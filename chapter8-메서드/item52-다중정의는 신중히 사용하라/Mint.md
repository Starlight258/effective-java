# 52. 다중정의는 신중히 사용하라
## 다중정의(overloading)
### 다중정의(오버로딩)은 어느 메서드를 호출할지 컴파일 타임에 정해진다.
```java
// 코드 52-1 컬렉션 분류기 - 오류! 이 프로그램은 무엇을 출력할까? (312쪽)  
public class CollectionClassifier {  
    public static String classify(Set<?> s) {  
        return "집합";  
    }  
  
    public static String classify(List<?> lst) {  
        return "리스트";  
    }  
  
    public static String classify(Collection<?> c) {  
        return "그 외";  
    }  
  
    public static void main(String[] args) {  
        Collection<?>[] collections = {  
                new HashSet<String>(),  
                new ArrayList<BigInteger>(),  
                new HashMap<String, String>().values()  
        };  
  
        for (Collection<?> c : collections)  
            System.out.println(classify(c));  
    }  
}
```
출력
```
그 외
그 외
그 외
```
- 다중정의(오버로딩)한 메서드는 **정적으로 선택**된다.
    - 컴파일 타임에, 오직 매개변수의 컴파일타임 타입에 의해 이뤄진다.

#### 반면에 재정의(오버라이딩)한 메서드는 동적으로 선택된다.
- 하위 클래스의 인스턴스에서 해당 메서드를 호출하면 재정의한 메서드가 실행된다.
```java
// 재정의된 메서드 호출 메커니즘 (313쪽, 코드 52-2의 일부)  
class Wine {  
    String name() { return "포도주"; }  
}

// 재정의된 메서드 호출 메커니즘 (313쪽, 코드 52-2의 일부)  
class SparklingWine extends Wine {  
    @Override String name() { return "발포성 포도주"; }  
}
  
// 재정의된 메서드 호출 메커니즘 (313쪽, 코드 52-2의 일부)  
class Champagne extends SparklingWine {  
    @Override String name() { return "샴페인"; }  
}

// 재정의된 메서드 호출 메커니즘 (313쪽, 코드 52-2의 일부)  
public class Overriding {  
    public static void main(String[] args) {  
        List<Wine> wineList = List.of(  
                new Wine(), new SparklingWine(), new Champagne());  
  
        for (Wine wine : wineList)  
            System.out.println(wine.name());  
    }  
}
```
출력
```
포도주
샴페인
발포성 포도주
```

#### 오버로딩 수정한 버전
```java
// 수정된 컬렉션 분류기 (314쪽)  
public class FixedCollectionClassifier {  
    public static String classify(Collection<?> c) {  
        return c instanceof Set  ? "집합" :  
                c instanceof List ? "리스트" : "그 외";  
    }  
  
    public static void main(String[] args) {  
        Collection<?>[] collections = {  
                new HashSet<String>(),  
                new ArrayList<BigInteger>(),  
                new HashMap<String, String>().values()  
        };  
  
        for (Collection<?> c : collections)  
            System.out.println(classify(c));  
    }  
}
```

### 안전하고 보수적으로 가려면 매개변수 수가 같은 다중정의는 만들지 말자
- 프로그래머에게는 다중정의가 예외적인 동작처럼 보이므로, 다중정의를 통해 혼동을 일으키는 상황을 피해야한다.
- 다중정의하는 대신 **메서드 이름을 다르게 지어주는 길**도 열려있다.
    - ex) writeBoolean, writeInt, writeLong ..
- 생성자는 이름을 다르게 지을 수 없으니 정적 팩터리를 이용할 수 있다.

### 매개변수 수가 같은 다중정의 메서드가 많더라고, 매개변수 집합이 명확하게 구분된다면 헷갈리지 않을 것이다.
- 매개변수 중 하나이상이 근본적으로 다르다면 헷갈리지 않을 것이다.
    - 두 타입의 값을 형변환할 수 없는 상황을 말한다.
    - ex) int를 받는 생성자 vs Collection을 받는 생성자

#### 제네릭과 오토박싱이 등장하면서 기본 타입과 참조 타입이 달라지지 않게 되었다.
```java
// 이 프로그램은 무엇을 출력할까? (315-316쪽)  
public class SetList {  
    public static void main(String[] args) {  
        Set<Integer> set = new TreeSet<>();  
        List<Integer> list = new ArrayList<>();  
  
        for (int i = -3; i < 3; i++) {  
            set.add(i);  
            list.add(i);  
        }  
        for (int i = 0; i < 3; i++) {  
            set.remove(i);  
            list.remove(i);  
        }  
        System.out.println(set + " " + list);  
    }  
}
```
출력
- `set.remove(Object)`는 해당 객체를 제거한다.
- `list.remove(Object)`는 해당 객체를 제거한다.
- `list.remove(int index)`는 해당 위치의 객체를 제거한다.

- java 5 이전
    - 제네릭 도입 전인 `java 4`까지는 `Object`와 `int`가 근본적으로 달라서 문제가 없었다.
```
[-3, -2, -1]
[-3, -2, -1]
```

- java 5 이후
- **제네릭과  오토박싱이 등장하면서 더는 기본 타입과 참조 타입이 근본적으로 다르지 않게 되었다.**
    - `int`가 자동으로 `Integer` 객체로 변환된다. (`Integer`도 `int`로 언박싱이 된다)
```
[-3, -2, -1]
[-2, 0, 2]
```
- `list.remove`의 인수를 `Integer`로 형변환하여 `remove(Object)`가 호출되도록 하면 된다.
    - `list.remove((Integer) i)`

### 람다와 메서드 참조도 다중 정의시의 혼란을 키웠다
- `new Thread(System.out::println).start()`
    - `System.out::println`은 `Runnable`로 해석된다.
- `ExecutorService exec = Executors.newCachedThreadPool(); exec.submit(System.out::println)`
    - 컴파일 에러
    - `ExecutorService.submit()` 메서드는 여러 오버로딩된 버전이 있다
        - `submit(Runnable)`
        - `submit(Callable<T>)`
    - `System.out::println`은 `Runnable`과 `Callable<Void>` 모두와 호환될 수 있어 모호하다

#### 메서드를 다중정의할 때, 서로 다른 함수형 인터페이스라도 같은 위치의 인수로 받아서는 안된다.
- 서로 다른 함수형 인터페이스라도 인수 위치가 같으면 혼란이 생긴다.
    - 서로 다른 함수형 인터페이스라도 서로 근본적으로 다르지 않다.
- 함수형 인터페이스들은 결국 '함수'라는 개념을 표현하는 것이므로, 서로 근본적으로 크게 다르지 않다.
    - 유사성으로 인해 오버로딩 시 혼란이 발생할 수 있다.

### 어떤 다중정의 메서드가 불리는지 몰라도 기능이 똑같다면 신경쓸 필요 없다.
- **상대적으로 더 특수한 다중정의 메서드**에서 **덜 특수한(일반적인) 다중정의 메서드**로 일을 넘기면 된다.
```java
public boolean contentEquals(StringBuffer sb){
	return contentEquals((CharSequence) sb);
}
```

# 결론
- 일반적으로 **매개변수 수가 같을 때는 다중정의를 피하는게 좋다.**
- 피할 수 없을 경우 **헷갈릴 만한 매개변수는 형변환하여 정확한 다중정의 메서드가 선택**되도록 해야한다.
- **같은 객체를 입력받는 다중 정의 메서드들이 모두 동일하게 동작**하도록 만들어야한다.


