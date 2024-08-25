# 44. 표준 함수형 인터페이스를 사용하라
### 템플릿 메서드 대신 함수 객체를 받는 정적 팩터리나 생성자를 제공하자.
#### 템플릿 메서드 : 알고리즘의 구조를 정의하고, 일부 단계를 서브클래스에서 구현할 수 있도록 하는 방법
```java
abstract class Beverage {
    // 템플릿 메서드
    final void prepareBeverage() {
        boilWater();
        brew();
        pourInCup();
        if (customerWantsCondiments()) {
            addCondiments();
        }
    }

    void boilWater() {
        System.out.println("물을 끓입니다.");
    }

    void pourInCup() {
        System.out.println("컵에 따릅니다.");
    }

    abstract void brew();
    abstract void addCondiments();

    // 필요에 따라 오버라이드
    boolean customerWantsCondiments() {
        return true;
    }
}

class Coffee extends Beverage {
    @Override
    void brew() {
        System.out.println("필터로 커피를 우려냅니다.");
    }

    @Override
    void addCondiments() {
        System.out.println("설탕과 우유를 추가합니다.");
    }
}
```

> 람다를 사용하자

#### 함수 객체를 매개변수로 받는 생성자와 메서드
```java
class Beverage {
    private final Supplier<String> brewStep;
    private final Supplier<String> condimentsStep;
    private final Supplier<Boolean> wantsCondiments;

    private Beverage(Supplier<String> brewStep, Supplier<String> condimentsStep, Supplier<Boolean> wantsCondiments) {
        this.brewStep = brewStep;
        this.condimentsStep = condimentsStep;
        this.wantsCondiments = wantsCondiments;
    }

    public void prepareBeverage() {
        System.out.println("물을 끓입니다.");
        System.out.println(brewStep.get());
        System.out.println("컵에 따릅니다.");
        if (wantsCondiments.get()) {
            System.out.println(condimentsStep.get());
        }
    }

    // 정적 팩토리 메서드
    public static Beverage createBeverage(Supplier<String> brewStep, Supplier<String> condimentsStep, Supplier<Boolean> wantsCondiments) {
        return new Beverage(brewStep, condimentsStep, wantsCondiments);
    }
}

public class FunctionalBeverageExample {
    public static void main(String[] args) {
        // 커피 생성
        Beverage coffee = Beverage.createBeverage(
            () -> "필터로 커피를 우려냅니다.",
            () -> "설탕과 우유를 추가합니다.",
            () -> true
        );

        // 차 생성
        Beverage tea = Beverage.createBeverage(
            () -> "차를 우려냅니다.",
            () -> "레몬을 추가합니다.",
            () -> false
        );

        System.out.println("커피 만들기:");
        coffee.prepareBeverage();

        System.out.println("\n차 만들기:");
        tea.prepareBeverage();
    }
}
```

### LinkedHashMap
#### 메서드
```java
protected boolean removeEldestEntryMap(Map.Entry<K,V> eldest){
	return size() > 100;
}
```

#### 함수 객체를 매개변수로 받는 생성자와 메서드
- 팩터리나 생성자를 호출할때는 맵의 인스턴스가 존재하지 않으므로 size()와 같은 인스턴스 메서드를 호출할 수 없다.
    - 자기 자신도 함수 객체에 건네줘야한다.
```java
@FunctionalInterface interface EldestEntryRemovalFunction<K,V>{
	boolean remove(Map<K,V> map, Map.Entry<K,V> eldest);
}
```
- 현재 작업 중인 map과 가장 오래된 엔트리를 매개변수로 전달한다.
    - true이면 해당 엔트리를 제거한다.

## 표준 함수형 인터페이스
### 필요한 용도에 맞는게 있다면, 직접 구현하지 말고 표준 함수형 인터페이스를 활용하라
- API가 다루는 개념의 수가 줄어들어 익히기 더 쉽다.
- 표준 함수형 인터페이스들은 유용한 디폴트 메서드를 많이 제공한다.
    - `and()`, `or()`, `negate()`
- `EldestEntryRemovalFunction`를  표준 인터페이스인`BiPredicate`로 사용할 수 있다.
```java
public static BiPredicate<Map<String, Integer>, Map.Entry<String, Integer>> eldestEntryRemovalCondition = (map, eldest) -> map.size() > 100;
```

### 기본 인터페이스 6개
- 모두 참조타입용이다.
- `Operator` :  반환값과 인수의 타입이 같은 함수
    - `UnaryOperator`, `BinaryOperator`
- `Predicate` : 인수 하나를 받아 boolean을 반환하는 함수
- `Function` : 인수와 반환 타입이 다른 함수
- `Supplier` : 인수를 받지 않고 값을 반환하는 함수
- `Consumer` : 인수 하나 받고 반환값은 없는 함수

| 인터페이스            | 함수 시그니처               | 예시                                                   |
| ---------------- | --------------------- | ---------------------------------------------------- |
| Supplier<T>      | `T get()`             | `Supplier<String> s = () -> "Hello World";`          |
| Consumer<T>      | `void accept(T t)`    | `Consumer<String> c = (s) -> System.out.println(s);` |
| Function<T,R>    | `R apply(T t)`        | `Function<String, Integer> f = (s) -> s.length();`   |
| Predicate<T>     | `boolean test(T t)`   | `Predicate<String> p = (s) -> s.isEmpty();`          |
| UnaryOperator<T> | `T apply(T t)`        | `UnaryOperator<String> uo = (s) -> s.toUpperCase();` |
| BinaryOperator   | `T apply(T t1, T t2)` | `BigInteger::add`                                    |
### int, long, double 용으로 각 3개씩 변형이 일어난다.
- 기본 인터페이스 이름 앞에 해당 기본 타입 이름을 붙여 짓는다.
    - ex) `IntPredicate`, `LongBinaryOperator`..
- Function은 반환 타입을 매개변수화했다.
    - ex) `LongFunction<int[]>`

### 인수를 2개씩 받는 변형
- `BiPredicate<T,U>`
    - 기본 타입을 반환하는 변형 3개: `ToIntBiFunction<T,U>`, `ToLongBiFunction<T,U>`, `ToDoubleBiFunction<T,U>`
- `BiFunction<T,U>`
    - 입력과 결과 타입이 모두 기본 타입일 경우: `SrcToResult`
        - ex) `LongToIntFunction`
        - 총 6개
    - 입력이 객체 참조이고 결과가 int, long, double일 경우 : `ToResult`
        - ex) `ToLongFunction<int[]>`
- `BiConsumer<T,U>`
    - 기본 타입을 반환하는 변형 3개: `ObjIntConsumer<T>`, `ObjLongConsumer<T>`, `ObjDoubleConsumer<T>`

#### booleanSupplier 인터페이스
- `boolean`을 반환하는 변형

### 총 43개의 표준 함수형 인터페이스

| 인터페이스                  | 함수 디스크립터                  | 설명                         | 예시                                                                             |
| ---------------------- | ------------------------- | -------------------------- | ------------------------------------------------------------------------------ |
| `Runnable`             | () -> void                | 인자를 받지 않고 리턴값도 없는 작업 수행    | `Runnable r = () -> System.out.println("Hello");`                              |
| `Supplier<T>`          | () -> T                   | 인자 없이 T 타입 객체 반환           | `Supplier<String> s = () -> "Hello";`                                          |
| `Consumer<T>`          | T -> void                 | T 타입 인자를 받아 작업 수행          | `Consumer<String> c = s -> System.out.println(s);`                             |
| `BiConsumer<T,U>`      | (T,U) -> void             | 두 인자를 받아 작업 수행             | `BiConsumer<String,Integer> bc = (s,i) -> System.out.println(s+i);`            |
| `Function<T,R>`        | T -> R                    | T 타입 인자를 받아 R 타입 결과 반환     | `Function<String,Integer> f = s -> s.length();`                                |
| `BiFunction<T,U,R>`    | (T,U) -> R                | 두 인자를 받아 R 타입 결과 반환        | `BiFunction<String,String,Integer> bf = (s1,s2) -> s1.length() + s2.length();` |
| `UnaryOperator<T>`     | T -> T                    | T 타입 인자를 받아 같은 타입 반환       | `UnaryOperator<String> uo = s -> s.toUpperCase();`                             |
| `BinaryOperator<T>`    | (T,T) -> T                | 같은 타입의 인자 두 개를 받아 같은 타입 반환 | `BinaryOperator<Integer> bo = (i1,i2) -> i1 + i2;`                             |
| `Predicate<T>`         | T -> boolean              | T 타입 인자를 받아 boolean 반환     | `Predicate<String> p = s -> s.isEmpty();`                                      |
| `BiPredicate<T,U>`     | (T,U) -> boolean          | 두 인자를 받아 boolean 반환        | `BiPredicate<String,Integer> bp = (s,i) -> s.length() > i;`                    |
| `IntSupplier`          | () -> int                 | int 값 반환                   | `IntSupplier is = () -> (int)(Math.random() * 100);`                           |
| `LongSupplier`         | () -> long                | long 값 반환                  | `LongSupplier ls = () -> System.currentTimeMillis();`                          |
| `DoubleSupplier`       | () -> double              | double 값 반환                | `DoubleSupplier ds = () -> Math.PI;`                                           |
| `BooleanSupplier`      | () -> boolean             | boolean 값 반환               | `BooleanSupplier bs = () -> true;`                                             |
| `IntConsumer`          | int -> void               | int 값을 받아 작업 수행            | `IntConsumer ic = i -> System.out.println(i);`                                 |
| `LongConsumer`         | long -> void              | long 값을 받아 작업 수행           | `LongConsumer lc = l -> System.out.println(l);`                                |
| `DoubleConsumer`       | double -> void            | double 값을 받아 작업 수행         | `DoubleConsumer dc = d -> System.out.println(d);`                              |
| `IntFunction<R>`       | int -> R                  | int를 받아 R 타입 객체 반환         | `IntFunction<String> intf = i -> String.valueOf(i);`                           |
| `LongFunction<R>`      | long -> R                 | long을 받아 R 타입 객체 반환        | `LongFunction<String> longf = l -> String.valueOf(l);`                         |
| `DoubleFunction<R>`    | double -> R               | double을 받아 R 타입 객체 반환      | `DoubleFunction<String> doublef = d -> String.valueOf(d);`                     |
| `ToIntFunction<T>`     | T -> int                  | T 타입 인자를 받아 int 반환         | `ToIntFunction<String> tif = s -> s.length();`                                 |
| `ToLongFunction<T>`    | T -> long                 | T 타입 인자를 받아 long 반환        | `ToLongFunction<String> tlf = s -> s.length();`                                |
| `ToDoubleFunction<T>`  | T -> double               | T 타입 인자를 받아 double 반환      | `ToDoubleFunction<String> tdf = s -> Double.parseDouble(s);`                   |
| `IntToLongFunction`    | int -> long               | int를 받아 long 반환            | `IntToLongFunction itlf = i -> (long)i;`                                       |
| `IntToDoubleFunction`  | int -> double             | int를 받아 double 반환          | `IntToDoubleFunction itdf = i -> (double)i;`                                   |
| `LongToIntFunction`    | long -> int               | long을 받아 int 반환            | `LongToIntFunction ltif = l -> (int)l;`                                        |
| `LongToDoubleFunction` | long -> double            | long을 받아 double 반환         | `LongToDoubleFunction ltdf = l -> (double)l;`                                  |
| `DoubleToIntFunction`  | double -> int             | double을 받아 int 반환          | `DoubleToIntFunction dtif = d -> (int)d;`                                      |
| `DoubleToLongFunction` | double -> long            | double을 받아 long 반환         | `DoubleToLongFunction dtlf = d -> (long)d;`                                    |
| `IntUnaryOperator`     | int -> int                | int를 받아 int 반환             | `IntUnaryOperator iuo = i -> i * 2;`                                           |
| `LongUnaryOperator`    | long -> long              | long을 받아 long 반환           | `LongUnaryOperator luo = l -> l * 2;`                                          |
| `DoubleUnaryOperator`  | double -> double          | double을 받아 double 반환       | `DoubleUnaryOperator duo = d -> d * 2;`                                        |
| `IntBinaryOperator`    | (int,int) -> int          | int 두 개를 받아 int 반환         | `IntBinaryOperator ibo = (i1,i2) -> i1 + i2;`                                  |
| `LongBinaryOperator`   | (long,long) -> long       | long 두 개를 받아 long 반환       | `LongBinaryOperator lbo = (l1,l2) -> l1 + l2;`                                 |
| `DoubleBinaryOperator` | (double,double) -> double | double 두 개를 받아 double 반환   | `DoubleBinaryOperator dbo = (d1,d2) -> d1 + d2;`                               |
| `IntPredicate`         | int -> boolean            | int를 받아 boolean 반환         | `IntPredicate ip = i -> i > 0;`                                                |
| `LongPredicate`        | long -> boolean           | long을 받아 boolean 반환        | `LongPredicate lp = l -> l > 0;`                                               |
| `DoublePredicate`      | double -> boolean         | double을 받아 boolean 반환      | `DoublePredicate dp = d -> d > 0;`                                             |
| `ObjIntConsumer<T>`    | (T,int) -> void           | T 타입과 int를 받아 작업 수행        | `ObjIntConsumer<String> oic = (s,i) -> System.out.println(s+i);`               |
| `ObjLongConsumer<T>`   | (T,long) -> void          | T 타입과 long을 받아 작업 수행       | `ObjLongConsumer<String> olc = (s,l) -> System.out.println(s+l);`              |
| `ObjDoubleConsumer<T>` | (T,double) -> void        | T 타입과 double을 받아 작업 수행     | `ObjDoubleConsumer<String> odc = (s,d) -> System.out.println(s+d);`            |

### 표준 함수형 인터페이스 대부분은 기본 타입만 지원한다.
- 기본 함수형 인터페이스에 박싱된 기본 타입을 넣어 사용하지는 말자
    - 박싱된 기본 타입 대신 기본 타입을 사용하라
    - 계산량이 많을 때는 성능이 처참히 느려질 수 있다.

## 코드를 직접 작성해야할 경우
- 표준 인터페이스 중 필요한 용도에 맞는게 없다면 직접 작성해야한다.

### 표준 인터페이스가 지원하더라도 독자적인 인터페이스로 남아야하는 경우가 있다.
- `ex) Comparator<T>`는 `ToIntBiFunction<T,U>` 가 존재하더라도 직접 인터페이스를 구현하는 것이 좋은 선택이다.
- 1. 이름이 그 용도를 아주 훌륭히 설명해준다.
- 2. 구현하는 쪽에서 반드시 지켜야 할 규약을 담고 있다.
- 3. 비교자들을 변환하고 조합해주는 유용한 디폴트 메서드를 담고 있다.

#### 전용 함수형 인터페이스를 구현해야하는 경우
- 자주 쓰이며, 이름 자체가 용도를 명확히 설명해준다.
- 반드시 따라야 하는 규약이 있다.
- 유용한 디폴트 메서드를 제공할 수 있다.

## @FunctionalInterface
- 프로그래머의 의도를 명시하기 위한 것이다.
- 1. 해당 클래스의 코드나 설명 문서를 읽을 이에게 인터페이스가 람다용으로 설계된 것임을 알려준다.
- 2. 해당 인터페이스가 추상 메서드를 오직 하나만 가지고 있어야 컴파일되게 해준다.
- 3. 유지보수 과정에서 실수로 메서드를 추가되지 못하게 막아준다.
> 직접 만든 함수형 인터페이스에는 항상 @FunctionalInterface 애너테이션을 사용하라

## 함수형 인터페이스 주의점
### 서로 다른 함수형 인터페이스를 같은 위치의 인수로 받는 메서드를 다중 정의해서는 안된다.
- 모호함으로 인해 문제가 발생할 수 있다.
    - 어떤 타입인지 알려주기 위해 형변환해야할 때가 생긴다.
> 서로 다른 함수형 인터페이스를 같은 위치의 인수로 사용하는 다중정의를 피하라


## 결론
- 자바도 람다를 지원한다.
    - api 설계시 람다를 염두해두자.
- **입력값과 반환값에 함수형 인터페이스 타입을 활용하라**
    - `java.util.function` 패키지의 표준 함수형 인터페이스를 사용하는 것이 가장 좋은 선택이다.
- 흔치는 않지만 직접 새로운 함수형 인터페이스를 만들어 쓰는 편이 나을수도 있다.
