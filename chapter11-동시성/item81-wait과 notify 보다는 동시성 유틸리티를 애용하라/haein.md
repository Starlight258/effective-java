## 요약

### `wait` 과 `notify` 는 올바르게 사용하기가 아주 까다로우니 고수준 동시성 유틸리티를 사용하자
- `java.util.concurrent` 의 고수준 유틸리티는 실행자 프레임워크, 동시성 컬렉션, 동기화 장치로 나뉠 수 있다


### 동시성 컬렉션 
- 표준 컬렉션 인터페이스에 동시성을 더해서 구현
- 내부적으로 동시성을 구현
    - 외부에서 락을 걸면 성능 저하를 유발
    - 동시성을 무력화하는 건 불가능함 (여러 기본 동작들을 하나로 묶는 **상태 의존적 수정 메서드)  - `putIfAbsent(key, value)`**
- `ConcurrentHashMap`

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

   
    - 동기화한 컬렉션(`synchronizedMap`) 보다 성능이 좋다 : bucket-wise 동기화를 지원하여 컬렉션 전체를 잠그는 것보다 성능이 우수하다
    - `get` 과 같은 검색 기능에 최적화되어있다고 한다 (get 은 동기화를 지원하지는 않는다)
    - 동기화된 맵을 동시성 컬렉션으로 전환하면 상당한 성능 개선을 기대할 수 있음

- `BlockingQueue`
    - 작업이 성공적으로 완료될 때까지 기다리도록(block) 설계됨
    - 생산자-소비자 큐로 사용
    - 대부분의 `ExecutorService` 구현체에서 사용함


### 동기화 장치(synchronizer)
- 스레드가 다른 스레드를 기다릴 수 있게 하여 작업을 조율할 수 있게 해줌
- `CountDownLatch`, `Semaphore` 를 많이 사용 `CyclicBarrier` , `Exchanger` 는 덜 쓰이고  가장 강력한 동기화 장치는 `Phaser`

```java
  public static long time(Executor executor, int concurrency,
                            Runnable action) throws InterruptedException {
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

        ready.await();     // 모든 작업자가 준비될 때까지 기다린다.
        long startNanos = System.nanoTime();
        start.countDown(); // 작업자들을 깨운다.
        done.await();      // 모든 작업자가 일을 끝마치기를 기다린다.
        return System.nanoTime() - startNanos;
    }

```

- `CountDownLatch` 는 객체를 생성할 때 인자로 준 count가 0이 될 때가지 `await` 호출한 스레드를 기다리게 만든다  (`countDown`)
- 각 작업을 동시에 실행하고 모두 완료하기까지 걸리는 시간을 측정하고자 할 때
    - `CountDownLatch` 를 이용하여 각 스레드가 준비될때까지 기다리고(ready),  준비가 다 되면 시작(start),  완료되면(done) 측정 시간을 반환
    - 실행자 서비스는 동시성 수준(concurrency) 만큼의 스레드를 만들 수 있어야 됨, 그것보다 적으면 done 이 안끝남
    - InterruptException 을 캐치하면 이를 되살리고 빠져나감 (실행자가 이를 처리할 수 있도록 하기 위해)
    - 시간 간격을 측정할 때는 `System.nanotime` 이 `System.currentTimeMillis` 를 사용하자




### wait 과 notify 를 다뤄야 하는 경우

```java
synchronized (obj) {
    while (조건이 충족되지 않았다) 
        obj.wait(); // 락을 놓고, 깨어나면 다시 잡는다.
    

    ... // 조건이 충족됐을 때의 동작을 수행한다.
}
```

- `wait` 은 반복문 밖에서는 절대로 호출하면 안된다
    - `wait` 호출 전후로 조건이 만족하는지를 검사함
    - 대기 전에 조건을 검사하여 만족하면 `wait` 을 건너뜀 → 응답 불가 상태를 예방
    - 대기 후에 조건을 검사하여 충족되지 않았다면 다시 `wait` → 안전 실패를 막는 조치

- 조건이 만족하지 않아도 스레드가 깨어날 수도 있음
    - 스레드가 `notify` 호출했는데 대기중인 다른 스레드가 락을 얻어 상태를 변경함
    - 조건이 만족되지 않았음에도 다른 스레드가 실수, 고의로 `notify` 를 호출하는 경우
    - 대기중인 스레드 중 일부만 조건이 충족되었는 `notifyAll` 호출하는 경우
    - `notify` 없어도 깨어날 수 있다 (Spurious wakeup)

- `notify` 보다 `notifyAll` 을 호출하는 것이 일반적으로 더 안전하고, 합리적임
    - 깨어나야 하는 모든 스레드가 깨어남을 보장 (조건이 미충족된 스레드는 다시 대기함)
    - 관련 없는 스레드가 실수, 고의로 `wait` 로 호출하는 공격으로부터 안전함