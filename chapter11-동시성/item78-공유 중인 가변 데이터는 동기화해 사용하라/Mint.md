# 78. 공유 중인 가변 데이터는 동기화해 사용하라
### synchronized
- 해당 메서드나 블록을 **한번에 한 스레드씩 수행하도록 보장**한다.

### 동기화란?
- **배타적 실행** : 한 스레드가 변경하는 중에 상태가 일관성이 깨진 객체를 다른 스레드가 보지 못하도록 막는다.
    - 한 객체가 일관된 상태로 생성되고, 접근하는 메서드는 그 객체에 락을 건다. 락을 건 메서드는 객체의 상태를 확인하고 필요에 따라 수정한다.
    - 객체를 하나의 일관된 상태에서 다른 일관된 상태로 변화시킨다.
    - **변경 중인 객체를 다른 스레드가 보지 못하도록 막는다.**
- **스레드 사이의 안정적인 통신** : 동기화된 메서드나 블록에 들어간 스레드가 같은 락의 보호하에 **수행된 모든 이전 수정의 최종 결과를 보게 해준다**.
    - java 메모리 모델은 한 스레드가 변경한 값이 다른 스레드에 즉시 보이지 않을 수 있다.
        - 성능 최적화로 인해 CPU 캐시나 레지스터에 값을 임시로 저장하기 때문이다.
    - **동기화는 한 스레드의 변경사항이 다른 스레드에게 즉시 보이도록 보장한다.**
    - java는 스레드가 필드를 읽을 때 항상 수정이 완전히 반영된 값을 얻는 것을 보장하지만, 한 스레드가 저장한 값이 다른 스레드에게 보이는가는 보장하지 않는다.

#### 원자적 (atomic)
- 여러 스레드가 같은 변수를 **동기화없이 수정하는 중이라도**, **항상 어떤 스레드가 정상적으로 저장한 값을 온전히 읽어온다.**
    - ex) long, double외의 변수를 읽고 쓰는 동작

#### 다른 스레드를 멈추는 방법
- `Thread.stop()`은 사용하지 말자
- boolean 필드를 읽고 쓰는 원자적인 작업을 이용한다면?
    - 예상한 것과 달리 영원히 수행된다.
    - 동기화하지 않으면 메인 스레드가 수정한 값을 백그라운드 스레드가 언제 보게 될지 보증할 수 없다.
    - 동기화가 빠지면 가상 머신이 최적화를 수행할 수도 있다. - 끌어올리기(`hoisting`) 최적화 기법 (ex ) `while(true)`)
```java
package effectivejava.chapter11.item78.brokenstopthread;  
import java.util.concurrent.*;  
  
// 코드 78-1 잘못된 코드 - 이 프로그램은 얼마나 오래 실행될까? (415쪽)  
public class StopThread {  
    private static boolean stopRequested;  
  
    public static void main(String[] args)  
            throws InterruptedException {  
        Thread backgroundThread = new Thread(() -> {  
            int i = 0;  
            while (!stopRequested)  
                i++;  
        });  
        backgroundThread.start();  
  
        TimeUnit.SECONDS.sleep(1);  
        stopRequested = true;  
    }  
}
```
- boolean 필드를 동기화하여 접근하면 문제가 해결된다.
```java
package effectivejava.chapter11.item78.fixedstopthread1;  
import java.util.concurrent.*;  
  
// 코드 78-2 적절히 동기화해 스레드가 정상 종료한다. (416쪽)  
public class StopThread {  
    private static boolean stopRequested;  
  
    private static synchronized void requestStop() {  // 동기화하여 쓰기
        stopRequested = true;  
    }  
  
    private static synchronized boolean stopRequested() {  // 동기화하여 읽기
        return stopRequested;  
    }  
  
    public static void main(String[] args)  
            throws InterruptedException {  
        Thread backgroundThread = new Thread(() -> {  
            int i = 0;  
            while (!stopRequested())  
                i++;  
        });  
        backgroundThread.start();  
  
        TimeUnit.SECONDS.sleep(1);  
        requestStop();  
    }  
}
```

### 쓰기 메서드와 읽기 메서드 모두 동기화해야 예상한 동작을 보장한다.
- 쓰기 작업만 동기화하고 읽기 작업을 동기화하지 않으면, 다른 스레드에서 변경된 값을 즉시 볼 수 없다.

### volatile 한정자
- 쓰기 작업은 모든 스레드에 즉시 반영되며, 읽기 작업은 항상 가장 최근에 기록된 값을 읽게 된다.
```java
// 코드 78-3 volatile 필드를 사용해 스레드가 정상 종료한다. (417쪽)  
public class StopThread {  
    private static volatile boolean stopRequested;  
  
    public static void main(String[] args)  
            throws InterruptedException {  
        Thread backgroundThread = new Thread(() -> {  
            int i = 0;  
            while (!stopRequested)  
                i++;  
        });  
        backgroundThread.start();  
  
        TimeUnit.SECONDS.sleep(1);  
        stopRequested = true;  
    }  
}
```
- 사용 예시
    - **단일 변수의 읽기/쓰기**: 하나의 스레드가 쓰고 다른 스레드들이 읽는 패턴에 적합하다.
    - **플래그 변수**: 상태 변경을 다른 스레드에 즉시 알려야 할 때 유용하다.

- 배타적으로 실행되지 않으므로 사용시 주의해야한다.
    - 두 스레드가 동시에 값을 읽는다면 같은 값을 반환받게 된다.
    - `synchronized`를 메서드에 붙이면 동기화 문제는 해결된다. (이때 volatile은 지워야한다.)
```java
// 문제 상황 
private static volatile int nextSerialNumber = 0;

public static int generateSerialNumber(){
	return nextSerialNumber++;
}

// 해결 방법 - 동기화
private static int nextSerialNumber = 0;

public static synchronized int generateSerialNumber(){
	return nextSerialNumber++;
}
```

### Atomic 패키지
- **락 없이도 스레드 안전한 프로그래밍을 지원하는 클래스**
- 동기화의 모든 특성 - 통신 + 배타적 실행(원자성) 까지 지원한다.
    - volatile은 통신만 지원한다.
- 성능도 동기화 버전보다 우수하다.
```java
// 해결 방법 - 동기화
private static final AtomicLong nextSerialNum = new AtomicLong();

public static long generateSerialNumber(){
	return nextSerialNum.getAndIncrement();
}
```

### 가변 데이터는 공유하지 말자
- 가변 데이터는 단일 스레드에서만 쓰자
- 불변 데이터만 공유하거나 아무것도 공유하지 말자.
- 문서에 남겨 유지보수 과정에서 정책이 잘 지켜지도록 하자.

### 사실상 불변 (effectively immutable)
- **객체가 처음 생성된 후 더 이상 수정되지 않는 상태**
- 한 스레드가 데이터를 다 수정한 후 다른 스레드에 공유할 때는 **해당 객체에서 공유하는 부분만 동기화해도 된다**.
    - 그 객체를 다시 수정할 일이 생기기 전까지 다른 스레드들은 동기화 없이 자유롭게 값을 읽어갈 수 있다.
- **안전 발행**
    - 객체를 다른 스레드에 공유할 때 사용하는 기법이다.
    - 안전하게 발행된 객체는 다른 스레드에서 동기화 없이 안전하게 읽을 수 있다.
- **안전 발행하는 방법** : 클래스 초기화 과정에서 객체를 `정적 필드`, `volatile 필드`, `final 필드`, 혹은 `보통의 락`을 통해 접근하는 필드에 저장해도 된다.
    - `정적 필드`: 클래스 로딩 시 한 번만 초기화되므로 안전하다.
    - `volatile 필드`: 항상 가장 최신의 값을 보장한다.
    - `final 필드`: 객체 생성 후 변경되지 않음을 보장한다.
    - `보통의 락을 통해 접근하는 필드`: 동기화를 통해 가시성을 보장한다.
    - `동시성 컬렉션`: 자체적으로 스레드 안전성을 보장한다.

# 결론
- 여러 스레드가 가변 데이터를 공유한다면 그 데이터를 **읽고 쓰는 동작은 반드시 동기화**되어야한다.
    - 동기화하지 않으면 한 스레드가 수행한 변경을 다른 스레드가 보지 못할 수도 있다.
    - 동기화에 실패하면 응답 불가 상태에 빠지거나 안전 실패로 이어진다.
    - 간헐적이거나 특정 타이밍에만 문제가 발생할 수 있고 VM에 따라 현상이 달라지기도 한다.
- 배타적 실행은 필요 없고 **스레드끼리의 통신만 필요하다면 `volatile` 한정자만으로 동기화**할 수 있다.
    - 하지만 올바로 사용하기가 까다롭다.


