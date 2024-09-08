# 55. 옵셔널(Optional) 반환은 신중히 하라
## 값을 반환하지 못할 경우
- 1. `예외` 던지기
  - 예외는 진짜 예외적인 상황에서 사용해야한다.
  - 예외를 생성할 때 스택 추적 전체를 캡처해야한다.
- 2. `null` 반환하기
  - 별도의 `null` 처리 코드를 추가해야한다.
  - 실제 원인과 상관없는 코드에서 `NullPointerException`이 발생할 수 있다.
- 3. `Optional<T>` : null이 아닌 T 타입 참조를 하나 담거나, 혹은 아무것도 담지 않을 수 있다.
  - 원소를 최대 1개 가지는 불변 컬렉션이다.

## `Optional<T>`
- 보통은 `T`를 반환해야 하지만, 특정 조건에서는 아무것도 반환하지 않아야 할 경우 `T` 대신 `Optional<T>`를 반환하도록 선언하자.
- 작동
  - 유효한 반환 값이 없을 경우 `빈 결과를 반환하는 메서드`(`Optional.empty()`)가 만들어진다.
  - 유효한 반환 값이 있을 경우 (`null` 이 아니면), 해당 값을 포함하는 `Optional`을 반환한다.
- 장점
  - 예외를 던지는 메서드보다 유연하고 사용하기 쉽다.
  - `null`을 반환하는 메서드보다 오류 가능성이 적다.
- 예제 코드
```java
// 코드 55-2 컬렉션에서 최댓값을 구해 Optional<E>로 반환한다. (327쪽)  
public static <E extends Comparable<E>>  
Optional<E> max(Collection<E> c) {  
    if (c.isEmpty())  
        return Optional.empty();  
  
    E result = null;  
    for (E e : c)  
        if (result == null || e.compareTo(result) > 0)  
            result = Objects.requireNonNull(e);  
  
    return Optional.of(result);  
}
```
- 주의점
  - `Optional.of()`에 `null` 을 넣으면 `NullPointerException`이 발생하니 주의하자.
  - `null` 이면 `Optional.empty()`를 반환하는 `Optional.ofNullable(value)`를 사용하자.

### Optional로 선언해야하는 경우
- 결과가 없을 수 있으며, 클라이언트가 값이 없을 경우를 특별하게 처리해야할 경우 `Optional`을 반환한다.

#### 옵셔널은 검사 예외와 취지가 비슷하다
- **반환 값이 없을 수도 있음**을 사용자에게 명확히 알려준다.
- `비검사 예외`를 던지거나 `null`을 반환한다면 **사용자가 그 사실을 인지하지 못해 끔찍한 결과로 이어질 수 있다.**
- `검사 예외`를 던지면 **클라이언트에서는 반드시 이에 대처하는 코드를 작성해야한다.**
  - `Optional`도 값을 얻지 못할 경우 취할 행동을 선택해야한다.

### 기본값 설정하기
```java
String lastWordInLexicon = max(words).orElse("단어 없음..");
```
-  `orElse(T other)`: 기본값을 직접 받는다.
  - Optional의 값 존재 여부와 관계없이 항상 평가된다.
  - 만약 이전 단계에서 `Optional.empty()`가 반환되었다면 호출된다.
- `orElseGet(Supplier<? extends T> supplier)`: 기본값을 생성하는 함수를 받는다.
  - `Optional`이 비어있을 때만 실행된다.
> 기본값을 설정하는 비용이 매우 커서 부담이 될 경우, orElseGet을 사용하면 초기 설정 비용을 낮출 수 있다.

### 원하는 예외를 던지기
```java
Toy myToy = max(toys).orElseThrow(TemperTanttrumException::new);
```
- `예외 팩터리`를 건넬 경우 예외가 실제로 발생하지 않는 한 `예외 생성 비용`은 들지 않는다.
  - `Optional`에 값이 있으면 예외 객체는 생성되지 않는다.

### 값이 채워져있음을 확신한다면 바로 값을 꺼내기
```java
Element lastE = max(Elements.NOBLE_GASES).get();
```
- 값이 없을 경우 `NoSuchElementException`이 발생할 수 있다.

### isPresent()
- `Optional`이 채워져있으면 `true`, 비어 있으면 `false`를 반환한다.
- 상당수는 앞서 언급한 메서드들로 대체할 수 있다.

#### ex) Map 사용
- `isPresent` 사용할 경우
```java
Optional<ProcessHandle> parentProcess = ph.parent();
System.out.println((parentProcess.isPresent() ? String.valueOf(parentProcess.get().pid()) : "N/A"));
```

- `map()` 사용
  - 더 의미가 명확하고 간단하다.
```java
System.out.println(ph.parent()
				  .map(h -> String.valueOf(h.pid())).orElse("N/A"));
```

#### `Stream<Optional<T>>`
- 값이 채워진 것들을 뽑아 처리하는 코드
```java
streamOfOptionals
	.filter(Optional::isPresent)
	.map(Optional::get);
```
-  java 9 이상 : `Optional.stream()`을 이용해 스트림으로 변환하기
  - 더 간단하고 명확하다.
```java
streamOfOptionals
	.flatMap(Optional::stream)
```

### 컬렉션, 스트림, 배열, 옵셔널 같은 컨테이너 타입은 옵셔널로 감싸면 안된다.
- `빈 컨테이너`를 그대로 반환하면 클라이언트에 옵셔널 처리 코드를 넣지 않아도 된다.

#### 기본 타입 필드일 경우 값이 없음을 나타낼 수 있다.
- 기본 타입이라 값을 나타낼 방법이 마땅치 않다.
- 필드를 옵셔널로 선언하고, `getter` 메서드들이 옵셔널을 반환하게 해주는 것도 좋다.

### Optional에는 대가가 따른다.
- 새롭게 할당하고 초기화하는 객체이고, 그 안에서 값을 꺼내려면 메서드를 호출해야한다.
- **성능이 중요할 경우 옵셔널이 맞지 않다.**

### 박싱된 기본 타입을 담는 옵셔널을 반환하지 말자
- 박싱된 기본 타입(예: Integer, Long, Double)을 담는 Optional 대신 전용 Optional 클래스를 사용하자.
  - `박싱/언박싱` 과정에서 불필요한 객체 생성이 발생하여 성능 저하를 일으킬 수 있다.
  - `OptionalInt`, `OptionalLong`, `OptionalDouble`을 사용하자.

### 옵셔널을 컬렉션의 키, 값, 원소나 배열의 원소로 사용하지 말자
- Map의 경우 키 자체가 없는 경우와 키는 있지만 그 키가 빈 옵셔널일 경우를 각각 처리해주어야한다.

# 결론
- 값을 반환하지 못할 가능성이 있고, 호출할 때마다 반환값이 없을 가능성을 염두에 두어야한다면 `Optional`을 반환하자
  - 옵셔널 반환에는 성능 저하가 뒤따르니 **성능에 민감할 경우 `null`을 반환하거나 `예외`를 던지자**.
- 옵셔널을 반환값 이외의 용도로 쓰는 경우는 매우 드물다.

