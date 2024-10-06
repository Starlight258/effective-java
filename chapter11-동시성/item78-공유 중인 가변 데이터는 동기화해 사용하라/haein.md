## 요약

### 동기화는 배타적 실행뿐 아니라 스레드 사이의 안정적인 통신에 꼭 필요하다 
- `synchronized` 키워드 : 선언된 메서드나 코드블록이 한번에 한 스레드씩 수행하도록 보장한다
- 동기화의 기능
    1. 동기화는 객체의 변경되는 순간을 숨길 수 있음 (베타적 실행)
    1. 그리고 동기화 없이는 한 스레드가 만든 변화를 다른 스레드에서 확인할 수 없음  (통신)
- 자바 언어 명세는 `long` 과 `double` 외의 변수를 읽고 쓰는 동작은 원자적이라고 보장함 
- 하지만 한 스레드가 저장한 값을 다른 스레드가 볼 수 있는 지는 보장하지 않으므로 동기화는 중요하다
- 동기화에 실패하면 처참한 결과로 이어질 수 있다 (`Thread.stop` 메서드는 안전하지 않아서 deprecated 되었다)


```java
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
- `boolean` 필드를 동기화하지 않으면 메인 스레드가 수정한 값을 백그라운드 스레드가 언제 보게 될 지 보장할 수 없다



```java
public class StopThread {
    private static boolean stopRequested;

    private static synchronized void requestStop() {
        stopRequested = true;
    }

    private static synchronized boolean stopRequested() {
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
- 쓰기 메서드와 읽기 메서드를 모두 동기화해야 동작이 보장된다 
- 이 코드에서 동기화는 통신 목적으로만 수행되었다 (원자성은 원래도 잘 동작함)

### `volatile` 키워드 

```java
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
- `volatile` 키워드를 사용한다면 항상 가장 최근 기록된 값을 읽게 되도록 보장한다 
- 매번 동기화하는 부분에서 최적화를 달성할 수 있다 


```java
private static volatile int nextSerialNumber = 0; 

public static int generateSerialNumber() {
	return nextSerialNumber++;
}
```
- `volatile` 키워드는 베타적 실행을 보장하지 않는다
- 이 코드에서 증가 연산자는, 논리상 `nextSerialNumber` 에 두 번 접근한다 (값을 읽고, 그 후  +1 된 값을  저장)
- 새로운 스레드가 이 시점 사이에 들어와 값을 읽어가면 첫 번째 스레드와 똑같은 값을 돌려받게 된다 (안전 실패)

> [이 부분 설명한 글](https://parkcheolu.tistory.com/16)

- 이 경우엔 `synchronized` 키워드를 사용하고 `volatile` 키워드를 제거해야 한다 


### `java.util.concurrent.atomic` 패키지의 `AtomicLong` 을 사용해보자
- 락 없이도 스레드 안전한 프로그래밍을 지원한다
- 동기화의 효과 중 배타적 실행, 통신 모두를 지원한다 

```java
private static AtomicLong nextSerialNum = new AtomicLong(); 

public static int generateSerialNumber() {
	return nextSerialNum.getAndIncrement();
}
```

### 가변 데이터는 단일 스레드에서만 쓰도록 하자
- 이 사실을 문서화하자
- 사용하는 프레임워크나 라이브러리를 깊이 이해하자
- 한 스레드가 데이터를 수정한 후 다른 스레드에 공유할 떄는 해당 객체에서 공유하는 부분만 동기화해도 된다 (사실상 불변)
- 이런 객체를 건내는 방법은 안전 발행이라고 한다 
    - 정적 필드, volatile 필드, final 필드, 보통의 락을 통해 접근하는 필드, 동시성 컬렉션에 저장