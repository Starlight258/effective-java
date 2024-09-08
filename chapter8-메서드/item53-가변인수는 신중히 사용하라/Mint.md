# 53. 가변인수는 신중히 사용하라
## 가변인수(varargs)
- 명시한 타입의 인수를 0개 이상 받을 수 있다.
- 가변인수 메서드를 호출하면, **가장 먼저 인수의 개수와 길이가 같은 배열**을 만들고, **인수들을 이 배열에 저장하여 가변인수 메서드에 건네준다**.

### 가변 인수 활용 예
```java
// 가변인수 활용 예 (320-321쪽)  
public class Varargs {  
    // 코드 53-1 간단한 가변인수 활용 예 (320쪽)  
    static int sum(int... args) {  
        int sum = 0;  
        for (int arg : args)  
            sum += arg;  
        return sum;  
    }
```

### 인수가 1개 이상이어야할 경우
- 인수를 0개만 받을 수도 있게 만드는 것은 좋지 않다.
```java
// 코드 53-2 인수가 1개 이상이어야 하는 가변인수 메서드 - 잘못 구현한 예! (320쪽)  
static int min(int... args) {  
    if (args.length == 0)  
        throw new IllegalArgumentException("인수가 1개 이상 필요합니다.");  
    int min = args[0];  
    for (int i = 1; i < args.length; i++)  
        if (args[i] < min)  
            min = args[i];  
    return min;  
}
```
> 인수를 0개만 넣어 호출하면 런타임에 실패한다.

- 매개변수를 2개 받도록 하면 된다.
```java
// 가변인수 활용 예 (320-321쪽)  
public class Varargs {
    // 코드 53-3 인수가 1개 이상이어야 할 때 가변인수를 제대로 사용하는 방법 (321쪽)  
    static int min(int firstArg, int... remainingArgs) {  
        int min = firstArg;  
        for (int arg : remainingArgs)  
            if (arg < min)  
                min = arg;  
        return min;  
    }  
  
    public static void main(String[] args) {  
        System.out.println(sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10));  
        System.out.println(min(1, 2, 3, 4, 5, 6, 7, 8, 9, 10));  
    }  
}
```


### 성능에 민감한 상황이라면 가변인수가 걸림돌이 될 수 있다.
- 가변 인수 메서드는 호출할 때마다 배열을 새로 하나 할당하고 초기화한다.

#### 가변인수의 유연성을 감당할 수 있는 패턴
- 메서드 호출의 95%가 인수를 3개 이하로 사용할 경우
```java
public void foo() {}
public void foo(int a1) {}
public void foo(int a1, int a2) {}
public void foo(int a1, int a2, int a3) {}
public void foo (int a1, int a2, int a3, int... rest) {}
```
> 마지막 다중정의 메서드가 인수 4개 이상인 5%의 호출을 담당한다.
> 인수 4개 이상일때만 배열을 생성한다.

- `EnumSet`의 정적 팩터리도 이 기법을 이용해 열거 타입 집합 생성 비용을 최소화한다.
    - 가변 인수를 사용하는 메서드(`of(E first, E... rest)`)는 열거 타입 요소가 6개 이상일 때만 사용된다.
```java
public static <E extends Enum<E>> EnumSet<E> noneOf(Class<E> elementType) { ... }
public static <E extends Enum<E>> EnumSet<E> of(E e) { ... }
public static <E extends Enum<E>> EnumSet<E> of(E e1, E e2) { ... }
public static <E extends Enum<E>> EnumSet<E> of(E e1, E e2, E e3) { ... }
public static <E extends Enum<E>> EnumSet<E> of(E e1, E e2, E e3, E e4) { ... }
public static <E extends Enum<E>> EnumSet<E> of(E e1, E e2, E e3, E e4, E e5) { ... }
public static <E extends Enum<E>> EnumSet<E> of(E first, E... rest) { ... }
```
- 비트 필드를 대체하면서 성능까지 유지해야하므로 아주 적절하게 활용한 예시이다.
    - 열거 타입 요소가 64개 이하일 경우, `EnumSet`은 내부적으로 단일 `long` 값을 사용하여 비트 벡터로 구현된다.
```java
enum Day { MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY }
// 1개 요소
EnumSet<Day> weekend1 = EnumSet.of(Day.SATURDAY);
// 2개 요소
EnumSet<Day> weekend2 = EnumSet.of(Day.SATURDAY, Day.SUNDAY);
// 3개 이상의 요소
EnumSet<Day> workdays = EnumSet.of(Day.MONDAY, Day.TUESDAY, Day.WEDNESDAY, Day.THURSDAY, Day.FRIDAY);
```

# 결론
- 인수 개수가 일정하지 않은 메서드를 정의해야한다면 `가변인수`가 반드시 필요하다.
- 메서드를 정의할 때 **필수 매개변수는 가변인수 앞**에 두고, **가변인수를 사용할 때는 성능 문제까지 고려**하자.
