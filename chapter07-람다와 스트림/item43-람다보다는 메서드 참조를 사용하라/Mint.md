# 43. 람다보다는 메서드 참조를 사용하라
## 메서드 참조
- 함수 객체를 람다보다도 더 간결하게 만드는 방법

### 람다
```java
map.merge(key, 1, (count, incr) -> count+incr);
```
- `merge`: 주어진 키가 멥 안에 아직 없다면 주어진 카, 값 쌍을 그대로 저장한다.
    - 키가 이미 있다면, 함수를 현재 값과 주어진 값에 적용한 다음, 그 결과로 현재 값을 덮어쓴다.
> 매개변수 이름 자체가 좋은 가이드가 되기도 한다.

### 메서드 참조 사용
```java
map.merge(key, 1, Integer::sum);
```
- 더  간단하게 줄일 수 있다.
- **람다로 구현했을 때 너무 복잡하다면, 메서드 참조로  대체하자.**
    - 메서드 이름을 잘 지으면  기능을 잘 드러낼 수 있다.
    - 람다와 달리 문서도 작성할 수 있다.
> 매개변수 수가 늘어날수록, 메서드 참조로 제거할 수 있는 코드양도 늘어난다.

#### 때론 람다가 메서드 참조보다 간결할 때도 있다.
- 주로 메서드와 람다가 같은 클래스에 있을 때 그렇다.

- 메서드 참조
```java
service.execute(GoshThisClassNameIsHumongous::action);
```
- 람다
```java
service.execute(() -> action());
```

## 메서드 참조의 유형
### 1. 정적 메서드를 가리키는 메서드 참조
- 클래스의 정적 메서드를 참조한다.
- `ClassName::staticMethodName`
- ex) `Integer::parseInt`

```java
Function<String, Integer> parser = Integer::parseInt;
int result = parser.apply("10"); // 결과: 10
```

### 2. 수신 객체를 특정하는 한정적 인스턴스 메서드 참조
-  특정 객체의 인스턴스 메서드를 참조한다.
-  `object::instanceMethodName`
    -  ex)`System.out::println`

```java
Consumer<String> printer = System.out::println;
printer.accept("Hello"); // 출력: Hello
```
- 함수 객체가 받는 인수 = 참조되는 메서드가 받는 인수
    - `printer.accept("Hello");`를 호출하면, "`Hello`"라는 인수가 `System.out::println`로 그대로 전달된다.

### 3. 수신 객체를 특정하지 않는 비한정적 인스턴스 메서드 참조
- 클래스의 인스턴스 메서드를 참조하지만, 특정 객체를 지정하지 않는다.
- `ClassName::instanceMethodName`
- ex) `String::toLowerCase`

```java
Function<String, Integer> lengthFunc = String::length;
int length = lengthFunc.apply("Hello"); // 결과: 5
```
- 함수 객체를 적용하는 시점에 수신 객체를 알려준다.
    - 수신 객체 전달용 매개변수가 매개변수 목록의 첫번째로 추가되며, 그 뒤로는 참조되는 메서드 선언에 정의된 매개변수들이 뒤따른다.
- 주로 스트림 파이프라인에서의 매핑과 필터 함수에 쓰인다.

### 4. 클래스 생성자를 가리키는 메서드 참조
-  클래스의 생성자를 참조한다.
-  `ClassName::new`
    - ex) `ArrayList::new`

```java
Supplier<List<String>> listSupplier = ArrayList::new;
List<String> list = listSupplier.get(); // 새 ArrayList 인스턴스 생성
```
- 팩터리 객체로 사용된다.

### 5. 배열 생성자를 가리키는 메서드 참조
- 특정 타입의 배열 생성자를 참조한다.
- `TypeName[]::new`
    - ex)`int[]::new`

```java
Function<Integer, int[]> arrayCreator = int[]::new;
int[] newArray = arrayCreator.apply(5); // 길이가 5인 새 int 배열 생성
```

#### 참고)  함수형 인터페이스의 추상 메서드가 제네릭일 수 있다.
```java
@FunctionalInterface
public interface GenericFunctionalInterface<T, R> {
    R apply(T t);
}
```

#### 함수 타입도 제네릭일 수 있다.
>함수 타입은 람다 표현식, 메서드 참조, 익명 클래스 등을 포함한다.
```java
// 함수 타입
Function<T, R>

// 예시
Function<String, Integer> stringLength = s -> s.length();
```

## 결론
- 메서드 참조는 람다의 간단명료한 대안이 될 수 있다.
    - 메서드 참조 쪽이 짧고 명확하다면 메서드 참조를 쓰고, 그렇지 않을 때만 람다를 사용하라.

