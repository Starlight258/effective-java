## 요약

### 다중정의(오버로딩)한 메서드 vs 오버라이딩 메서드

```java
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


class SparklingWine extends Wine {
    @Override String name() { return "발포성 포도주"; }
}

// ... 하위타입 선언 

public class Overriding {
    public static void main(String[] args) {
        List<Wine> wineList = List.of(
                new Wine(), new SparklingWine(), new Champagne());

        for (Wine wine : wineList)
            System.out.println(wine.name());
    }
}
```
- 오버로딩 메서드의 호출은 컴파일타임에 정해진다
- 따라서 오버로딩 예제 코드에서는 for 문 안의 c가 항상 Collection<?> 이므로 항상 세 번쨰 메서드인 classify(Collection<?>)이 호출된다
- 오버라이딩 예제 코드에서는 런타임에 호출되는 메서드가 결정된다
- 오버라이딩한 메서드는 동적으로 호출, 오버로딩한 메서드는 정적으로 호출된다고 표현한다  
- 이 문제는 모든 classify 를 하나로 합친 후, 명시적으로 instanceof 를 사용하여 기대한 결과를 얻을 수 있다


### 다중정의가 혼동을 일으키는 상황을 피해라 
- 공개 API라면 사용자가 매개변수를 넘기면서 어떤 다중정의 메서드가 호출될지를 모른다면 프로그램이 오동작하기 쉽다
- 안전하고 보수적으로 가려면 매개변수 수가 같은 다중정의는 만들지 말자 (메서드 이름을 다르게 지어주는 걸 항상 고려)
    - ex) ObjectOutputStream 클래스는 write() 다중 정의 대신 writeBoolean(), writeInt() 등으로 타입별로 메서드 이름을 다르게 지어줬다

### 두 번째 생성자부터는 다중정의를 피할 수 없다 
- 정적 팩터리라는 대안을 고려
- 생성자는 재정의될 수 없으니 혼동될 걱정은 없다 
- 여러 생성자를 사용, 같은 수의 매개변수를 받아야하는 경우 안전 대책을 세워둬야 한다 
    - 매개 변수 중 하나 이상이 근본적으로 다르다면(형변환이 불가하다면) 매개변수들의 런타임 타입만으로 다중 정의 메서드가 결정되므로 괜찮음

### 다중정의 시 제네릭과 오토박싱을 고려
```java
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
- -3 부터 2까지 정수를 집합과 리스트에 추가하고 remove 를 똑같이 세 번 호출
- set.remove(i) 는 시그니쳐가 remove(Object) 이므로 기대한 대로 집합에서 0 이상의 수를 제거
- list.remove(i) 는 시그니쳐가 remove(int) 이고 지정한 인덱스의 원소 제거 
- 리스트의 경우 인수를 Integer 로 형변환하여 올바른 다중정의 메서드를 선택하게 해야 함 
- 리스트 인터페이스가 제네릭과 오토박싱에 의해 취약해진 예시 


### 람다, 메서드 참조와 다중정의
```java
// Thread 의 생성자호출
new Thread(System.out::println).start();


// ExecutorService 의 submit 메서드 호출
ExecutorService exec = Executors.newCachedThreadPool();
exec.submit(System.out::println);
```
- 1번과 2번이 모습은 비슷하지만, 2번만 컴파일 오류가 난다 
- `submit` 다중 정의 메서드 중 Callable<T>를 받는 메서드도 있기 때문
- `Callable`은 `println`이 void를 반환하니 반환값이 있는 `Callable`로 변환되지 않을 것이라 생각할 수 있으나, 다중 정의 해소(resolution) 는 이렇게 동작하지 않는다 
- 참조한 메서드와 호출한 메서드가 둘 다 다중정의되어 우리의 기대처럼 동작하지 않는 상황이다
- 기술적으로 말하면 System.out::println 은 부정확한 메서드 참조이다 
    - 목표 타입이 선택되기 전에는 그 의미가 정해지지 않는다
    - 적응성 테스트때 무시된다 
    - 핵심은 다중정의된 메서드들이 함수형 인터페이스를 인수로 받을 때, 서로 다른 함수형 인터페이스라도 인수 위치가 같으면 혼란이 생긴다는 것이다
    - 서로 다른 함수형 인터페이스라도 같은 위치의 인수로 받으면 안된다(근본적으로 다르지 않다)


### 근본적으로 다른 타입들
- Object 외의 클래스타입과 배열 타입은 근본적으로 다르다 
- Serializable 과 Cloneable 외의 인터페이스 타입과 배열 타입도 근본적으로 다르다 
- String, Throwable 처럼 상위/하위 관계가 아닌 두 클래스는 관련 없다고 표현하며 공통 조상을 가지지 않는다 

### 다중정의가 잘못된 사례
- `String` 의 `contentEquals(StringBuffer)` 가 있었는데  StringBuffer, StringBuilder, String, CharBuffer 등을 위한 공통 인터페이스 `CharSequence` 등장
- `String`도 `contentEquals(CharSequence)`가 추가되어 다중정의됨
- 다만, 같은 객체를 입력하면 완전히 같은 작업을 수행하므로 해롭지는 않음

```java
public boolean contentEquals(StringBuffer sb) {
    return contentEquals((CharSequence) sb);
}

// 상대적으로 더 특수한 다중 정의 메서드 -> 덜 특수한(더 일반적) 다중정의 메서드로 forward
```

 -`String` 의 `valueOf(char[])` 과 `valueOf(Object)` 는 같은 객체를 건네더라도 전혀 다른 일을 수행한다 

 ```java
 @Test
 public void test() {
    char[] chars = {'H', 'e', 'l', 'l', 'o'};
    String strFromChars = String.valueOf(chars); 

    Object obj = new char[] {'H', 'e', 'l', 'l', 'o'};
    String strFromObj = String.valueOf(obj);

    System.out.println(String.valueOf(str)); // Hello
    System.out.println(String.valueOf(obj)); //  
 }
 ```
