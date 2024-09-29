제네릭은 java 5부터 사용할 수 있다.
## 제네릭 도입 이유
1. **코드 재사용성 향상**
   동일한 로직을 다양한 타입에 적용할 수 있다.

2. **타입 안정성 향상**
   컴파일 시점에 타입 오류를 잡아내고 런타임 에러 위험이 줄어든다.

## 제네릭과 형변환
### 제네릭을 지원하기 전에는 컬렉션에서 객체를 꺼낼때마다 형변환을 해야 했다.

Java 5 이전
1. 컬렉션은 `Object` 타입으로 요소를 저장했다.
2. **컬렉션에서 요소를 꺼낼 때마다 원하는 타입으로 형변환**을 해야 했다.
3. 이는 **런타임 오류**의 위험을 증가시켰다.


```java
// Java 5 이전
List list = new ArrayList();
list.add("Hello");
list.add("World");

// 요소를 꺼낼 때마다 형변환이 필요
String s1 = (String) list.get(0);
String s2 = (String) list.get(1);

// 잘못된 타입으로 형변환하면 런타임 오류가 발생
// Integer i = (Integer) list.get(0); // ClassCastException
```

문제점
1. 코드가 지저분해진다 (형변환이 자주 발생).
2. 컴파일 시점에 타입 안정성을 보장할 수 없다.
3. 잘못된 타입으로 형변환하면 런타임 오류(`ClassCastException`)가 발생한다.

Java 5 이후 (제네릭 도입)

```java
// Java 5 이후
List<String> list = new ArrayList<>();
list.add("Hello");
list.add("World");

// 형변환 필요 없음
String s1 = list.get(0);
String s2 = list.get(1);

// 컴파일 오류 - 타입 안정성 보장
// list.add(10); // 컴파일 오류
```

이점
1. 코드가 간결해진다 (불필요한 형변환 제거)
2. **컴파일 시점에 타입 안정성을 보장**한다.
3. 잘못된 타입의 객체를 추가하려 하면 **컴파일 오류가 발생**합니다.

## 제네릭 용어

### 1. 제네릭 타입 (Generic Type)
- **타입 매개변수를 가진 클래스나 인터페이스**
    - 예시: `List<E>`, `Map<K,V>`
- 타입에 의존적인 클래스나 인터페이스를 정의할 때 사용

```java
public class Box<T> {  // Box<T>는 제네릭 타입
    private T value;
    public void set(T value) { this.value = value; }
    public T get() { return value; }
}
```

### 2. 정규 타입 매개변수 (Formal Type Parameter) = 타입 매개변수
- 제네릭 타입 선언에 사용되는 타입 매개변수
    - `<T>`, `<E>`, `<K, V>`
- 제네릭 클래스나 메서드를 정의할 때 사용

```java
public interface Comparable<T> {  // T는 정규 타입 매개변수
    int compareTo(T o);
}
```

#### 정규 타입 매개변수의 다양한 이름

정규 타입 매개변수의 이름(E, T, K, V 등)은 단순한 컨벤션이며, 기능적 차이는 없다.
하지만 **가독성**을 위해 일반적으로 다음과 같이 사용된다.

- `E` (Element): 컬렉션의 요소 타입을 나타낼 때
- `T` (Type): 일반적인 타입을 나타낼 때
- `K` (Key): 맵의 키 타입을 나타낼 때
- `V` (Value): 맵의 값 타입을 나타낼 때
- `N` (Number): 숫자 타입을 나타낼 때
- `S`, `U`, `V` 등: 여러 타입 파라미터가 필요할 때 추가로 사용

```java
public interface List<E> { ... }
public class Box<T> { ... }
public interface Map<K, V> { ... }
public class NumberBox<N extends Number> { ... }
```

> 이를 통해 코드의 의도와 타입을 쉽게 유추할 수 있다.

### 3. 매개변수화 타입 (Parameterized Type)
- **제네릭 타입에 실제 타입 인자를 지정한 것**
    - ex) `List<String>`, `Map<String, Integer>`
- 컬렉션이나 제네릭 클래스를 사용할 때 사용

```java
List<String> names = new ArrayList<>();  // ArrayList<String>은 매개변수화 타입
```
> 제네릭 타입이 타입 인자를 받아 구체화된다.

### 4. 실제 타입 매개변수 (Actual Type Parameter)
- 제네릭 타입을 사용할 때 **지정하는 실제 타입**
    - 예시: `<String>`, `<Integer>`
- 제네릭 타입을 구체화할 때 사용

```java
Map<String, Integer> scores = new HashMap<>();  // String과 Integer가 실제 타입 매개변수
```

#### 예시
```java
// 제네릭 타입 정의
public interface List<E> {
    void add(E element);
    E get(int index);
}

// 매개변수화 타입 사용
List<String> stringList = new ArrayList<>();
List<Integer> integerList = new ArrayList<>();
```
- `E` : 타입 매개변수
- `List<E>` : 제네릭 타입
- `List<String>`, `List<Integer>` : 매개변수화 타입
- `String`과 `Integer`는 실제 타입 매개변수
> 매개변수화 타입은 일반적인 타입 정의를 특정 타입으로 구체화하는 과정을 나타낸다.

### 5. 비한정적 와일드카드 타입 (Unbounded Wildcard Type)
- **모든 타입을 대신할 수 있는 와일드카드**
    - `List<?>`, `Map<?, ?>`
- 타입 파라미터에 의존적이지 않은 메서드를 작성할 때 사용

```java
public void printList(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
}
```

#### 정규 타입 매개변수(T)와 와일드카드(?) 차이

a) `T` (타입 파라미터)
- **특정 타입**을 나타낸다.
- **클래스, 인터페이스, 메서드**에서 사용할 수 있다.
- 타입 정보를 사용할 수 있다 (**읽기/쓰기 가능**).
- 여러 메서드 호출에서 타입 관계를 유지할 수 있다.
- 반환 타입이 입력 타입과 관계가 있을 때 사용한다. (`T`)

b) `?` (와일드카드)
- **알 수 없는 타입**을 나타낸다.
- 주로 **메서드 파라미터**에서 사용된다.
- 타입 정보를 사용할 수 없다 (기본적으로 **읽기 전용**)
    - `? super T`의 경우 T 타입 또는 그 하위 타입을 쓸 수 있다.
- 여러 메서드 호출에서 타입 관계를 유지할 수 없다.
- 단일 메서드 내에서만 타입을 다룰 때 사용한다. (`void`)

```java
// 와일드카드 사용
public void printList(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
    // list.add(new Object()); // 컴파일 오류: 타입을 알 수 없어 추가할 수 없음
}

// 타입 파라미터 사용
public <T> void addToList(List<T> list, T item) {
    list.add(item); // 가능: T 타입의 아이템을 추가할 수 있음
}
```

#### 타입 파라미터를 사용한 경우 여러 메서드 호출에서 타입 관계를 유지할 수 있다.
```java
public class Box<T> {
    private T content;

    public void set(T item) {
        this.content = item;
    }

    public T get() {
        return content;
    }
}

public <T> void processBox(Box<T> box, T newItem) {
    T oldItem = box.get();  // 기존 아이템을 가져옴
    System.out.println("Old item: " + oldItem);
    box.set(newItem);       // 새 아이템을 설정
    System.out.println("New item: " + box.get());
}

// 사용 예
Box<String> stringBox = new Box<>();
stringBox.set("Hello");
processBox(stringBox, "World");  // 컴파일 성공, 타입 안전
```
- 컴파일러는 **타입 정보를 기억**한다.
> T는 String으로 고정된다.
- 메서드 내에서 일관된 타입으로 사용되며, 컴파일러가 타입 안정성을 확인할 수 있다.
> get을 호출했을 때 String을 반환하고, set은 String을 받아들인다.

#### 와일드 카드를 사용한 경우 타입 관계를 유지할 수 없다.
```java
public void processBoxWildcard(Box<?> box, Object newItem) {
    Object oldItem = box.get();  // OK, 모든 타입은 Object로 읽을 수 있음
    System.out.println("Old item: " + oldItem);
    // box.set(newItem);  // 컴파일 오류! 타입 안전성을 보장할 수 없음
}

// 사용 예
Box<String> stringBox = new Box<>();
stringBox.set("Hello");
processBoxWildcard(stringBox, "World");  // 컴파일 성공, 하지만 set 불가능
```
- **컴파일러는 구체적인 타입 정보를 잊어버린다. 알 수 없는 타입으로 취급한다.**
> processBox가 `Box<String>`을 `Box<?>` 타입을  받을 때, 컴파일러는 실제 타입이 String임을 의도적으로 잊어버린다

- 타입 안전성을 보장하기 위해 제한적인 작업(읽기)만 가능하다.
> get()을 사용할 수 있지만 Object로 반환되며, set()은 사용할 수 없다.
> 컴파일러가 box의 실제 타입을 알 수 없어 타입 안정성을 보장할 수 없기 때문이다.

### 6. 로 타입 (Raw Type)
- 제네릭 타입에서 **타입 매개변수를 전혀 사용하지 않은 것**
    -  `List` (제네릭 없이), `Map`
- 레거시 코드와의 호환성을 위해 사용 (권장X)

```java
List rawList = new ArrayList();  // 로 타입 (사용 권장하지 않음)
```

### 7. 한정적 타입 매개변수 (Bounded Type Parameter)
- **특정 타입이나 그 하위 타입으로 제한된 타입 매개변수**
    - `<T extends Number>`
- 타입 매개변수에 제약을 둘 때 사용

```java
public <T extends Comparable<T>> T max(T x, T y) {
    return x.compareTo(y) > 0 ? x : y;
}
```

### 8. 재귀적 타입 한정 (Recursive Type Bound)
- **자기 자신을 포함하는 타입 한정**
    - `<T extends Comparable<T>>`
- 타입 간의 자연스러운 순서를 정의할 때 사용

```java
public <T extends Comparable<T>> T max(List<T> list) {
    // 구현
}
```
> 타입 매개변수 한정시 super는 존재하지 않는다.
> super는 오직 와일드카드(?)와 함께 사용한다.
### 9. 한정적 와일드카드 타입 (Bounded Wildcard Type)
- **특정 타입이나 그 상위/하위 타입으로 제한된 와일드카드**
    - `List<? extends Number>`, `List<? super Integer>`
- 유연성이 필요한 메서드 파라미터를 정의할 때 사용

```java
public void addNumbers(List<? super Integer> list) {
    list.add(1);
    list.add(2);
}
```
> `? super Integer` 이므로 쓰기 가능

### 10. 제네릭 메서드 (Generic Method)
- **자체적인 타입 매개변수를 가진 메서드**
    -  `public <T> T[] toArray(T[] a)`
- 메서드 레벨에서 타입 안정성과 유연성이 필요할 때 사용

```java
public static <T> void swap(T[] array, int i, int j) {
    T temp = array[i];
    array[i] = array[j];
    array[j] = temp;
}
```

### 11. 타입 토큰 (Type Token)
- **런타임에 제네릭 타입 정보를 전달**하는 방법
    - `Class<T>`
- 리플렉션을 사용하거나 런타임에 타입 정보가 필요할 때

```java
public <T> List<T> convertToList(Class<T> targetType, Object[] array) {
    List<T> list = new ArrayList<>();
    for (Object obj : array) {
        list.add(targetType.cast(obj));
    }
    return list;
}
```


## `<T>` (제네릭 선언)
- 클래스나 메서드에서 제네릭을 사용하겠다고 선언할 때 쓴다.

### 1. `public class Box<T> { ... }`
-  **제네릭 클래스를 정의**하는 방법입
- 클래스 전체에 걸쳐 타입 파라미터 T를 사용할 수 있다.
- 클래스의 인스턴스를 생성할 때 구체적인 타입을 지정한다.
    -  `Box<String> stringBox = new Box<>();`

### 2. `public <T> void method(T t) { ... }`
-  **제네릭 메서드를 정의**하는 방법이다.
- **메서드 내에서만 타입 파라미터 T를 사용**할 수 있다.
- 메서드를 호출할 때마다 다른 타입을 사용할 수 있다.
- 클래스가 제네릭이 아니어도 메서드만 제네릭으로 만들 수 있다.

```java
// 제네릭 클래스
public class Box<T> {
    private T content;
    
    public void setContent(T content) {
        this.content = content;
    }
    
    public T getContent() {
        return content;
    }
}

// 제네릭 메서드를 포함한 일반 클래스
public class Utilities {
    public <T> void printArray(T[] array) {
        for (T element : array) {
            System.out.println(element);
        }
    }
}

// 사용 예
Box<String> stringBox = new Box<>();  // 클래스 인스턴스 생성 시 타입 지정
stringBox.setContent("Hello");

Utilities utils = new Utilities();
utils.printArray(new Integer[]{1, 2, 3});  // 메서드 호출 시 타입 추론
utils.printArray(new String[]{"a", "b", "c"});  // 같은 메서드, 다른 타입
```
