# 5. 자원을 직접 명시하지 말고 의존 객체 주입(DI)을 사용하라.

- 많은 클래스가 하나 이상의 자원에 의존한다.
- 정적 유틸리티로 구현한 경우가 있다.
```java
public class SpellChecker {
    private static final Lexicon dictionary = ...; // 자원

    private SpellChecker() {} // 객체 생성 방지

    public static boolean isValid(String word) { ... }
    public static List<String> suggestions(String typo) { ... }
}
```
- 싱글톤으로 구현할 수도 있다.
```java
public class SpellChecker {
    private final Lexicon dictionary = ...; // 자원

    private SpellChecker(...) {}

    public static SpellChecker INSTANCE = new SpellChecker(...);

    public boolean isValid(String word) { ... }
    public List<String> suggestions(String typo) { ... }
}
```
- 정적 유틸리티로 구현하거나 싱글톤으로 구현하는 것은 좋은 방법이 아니다.
    - 클래스는 여러 자원을 의존하는 경우가 많다.
    - final을 제거하고 매번 다른 사전으로 재할당할 경우 오류를 내기 쉽고 멀티 스레드 환경에서 쓸 수 없다.
    - 클래스가 자원을 직접 만드는 것도 좋은 방법이 아니다. 많은 책임을 가지게 되며 다른 구현으로 교체하기 어렵고 테스트가 어렵다.
      **=> 사용하는 자원에 따라 동작이 달라지는 클래스에는 정적 유틸리티 클래스나 싱글턴 방식이 적합하지 않다.**

### 인스턴스를 생성할 때 생성자에 필요한 자원을 넘겨주는 방식
- 클래스가 여러 자원 인스턴스를 지원할 수 있다.
- 클라이언트가 원하는 자원을 사용할 수 있다.
- 의존 객체 주입(DI)의 한 형태이다.

```java
public class SpellChecker {
    private final Lexicon dictionary;

    public SpellChecker(Lexicon dictionary) { // 클라이언트가 원하는 자원 주입 가능
        this.dictionary = Objects.requireNonNull(dictionary);
    }

    public boolean isValid(String word) { ... }
    public List<String> suggestions(String typo) { ... }
}
```

- 불변을 보장하여 여러 클라이언트가 의존 객체를 안심하고 공유할 수 있다.
    - final 필드에 의존성을 주입하면 재할당할 수 없다.
    - final 필드가 참조하는 객체도 불변이어야 불변을 완전히 보장할 수 있다.

#### 생성자에 자원 팩터리를 넘겨주는 방식
- 팩터리(Factory) : 호출할 때마다 특정 타입의 인스턴스를 반복해서 만들어주는 객체 = 팩터리 메서드 패턴
- **Supplier<T>** 를 파라미터로 받는 메서드
    - **한정적 와일드카드 타입** : 제네릭 타입의 상한, 하한을 지정
```java
`List<? extends Number>`: Number의 하위 클래스만 허용
`List<? super Integer>`: Integer의 상위 클래스만 허용
```
	- 클라이언트는 자신이 명시한 타입의 하위 타입이라면 무엇이든 생성할 수 있는 팩터리를 넘길 수 있다.
```java
public void processElements(Supplier<? extends Number> numberSupplier) {
    Number number = numberSupplier.get(); // Number의 모든 하위 클래스 넘기기 가능
}
```

### DI 주의점
- 의존 객체 주입이 유연성과 테스트 용이성을 개선해주기는 하지만, 의존성이 많은 프로젝트의 경우 코드를 어지럽게 만든다.
- 스프링같은 의존 객체 주입 프레임워크를 사용하면 어느정도 해결이 가능하다.

### 결론
- 클래스가 내부적으로 **하나 이상의 자원에 의존**하고, 그 자원이 클래스 동작에 영향을 준다면 싱글턴과 정적 유틸리티 클래스는 사용하지 않는 것이 좋다.
- 이 자원들을 클래스가 직접 만들게 해서도 안된다.****
- 대신 **필요한 자원(또는 자원을 만드는 팩터리)을 생성자(혹은 정적 팩터리나 빌더)에 넘겨**주자.
- 의존 객체 주입(DI)라 하는 이 기법은 **클래스의 유연성, 재사용성, 테스트 용이성을 개선**해준다.

