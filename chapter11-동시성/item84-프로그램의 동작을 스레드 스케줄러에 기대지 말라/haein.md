## 요약

### 정확성이나 성능이 스레드 스케줄러에 따라 달라지는 프로그램이라면 다른 플랫폼에 이식하기 어렵다
- 구체적인 스케줄러 정책은 OS 마다 달라질 수 있음
- 견고하고, 빠릿하고, 이식성 좋은 프로그램을 작성하려면 실행 가능한 스레드의 평균적인 수를 프로세서 수보다 지나치게 많아지지 않도록 해야 함
- 스레드는 당장 처리해야 할 작업이 없다면 실행되어선 안됨, 작업 완료 후에는 대기하도록 해야 함
- 스레드는 바쁜 대기(busy waiting) 상태가 되어선 안됨
    - 공유 객체의 상태가 바뀔 때까지 쉬지 않고 검사해서는 안된다 (실행을 기다리는 게 아니라 계속 확인하는 것)
    - 스케줄러의 변덕에 취약하며, 프로세서에도 큰 부담을 준다

```java
public class SlowCountDownLatch {
    private int count;

    public SlowCountDownLatch(int count) {
        if (count < 0)
            throw new IllegalArgumentException(count + " < 0");
        this.count = count;
    }

    public void await() {
        while (true) {
            synchronized(this) {
                if (count == 0)
                    return;
            }
        }
    }
    public synchronized void countDown() {
        if (count != 0)
            count--;
    }
}
```

- 공유자원을 사용할 수 있을 때까지 계속 검사하는 방식의 구현 (최악)

### Thread.yield 를 써서 문제를 고쳐보려는 유혹을 떨쳐내자

- `yield` 는 호출한 스레드를 대기 상태로 돌리고 다른 스레드에게 실행을 양보하는 것
- CPU 시간이 부족한 스레드를 해결하려고 `yield` 를 써도 이식성에 문제가 있으며, 테스트할 수단도 없음
- 비슷한 예시로 스레드 우선순위를 조절하는 것도 합리적이지 않음 (`setPriority` )

> 프로그램의 동작을 스레드 스케줄러에 기대지 말자 견고성과 이식성을 모두 해치는 행위다. 같은 이유로,
>`Thread.yield` 와 스레드 우선순위에 의존해서는 안 된다. 이 기능들은 스레드 스케줄러에 제공하는 힌트일 뿐이다.
>스레드 우선순위는 이미 잘 동작하는 프로그램의 서비스 품질을 높이기 위해 드물게 쓰일 수는 있지만, 간신히
> 동작하는 프로그램을 ‘고치는 용도’로 사용해서는 절대 안 된다.




