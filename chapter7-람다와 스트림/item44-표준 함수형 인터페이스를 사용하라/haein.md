## 요약

### 필요한 용도에 맞는 게 있다면, 직접 구현하지 말고 표준 함수형 인터페이스를 사용하라

| 인터페이스 | 함수 시그니쳐 | 예시 |
|------------|---------------|------|
| UnaryOperator<T> | T apply(T t) | String::toLowerCase |
| BinaryOperator<T> | T apply(T t1, T t2) | BigInteger::add |
| Predicate<T> | boolean test(T t) | Collection::isEmpty |
| Function<T,R> | R apply(T t) | Arrays::asList |
| Supplier<T> | T get() | Instant::now |
| Consumer<T> | void accept(T t) | System.out::println |


`IntFunction<Integer>` 과 같이 기본 타입의 함수형 인터페이스를 사용하면 기본 타입을 박싱하지 않고 직접적으로 기본 타입을 다룰 수 있다.

### 직접 함수형 인터페이스를 작성해야할 때는 언제인가?

- 자주 쓰이고 이름 자체가 용도를 명확히 설명해주고
- 반드시 따라야하는 규약이 있고
- 유용한 디폴트 메서드를 제공한다면

전용 함수형 인터페이스를 구현하는 것에 대한 고민이 필요하다.

### 직접 만든 함수형 인터페이스에는 @FunctionalInterface 애너테이션을 사용하자

- 해당 클래스의 코드나 설명 문서를 읽을 이에게 **그 인터페이스가 람다용으로 설계된 것임을 알려준다.** 
- 해당 인터페이스가 추상 메서드를 **오직 하나만 가지고 있어야 컴파일 되게 해준다.**
- 유지보수 과정에서 **실수로 누군가 메서드를 추가하지 못하게** 막는다.


### 서로 다른 함수형 인터페이스를 같은 위치의 인수로 받는 메서드들을 다중 정의해서는 안된다
- 클라이언트에게 모호함을 안겨주고, 형변환해야하는 불편함이 생김