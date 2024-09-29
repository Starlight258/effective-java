## 요약

## 적합한 인터페이스만 있다면 매개변수뿐 아니라 반환값, 변수, 필드를 전부 인터페이스 타입으로 선언하라

```java
Set<Son> sonSet = new LinkedHashSet<>();

Set<Son> sonSet = new HashSet<>();
```

- 구현체를 간단하게 교체하여 코드의 유연성을 확보할 수 있음
- 다만 구현 클래스가 인터페이스 규약 외의 기능을 제공하고 코드가 이에 의존하는 경우 이 기능을 유지시켜줘야함
(LinkedHashSet 은 순서를 유지시키는 기능이 있지만 HashSet 에는 없음에 유의)

## 적합한 인터페이스가 없는 경우는 클래스를 참조하라

- `String` , `BigInteger` 같은 값 클래스 (보통 final)
- 클래스 기반으로 작성된 프레임워크가 제공하는 객체들 ex: `java.io.OutputStream`
- 인터페이스엔 없는 특별한 메서드를 제공하는 경우 ex: `PriorityQueue` 는 `Queue`  인터페이스에 없는 `comparator` 메서드 제공