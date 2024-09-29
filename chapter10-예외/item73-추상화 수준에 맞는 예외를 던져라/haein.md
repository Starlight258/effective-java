## 요약

### 상위 계층에서는 저수준 예외를 잡아 자신의 추상화 수준에 맞는 예외로 바꿔 던져야 한다 (예외 번역)
- 메서드가 저수준 예외를 처리하지 않고 바깥으로 전파할 수 있음
    - 내부 구현 방식을 드러내어 윗 레벨 API 를 오염시킨다
    - 구현 방식을 바꾸면 다른 예외가 튀어나와 기존 클라이언트 프로그램을 깨지게 할 수도 있다 


```java
try{
    ... // 저수준 추상화를 이용한다
} catch (LowLevelException e){
    // 추상화 수준에 맞게 번역한다
    throw new HighlevelException(...);
}
```

- 예외를 번역할 때, 저수준 예외가 디버깅에 도움이 된다면 예외 연쇄를 사용하는 게 좋다

```java
try{
    ... // 저수준 추상화를 이용한다
} catch (LowLevelException cause){
    // 저수준 예외를 고수준 예외에 실어 보낸다
    throw new HighlevelException(cause);
}
```

- 별도의 접근자 메서드를 통해 저수준 예외를 꺼내볼 수 있다 (`getCause`)
- 고수준 예외의 생성자는 예외 연쇄용으로 설계된 상위 클래스의 생성자에게 `원인` 을 건네주어 `Throwable(Throwable)` 생성자까지
건네지게 한다 

```java
class HighLevelException extends Exception{
    HighLevelException(Throwable cuase){
        super(cause);
    }
}
```

### 그렇다고 예외 번역을 남용해서는 곤란하다 
- 가능하다면 저수준 메서드가 반드시 성공하도록 하여 아래 계층에서는 예외가 발생하지 않도록 하는 것이 최선이다 
- 아래 계층에서 예외를 피할 수 없다면, 상위 계층에서 예외를 조용히 처리해서 API 호출자까지 전파하지 않는 방법이 있다
    - 이 경우 발생한 예외는 `java.util.logging` 같은 적절한 로깅 기능을 활용하여 기록해두면 좋다 