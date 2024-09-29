# 31. 한정적 와일드카드를 사용해 API 유연성을 높이라
- 매개변수화 타입은 불공변이다.
    - 서로 다른 Type1과 Type2가 있을 때 `List<Type1>`은 `List<Type2>`의 하위 타입도 상위 타입도 아니다.
    - `List<String>`은 `List<Object>`의 하위 타입이 아니다.
        - `List<Object>`에는 어떤 타입의 객체든 넣을 수 있지만, `List<String>`은 문자열만 넣을 수 있다.
        - 리스코프 치환 원칙에 어긋난다.


## 한정적 와일드카드를 사용하여 유연성을 높이자.
### 기존 코드
```java
// 코드 31-1 와일드카드 타입을 사용하지 않은 pushAll 메서드 - 결함이 있다! (181쪽)  
public void pushAll(Iterable<E> src) {  
    for (E e : src)  
        push(e);  
}

// 코드 31-3 와일드카드 타입을 사용하지 않은 popAll 메서드 - 결함이 있다! (183쪽)  
public void popAll(Collection<E> dst) {  
    while (!isEmpty())  
        dst.add(pop());  
}

// 제네릭 Stack을 사용하는 맛보기 프로그램  
public static void main(String[] args) {  
    Stack<Number> numberStack = new Stack<>();  
    Iterable<Integer> integers = Arrays.asList(3, 1, 4, 1, 5, 9);  
    numberStack.pushAll(integers); // 에러 발생
  
    Collection<Object> objects = new ArrayList<>();  
    numberStack.popAll(objects); // 에러 발생
  
    System.out.println(objects);  
}
```
- `Iterable<Number>`에 `Iterable<Integer>`를 대입할 수 없어 에러가 난다.
- `Collection<Number>`에 `Collection<Object>`를 대입할 수 없어 에러가 난다.

#### 수정된 코드
```java
 // 코드 31-2 E 생산자(producer) 매개변수에 와일드카드 타입 적용 (182쪽)  
public void pushAll(Iterable<? extends E> src) {  
    for (E e : src)  
        push(e);  
}

// 코드 31-4 E 소비자(consumer) 매개변수에 와일드카드 타입 적용 (183쪽)  
public void popAll(Collection<? super E> dst) {  
    while (!isEmpty())  
        dst.add(pop());  
}
```
- 생산자에 `extends` 키워드로 와일드카드 타입을 적용하면 에러가 발생하지 않는다.
- 소비자에 `super` 키워드로 와일드카드 타입을 적용하면 에러가 발생하지 않는다.
> 유연성을 극대화하려면 원소의 생산자와 소비자용 입력 매개변수에 와일드카드 타입을 사용하라

## 펙스(PECS) : producer-extends, consumer-super
- 매개변수화 타입 T가 생산자라면 `<? extends T>`를 사용한다.
    - pushAll의 src 매개변수는 Stack이 사용할 E 인스턴스를 사용하므로 생산자이다.
- 소비자라면 `<? super T>`를 사용한다.
    - popAll의 dst 매개변수는 Stack으로부터 E 인스턴스를 소비하므로 소비자이다.

### 예시 1
```java
// T 생산자 매개변수에 와일드카드 타입 적용 (184쪽)  
public class Chooser<T> {  
    private final List<T> choiceList;  
    private final Random rnd = new Random();  
  
    // 코드 31-5 T 생산자 매개변수에 와일드카드 타입 적용 (184쪽)  
    public Chooser(Collection<? extends T> choices) {  
        choiceList = new ArrayList<>(choices);  
    }  
  
    public T choose() {  
        return choiceList.get(rnd.nextInt(choiceList.size()));  
    }  
  
    public static void main(String[] args) {  
        List<Integer> intList = List.of(1, 2, 3, 4, 5, 6);  
        Chooser<Number> chooser = new Chooser<>(intList);  
        for (int i = 0; i < 10; i++) {  
            Number choice = chooser.choose();  
            System.out.println(choice);  
        }  
    }  
}
```
- 생산자로 넘겨지는 choices 컬렉션은 T 타입의 값을 생산하기만 하니 T를 확장하는 와일드카드 타입을 사용해 선언해야 한다.
    - `public Chooser(Collection<? extends T> choices) {`

### 예시 2
```java
// 코드 30-2의 제네릭 union 메서드에 와일드카드 타입을 적용해 유연성을 높였다. (185-186쪽)  
public class Union {  
    public static <E> Set<E> union(Set<? extends E> s1,  
                                   Set<? extends E> s2) {  
        Set<E> result = new HashSet<E>(s1);  
        result.addAll(s2);  
        return result;  
    }  
  
    // 향상된 유연성을 확인해주는 맛보기 프로그램 (185쪽)  
    public static void main(String[] args) {  
        Set<Integer> integers = new HashSet<>();  
        integers.add(1);   
        integers.add(3);   
        integers.add(5);   
  
        Set<Double> doubles =  new HashSet<>();  
        doubles.add(2.0);   
        doubles.add(4.0);   
        doubles.add(6.0);   
  
        Set<Number> numbers = union(integers, doubles);  
  
//      // 코드 31-6 자바 7까지는 명시적 타입 인수를 사용해야 한다. (186쪽)  
//      Set<Number> numbers = Union.<Number>union(integers, doubles);  
  
        System.out.println(numbers);  
    }  
}
```
- union에서 s1과 s2 모두 생산자이므로 `extends` 키워드를 사용한다
    - `public static <E> Set<E> union(Set<? extends E> s1,  Set<? extends E> s2) {`

#### 참고 ) 명시적 타입 인수
- java 7 이전에 사용되던 방식
- 제네릭 메서드를 호출할 때 타입을 명시적으로 지정하여 컴파일러에게 정확한 타입 정보를 제공한다.
```java
Set<Number> numbers = Union.<Number>union(integers, doubles);  
```
> java 7까지는 사용하기

#### 참고)  목표 타이핑
- java8 부터 도입된 향상된 타입 추론 기능이다.
- 컴파일러가 컨텍스트를 기반으로 타입을 추론한다.
```java
Set<Number> numbers = union(integers, doubles);  
```
- 컴파일러는 union의 결과값이 `Set<Number>`라고 추론한다.

### 예시 3
#### 기존 코드
```java
public static <E extends Comparable<E>> E max(List<E> list)
```

#### 개선 코드
```java
// 와일드카드 타입을 사용해 재귀적 타입 한정을 다듬었다. (187쪽)  
public class RecursiveTypeBound {  
    public static <E extends Comparable<? super E>> E max(  
        List<? extends E> list) {  
        if (list.isEmpty())  
            throw new IllegalArgumentException("빈 리스트");  
  
        E result = null;  
        for (E e : list)  
            if (result == null || e.compareTo(result) > 0)  
                result = e;  
  
        return result;  
    }  
  
    public static void main(String[] args) {  
        List<String> argList = Arrays.asList(args);  
        System.out.println(max(argList));  
    }  
}
```
- 입력 매개변수에서는 E 인스턴스를 생산(읽기)하므로 `extends` 키워드 사용
    - `max(  List<? extends E> list) {`
- 비교를 하며 `Comparable<E>`는 E 인스턴스를 소비(비교 연산의 인자로 소비)하여 선후 관계를 뜻하는 정수를 생산한다.
    - `Comparable<? super E>`
> 일반적으로 `Comparable<E>`보다는 `Comparator<? super E>`를 사용하는 편이 낫다.

- 개선된 코드는 Comparable을 직접 구현하지 않고, 직접 구현한 다른 타입을 확장한 타입을 지원할 수 있다.
```java
List<ScheduledFuture<?>> futures = ...;
ScheduledFuture<?> latestFuture = RecursiveTypeBound.max(futures);
```
관계
```
ScheduledFuture<?> -> Delayed -> Comparable<Delayed>
```
`ScheduledFuture<?>`는 `Comparable<ScheduledFuture<?>>`을 직접 구현하지 않았다.
대신 `Comparable<Delayed>`를 구현하는 `Delayed`를 `extends` 한다.

`Comparable<? super E>`는 `E`의 상위 타입에 대한 `Comparable` 구현도 허용한다.
그러므로 `ScheduledFuture<?>`의 경우, `Delayed`가 `Comparable<Delayed>`를 구현하므로 호환이 된다.

### 반환 타입에는 한정적 와일드카드 타입을 사용하면 안된다.
```java
public class WildcardLimitationsExample {
    public static void main(String[] args) {
        List<? extends Number> wildcardList = new ArrayList<Integer>();
        // wildcardList.add(1);  // 컴파일 에러
        // wildcardList.add(new Integer(1));  // 컴파일 에러
        Number n = wildcardList.get(0);  // 가능, 하지만 실제 타입은 알 수 없음

        // 이해를 위한 가상의 상황 (실제로는 컴파일되지 않음)
        List<? extends Number> mixedList = new ArrayList<Number>();
        // 만약 아래가 허용된다면 ??
        // mixedList.add(new Integer(1));  // Integer를 추가한다고 가정
        // mixedList.add(new Double(1.0));  // Double을 추가한다고 가정
        // Double d = (Double) mixedList.get(0);  // ClassCastException 발생 가능!
    }
}
```
- 클라이언트 코드에서도 와일드카드 타입을 써야한다.
    - 컴파일러는 어떤 타입인지 알 수 없어 와일드카드가 사용된 컬렉션에 요소를 추가하는 것을 금지한다.
    - 읽기 작업은 가능하지만 구체적인 타입 정보는 잃어버린다.
- 입력 매개변수가 생산자와 소비자 역할을 동시에 한다면 와일드카드 타입을 쓰지 말고 타입을 명확하게 지정하는 것이 좋다.
> 클래스 사용자가 와일드카드 타입을 신경써야 한다면 API에 문제가 있을 가능성이 크다.

#### 참고) 매개변수와 인수
- 매개변수 : 메서드 선언에 정의한 변수
- 인수: 메서드 호출시 넘기는 실제값

## 타입 매개변수와 와일드카드에는 공통되는 부분이 있어서, 둘 중 어느 것을 사용해도 괜찮을 때가 많다.
### public API에는 간단한 와일드카드가 낫다.
```java
public static <E> void swap(List<E> list, int i, int j);
public static void swap(List<?> list, int i, int j);
```
- 신경써야할 부분이 없기 때문이다.
- **메서드 선언에 타입 매개변수가 한번만 나오면 와일드 카드로 대체하라**
    - 비한정적 타입 매개변수라면 비한정적 와일드카드로 바꾼다
    - 한정적 타입 매개변수라면 한정적 와일드카드로 바꾸면 된다.


### `List<?>`에는 null 외에 어떤 값도 넣을 수 없다.
- 알 수 없는 타입의 리스트이므로, 컴파일러는 타입 안전성을 보장하기 위해 `null` 외의 어떤 객체도 추가할 수 없게 한다.
- `List<?>` 뿐 아니라 `Set<?>,` `Queue<?>`같은 모든 제네릭 타입에 적용된다.

#### **와일드카드** 타입의 실제 타입을 알려주는 `private 도우미 메서드`를 활용해야 한다.
- 실제 타입을 알아내려면 이 도우미 메서드는 제네릭 메서드여야 한다.
```java
// 와일드카드 타입을 실제 타입으로 바꿔주는 private 도우미 메서드 (189쪽)  
public class Swap {  
    public static void swap(List<?> list, int i, int j) {  
        swapHelper(list, i, j);  
    }  
  
    // 와일드카드 타입을 실제 타입으로 바꿔주는 private 도우미 메서드  
    private static <E> void swapHelper(List<E> list, int i, int j) {  
        list.set(i, list.set(j, list.get(i)));  
    }  
  
    public static void main(String[] args) {  
        // 첫 번째와 마지막 인수를 스왑한 후 결과 리스트를 출력한다.  
        List<String> argList = Arrays.asList(args);  
        swap(argList, 0, argList.size() - 1);  
        System.out.println(argList);  
    }  
}
```
- 내부적 (private 도우미 메서드)으로는 구체적인 타입 `E`를 사용해서 필요한 연산을 수행한다.
    - 이 리스트에서 꺼낸 값의 타입은 항상 `E`이고, `E` 타입의 값이라면 이 리스트에 넣어도 안전함을 알고 있다.
- 공개 API : `List<?>`를 사용해서 유연성을 제공한다.
    - `swap` 메서드를 호출하는 클라이언트는 `swapHelper`의 존재를 모른채 혜택을 누릴 수 있다.
> 와일드카드인 `?`를 이용하면 **해당 메서드가 특정 타입에 의존하지 않음을 더 명확하게 표현**할 수 있다.

## 결론
- 조금 복잡하더라도 `와일드카드` 타입을 적용하면 API가 훨씬 유연해진다.
    - 널리 쓰일 라이브러리를 작성한다면 와일드카드 타입을 적절하게 사용하는 것이 좋다.
- `PECS` 공식을 기억하자
    - 생산자는 `extends`를 소비자는 `super`를 사용한다.
    - `Comparable`과 `Comparator`는 모두 소비자라는 사실을 잊지 말자.

