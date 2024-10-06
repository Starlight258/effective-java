# 81. `wait`과 `notify`보다는 동시성 유틸리티를 애용하라
-  wait과 notify는 사용하기가 아주 까다롭다.
- 대신 고수준 동시성 유틸리티를 사용하자.

## 고수준 유틸리티
- 실행자 프레임워크 (item 80)
- 동시성 컬렉션
- 동기화 장치

### 동시성 컬렉션
- `List`, `Queue`, `Map` 같은 **표준 컬렉션 인터페이스에 동시성을 가미**해 구현한 고성능 컬렉션이다.
    - ex) `ConcurrentHashMap`, `CopyOnWriteArrayList`, `ConcurrentLinkedQueue`
- 높은 동시성에 도달하기 위해 동기화를 각자의 내부에서 수행한다.
    - 동시성 컬렉션에서 동시성을 비활성화 할 수 없으며, 외부에서 락을 추가로 사용하면 오히려 속도가 느려진다.
- 여러 기본 동작을 하나의 원자적 동작으로 묶는 **상태 의존적 메서드**들이 존재한다.
    - ex) `Map`의 `putIfAbsent(key, value)` : 주어진 키가 없을 때만 새 값을 추가하며, 원자적으로 수행한다.

#### ConcurrentHashMap
```java
// ConcurrentMap으로 구현한 동시성 정규화 맵  
public class Intern {  
    // 코드 81-1 ConcurrentMap으로 구현한 동시성 정규화 맵 - 최적은 아니다. (432쪽)  
    private static final ConcurrentMap<String, String> map =  
            new ConcurrentHashMap<>();  
  
    public static String intern(String s) {  
        String previousValue = map.putIfAbsent(s, s);  
        return previousValue == null ? s : previousValue;  
    }
```
- get 같은 검색 기능에 최적화되었으므로 get을 먼저 호출하여 필요할 때만 putIfAbsent를 호출하면 더 빠르다.
```java
// 코드 81-2 ConcurrentMap으로 구현한 동시성 정규화 맵 - 더 빠르다! (432쪽)  
public static String intern(String s) {  
    String result = map.get(s);  
    if (result == null) {  
        result = map.putIfAbsent(s, s);  
        if (result == null)  
            result = s;  
    }  
    return result;  
}
```

- `동시성 컬렉션`은 `동기화한 컬렉션`을 낡은 유산으로 만들었다.
    - `Collections.synchronizedMap` 보다는 `ConcurrentHashMap`을 사용하는 것이 훨씬 좋다.
    - 동기화된 맵을 동시성 맵으로 교체하면 동시성 애플리케이션의 성능이 극적으로 개선된다.

#### BlockingQueue
- 큐가 비었으면 새로운 원소가 추가될 때까지 기다린다.
- 작업 큐(생산자-소비자 큐)로 쓰기에 적합하다.
    - 작업 큐는 하나 이상의 생산자 스레드가 작업을 큐에 추가하고, 하나 이상의 소비사 스레드가 큐에 있는 작업을 꺼내 처리한다.
    - 대부분의 실행자 서비스 구현체에서 `BlockingQueue`를 사용한다.

## 동기화 장치
- `CountDownLatch`, `Semaphore`이 가장 자주 쓰인다
- `CyclicBarrier`와 `Exchanger`는 그보다 덜 쓰인다.
- 가장 강력한 동기화 장치는 `Phaser`다.

### CountDownLatch
- **일회성 장벽**으로, 하나 이상의 스레드가 또 다른 하나 이상의 스레드 작업이 끝날 때까지 기다리게 한다.
- 생성자는 `int` 값을 받으며, 래치의 `countDown` 메서드를 몇번 호출해야 대기 중인 스레드들을 깨우는지를 결정한다.

#### 동시 실행 시간을 재는 간단한 프레임워크
- **ready 래치** : 작업자 스레드들이 준비가 완료가 되었음을 스레드에 통지할 때 사용한다.
- 통지를 끝낸 작업자 스레드들은 두번째 래치인 `start`가 열리기를 기다린다.
- 마지막 작업자 스레드가 `ready.countDown`을 호출하면 타이머 스레드가 시작 시각을 기록하고 `start.countDown`을 호출하여 기다리던 작업자 스레드를 깨운다.
- **down 래치**는 마지막 작업자 스레드가 동작을 마치고 `down.countDown`을 호출하면 열린다.
- 타이머 스레드는 **done 래치**가 열리자마자 깨어나 종료 시각을 기록한다.
```java
// 코드 81-3 동시 실행 시간을 재는 간단한 프레임워크 (433-434쪽)  
public class ConcurrentTimer {  
    private ConcurrentTimer() { } // 인스턴스 생성 불가  
  
    public static long time(Executor executor, int concurrency,  
                            Runnable action) throws InterruptedException {  
        // 작업자 스레드 생성
        CountDownLatch ready = new CountDownLatch(concurrency);  
        CountDownLatch start = new CountDownLatch(1);  
        CountDownLatch done  = new CountDownLatch(concurrency);  

        for (int i = 0; i < concurrency; i++) {  
            executor.execute(() -> {  
                ready.countDown(); // 타이머에게 준비를 마쳤음을 알린다.  
                try {  
                    start.await(); // 모든 작업자 스레드가 준비될 때까지 기다린다.  
                    action.run();  
                } catch (InterruptedException e) {  
                    Thread.currentThread().interrupt();  
                } finally {  
                    done.countDown();  // 타이머에게 작업을 마쳤음을 알린다.  
                }  
            });  
        }  

		// 타이머 로직
        ready.await();     // 모든 작업자가 준비될 때까지 기다린다.  
        long startNanos = System.nanoTime();  
        start.countDown(); // 작업자들을 깨운다. (모든 작업자 스레드를 동시에 시작)
        done.await();      // 모든 작업자가 일을 끝마치기를 기다린다.  
        return System.nanoTime() - startNanos;  
    }  
}
```
- time 메서드에 넘겨진 `실행자`(executor)는 동시성 수준만큼의 스레드를 생성할 수 있어야한다.
    - 그렇지 않으면 이 메서드는 절대로 끝나지 않는다. = **스레드 기아 교착상태**
```java
try {
    start.await(); // 모든 작업자 스레드가 준비될 때까지 기다린다.  
    action.run();  
} catch (InterruptedException e) {  
    Thread.currentThread().interrupt();  // 인터럽트 상태를 다시 설정하여 finally 블록으로 넘어간다.
} finally {
    done.countDown();  // 타이머에게 작업을 마쳤음을 알린다.  
} 
```
- `start.await()`에서 `InterruptedException`이 발생한다면, 예외를 캐치한 작업자 스레드는 `Thread.currentThread().interrupt()` 관용구를 사용해 인터럽트를 되살리고 `run()`에서 빠져나온다.
    - 현재 스레드의 인터럽트 상태를 true로 다시 설정한다.
- 시간 간격을 잴 때는 항상 `System.currentTimeMillis`가 아닌 `System.nanoTime`을 사용하자
    - `System.nanoTime`은 더 정확하고 정밀하며 시스템의 실시간 시간 보정에 영향받지 않는다.
    - 정밀한 시간 간격을 재려면 `jmh`같은 특수 프레임워크를 사용해야 한다.

## wait, notify를 사용하는 레거시 코드일 때
### wait
- `wait` 메서드는 **스레드가 어떤 조건이 충족되기를 기다리게 할 때 사용**한다.
- 락 객체의 `wait` 메서드는 반드시 해당 객체의 락을 획득한 동기화 블록 내에서 호출해야 한다.
```java
synchronized (obj) {
	while (<조건이 충족되지 않을 때>)
		obj.wait(); // 락을 놓고 깨어나면 다시 잡는다.
}
```
- `wait` 메서드를 사용할 때는 반드시 **대기 반복문 (wait loop)** 관용구를 사용하라.
    - 이 반복문은 **`wait` 호출 전후로 조건이 만족하는지를 검사**하는 역할을 한다.
    - 반복문 밖에서는 절대로 호출하지 말자. (외부로 공개된 객체에 대해 실수로 혹은 악의적으로 notify를 호출하는 상황 존재)
- 대기 전에 조건을 검사하여 조건이 이미 충족되었다면 wait를 건너뛰게 한 것은 응답 불가 상태를 예방한다.
    - 만약 조건이 이미 충족되었는데 스레드가 `notify` 메서드를 먼저 호출한 후 대기 상태로 빠지면, 그 스레드를 다시 깨울 수 있다고 보장할 수 없다.
- 대기 후에 조건을 검사하여 조건이 충족되지 않았다면 다시 대기하게 하는 것은 안전 실패를 막는 조치이다.
    - 조건이 충족되지 않았는데 스레드가 동작을 이어가면 락이 보호하는 불변식을 깨뜨릴 위험이 있다.

#### 조건이 만족되지 않아도 스레드가 깨어날 수 있는 상황
- 조건 변경 시점 문제
    - `notify` 호출과 대기 중이던 스레드가 깨어나는 사이에 다른 스레드가 상태를 변경할 수 있다.
- 잘못된 `notify` 호출
    - 다른 스레드가 실수로 또는 악의적으로 `notify`를 호출할 수 있다.
    - 특히 공개된 객체를 락으로 사용하는 경우 이러한 위험에 노출된다.
    - 외부에 노출된 객체의 동기화된 메서드 안에서 호출하는 wait는 모두 이 문제의 영향을 받는다.
- 과도한 `notifyAll` 사용
    - 일부 스레드의 조건만 충족되어도 `notifyAll`을 호출하여 모든 스레드를 깨울 수 있다.
- 허위 각성(spurious wakeup)
    - 대기 중인 스레드가 `notify` 없이도 깨어나는 현상

#### 대기 반복문 (wait loop)
- 이로인해 앞서 설명한 `대기 반복문`(wait loop)을 사용하는 것이 중요하다.
- 1. 스레드가 깨어날 때마다 **조건을 다시 확인**한다.
- 2. 조건이 여전히 만족되지 않았다면 다시 **대기 상태**로 들어간다.
- 3. 이를 통해 언급된 문제 상황들로부터 **안전성을 확보**할 수 있다.

### notify vs notifyAll
- `notify` : 스레드 하나만 깨운다.
    - 모든 스레드가 같은 조건을 기다리고, 조건이 한 번 충족될 때마다 단 하나의 스레드만 혜택을 받을 수 있다면 notifyAll 대신 notify를 사용해 최적화할 수 있다.
- `notifyAll` : 모든 스레드를 깨운다.
- 일반적으로 언제나 `notifyAll`을 사용하라는게 합리적이고 안전하다.
    - 다른 스레드까지 깨어날 수도 있긴 하지만, 조건을 확인하여 대기하거나 깨우므로 프로그램의 정확성에는 영향을 주지 않는다.
    - `notifyAll`을 사용하면 관련 없는 스레드가 실수로 혹은 악의적으로 `wait`를 호출하는 공격으로부터 보호할 수 있다.
        - 악의적인 스레드가 `wait`를 호출해도, `notifyAll`로 인해 곧바로 깨어나게 되어 시스템의 다른 부분이 무기한 대기하는 상황을 방지한다.


## 결론
- 코드를 새로 작성한다면 `wait`와 `notify`를 쓸 이유가 거의 없다.
- `wait`과 `notify`를 사용한 레거시 코드를 유지보수해야한다면 `wait`는 항상 표준 관용구에 따라 `while`문 안에서 호출하도록 하자.
- 일반적으로 `notify`보다는 `notifyAll`을 사용해야 한다.
    - 혹시라도 `notify`를 사용한다면 응답 불가 상태에 빠지지 않도록 주의하자. (조건이 충족되었음에도 모든 스레드가 대기 상태가 될 수 있다.)
