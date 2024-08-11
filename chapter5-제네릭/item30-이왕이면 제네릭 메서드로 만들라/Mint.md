# 30. 이왕이면 제네릭 메서드로 만들라
## 제네릭 메서드 만들기
- 매개변수화 타입을 받는 정적 유틸리티 메서드는 보통 제네릭이다.
    - Collections의 알고리즘 메서드(binarySearch, sort 등)은 모두 제네릭이다.

### 기존 코드
```java
public class Union {  
    public static Set union(Set s1, Set s2) {  
        Set<E> result = new HashSet<>(s1);  
        result.addAll(s2);  
        return result;  
    }  
}
```
로 타입을 사용하여 타입 정보를 알 수 없어 안전하지 않다.

### 제네릭을 이용해 타입 안전하게 만들기
- 메서드 선언에서 입력, 출력의 원소 타입을 **타입 매개변수로 명시**한다.
- 메서드 안에서도 이 타입 매개변수만 사용하게 수정한다.
- 타입 매개변수들을 선언하는 타입 매개변수 목록은 메서드의 제한자와 반환 타입 사이에 온다.
```java
// 제네릭 union 메서드와 테스트 프로그램 (177쪽)  
public class Union {  
  
    // 코드 30-2 제네릭 메서드 (177쪽)  
    public static <E> Set<E> union(Set<E> s1, Set<E> s2) {  
        Set<E> result = new HashSet<>(s1);  
        result.addAll(s2);  
        return result;  
    }  
  
    // 코드 30-3 제네릭 메서드를 활용하는 간단한 프로그램 (177쪽)  
    public static void main(String[] args) {  
        Set<String> guys = Set.of("톰", "딕", "해리");  
        Set<String> stooges = Set.of("래리", "모에", "컬리");  
        Set<String> aflCio = union(guys, stooges);  
        System.out.println(aflCio);  
    }  
}
```
경고 없이 컴파일되며, 타입 안전하고, 쓰기도 쉽다.

#### 한정적 와일드카드 타입을 사용하여 더 유연하게 개선할 수 있다.
```java
public class Union {
    public static <E> Set<E> union(Set<? extends E> s1, Set<? extends E> s2) {
        Set<E> result = new HashSet<E>();
        result.addAll(s1);
        result.addAll(s2);
        return result;
    }

    public static void main(String[] args) {
        Set<Integer> ints = Set.of(1, 3, 5);
        Set<Double> doubles = Set.of(2.0, 4.0, 6.0);
        Set<Number> numbers = Union.<Number>union(ints, doubles);
        System.out.println(numbers);

        Set<String> guys = Set.of("톰", "딕", "해리");
        Set<String> stooges = Set.of("래리", "모에", "컬리");
        Set<String> aflCio = union(guys, stooges);
        System.out.println(aflCio);
    }
}
```
이렇게 작성하면 `Set<Integer>`와 `Set<Double>`을 union할 수 있어 더 유연하다.
> union메서드는 Integer와 Double을 합치는 것이다보니 컴파일러에서 정확한 타입을 추론할 수 없을 수도 있다.
> `Union.union`보다 Number를 명시적으로 지정함으로써 union의 결과가 Number임을 알려준다.

### 제네릭 싱글턴 팩터리
- 불변 객체를 여러 타입으로 활용할 수 있게 만들어야 할 때가 있다.
- **제네릭은 런타임에 타입 정보가 소거**되므로 **하나의 객체를 어떤 타입으로든 매개변수화**할 수 있다.
- **요청한 타입 매개변수에 맞게 매번 그 객체의 타입을 바꿔주는 정적 팩터리**를 만들어야한다.
    - ex) `Collections.reverseOrder` 나 `Collections.emptySet`과 같은 컬렉션 용으로 사용한다.
> 제네릭 싱글턴 팩토리 :단 하나의 인스턴스를 다양한 타입으로 사용, 객체 생성 캡슐화

#### 예시 : 항등 함수
- **항등 함수** : 입력 값을 수정 없이 그대로 반환하는 함수
    - 상태가 없으니 요청할 때마다 매번 생성하는 것은 낭비이다.
    - 제네릭은 소거 방식을 사용하므로 제네릭 싱글턴 하나이면 충분하다.
> 제네릭은 런타임에 모든 제네릭 타입 정보가 사라지므로 타입 검사하지 않고, 실제로는 하나의 Object만 있어도 다양한 제네릭 타입으로 사용할 수 있다.
```java
// 제네릭 싱글턴 팩터리 패턴 (178쪽)  
public class GenericSingletonFactory {  
    // 코드 30-4 제네릭 싱글턴 팩터리 패턴 (178쪽)  
    private static UnaryOperator<Object> IDENTITY_FN = (t) -> t;  
  
    @SuppressWarnings("unchecked")  
    public static <T> UnaryOperator<T> identityFunction() {  
        return (UnaryOperator<T>) IDENTITY_FN;  
    }  
  
    // 코드 30-5 제네릭 싱글턴을 사용하는 예 (178쪽)  
    public static void main(String[] args) {  
        String[] strings = { "삼베", "대마", "나일론" };  
        UnaryOperator<String> sameString = identityFunction();  
        for (String s : strings)  
            System.out.println(sameString.apply(s));  
  
        Number[] numbers = { 1, 2.0, 3L };  
        UnaryOperator<Number> sameNumber = identityFunction();  
        for (Number n : numbers)  
            System.out.println(sameNumber.apply(n));  

		UnaryOperator<String> strOp1 = genericSingletonFactory();
        UnaryOperator<Integer> intOp1 = genericSingletonFactory();
        System.out.println("Generic Singleton Factory:");
        System.out.println("Same object: " + (strOp1 == intOp1));  // true
    }  
}
```
`IDENTITY_FN`을 형변환하는 과정에서 경고가 발생할 수 있지만, 동일한 `IDENTITY_FN` 객체를 요청한 타입에 맞추므로 타입 안전하다.

### 재귀적 타입 한정
- 자기 자신이 들어간 표현식을 사용하여 타입 매개변수의 허용 범위를 한정한다.
- 주로 타입의 자연적 순서를 정하는 `Comparable` 인터페이스와 함께 쓰인다.

#### 재귀적 타입 한정을 이용해 상호 비교할 수 있음을 표현한다.
-  `<E extends Comparable<E>>`
    - E는 어떤 타입이든 될 수 있지만, `Comparable<E>` 인터페이스를 구현해야 한다.
    - 즉, E 타입의 객체는 자기 자신과 비교할 수 있어야 한다.
```java
public class RecursiveTypeBound {
    // Optional<E>를 반환하도록 수정된 max 메서드
    public static <E extends Comparable<E>> Optional<E> max(Collection<E> c) {
        if (c.isEmpty()) {
            return Optional.empty();
        }

        E result = null;
        for (E e : c) {
            if (result == null || e.compareTo(result) > 0) {
                result = Objects.requireNonNull(e);
            }
        }

        return Optional.of(result);
    }

    public static void main(String[] args) {
        List<String> argList = Arrays.asList(args);
        Optional<String> maxString = max(argList);
        
        maxString.ifPresentOrElse(
            max -> System.out.println("최대값: " + max),
            () -> System.out.println("컬렉션이 비어 있습니다.")
        );

        // 빈 리스트 테스트
        List<Integer> emptyList = new ArrayList<>();
        Optional<Integer> maxInt = max(emptyList);
        
        maxInt.ifPresentOrElse(
            max -> System.out.println("최대값: " + max),
            () -> System.out.println("컬렉션이 비어 있습니다.")
        );
    }
}
```


## 결론
- 클라이언트에서 입력 매개변수와 반환값을 **명시적으로 형변환해야하는 메서드보다 제네릭 메서드가 더 안전하며 사용하기 쉽다.**
- 제네릭 타입과 마찬가지로, 메서도 형변환 없이 사용할 수 있는 편이 좋으며, 많은 경우 그렇게 하려면 제네릭 메서드가 되어야 한다.
- **타입과 마찬가지로, 형변환을 해줘야 하는 기존 메서드는 제네릭하게 만들자.**

