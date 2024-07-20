# 6. 불필요한 객체 생성을 피하라.

- 똑같은 기능의 객체를 매번 사용하는 것보다 **객체 하나를 재사용하는 편이 나을때가 많다.**
- 재사용은 빠르고 세련된다.
    - 불변 객체는 언제든 재사용 가능하다.
```java
String s1 = new String("hi"); // 따라하지 말 것!
String s2 = "kim";
```
> 여기서 s1 문장을 실행할때마다 매번 String 인스턴스를 새로 만든다.
> s2 문장은 하나의 String 인스턴스를 사용하여 같은 가상 머신 안에서 이와 똑같은 문자열 리터럴을 사용하는 모든 코드가 같은 객체를 재사용함이 보장된다.

### 정적 팩터리 메서드를 사용해 불필요한 객체 생성을 피할 수 있다.
- 생성자는 호출할 때마다 새로운 객체를 만들지만, 팩터리 메서드는 전혀 그렇지 않다.
    - `Boolean.valueOf(String)`
  ```java
  public final class Boolean implements java.io.Serializable,
                                    Comparable<Boolean>
{
// 미리 TRUE, FALSE 만듬
public static final Boolean TRUE = new Boolean(true);
public static final Boolean FALSE = new Boolean(false);

    @HotSpotIntrinsicCandidate
    public static Boolean valueOf(boolean b) {
        return (b ? TRUE : FALSE);
    }

    @HotSpotIntrinsicCandidate
    public static Boolean valueOf(String s) {
        return parseBoolean(s) ? TRUE : FALSE;
    }

    public static boolean parseBoolean(String s) {
        return ((s != null) && s.equalsIgnoreCase("true"));
    }
}
```
- 가변 객체라 해도 사용 중에 변경되지 않음을 안다면 재사용할 수 있다.
```java
public class DateRange {
    private static final Map<Integer, DateRange> cache = new HashMap<>();
    
    private final int start;
    private int end;

    private DateRange(int start, int end) {
        this.start = start;
        this.end = end;
    }

    // 가변 메서드이지만, 팩토리 메서드에서는 사용되지 않음 (DataRange는 가변 객체이다)
    public void setEnd(int end) {
        this.end = end;
    }

    // 팩토리 메서드
    public static DateRange of(int start, int end) {
        int hashCode = start * 31 + end;
        return cache.computeIfAbsent(hashCode, k -> new DateRange(start, end));
    }

    @Override
    public String toString() {
        return "DateRange{start=" + start + ", end=" + end + "}";
    }

    public static void main(String[] args) {
        DateRange range1 = DateRange.of(1, 10);
        DateRange range2 = DateRange.of(1, 10); // 캐시에 존재한다면 같은 객체 반환

        System.out.println(range1 == range2);  // true
    }
}
```

### 생성 비용이 높을 경우 캐싱하여 재사용하자.
#### 기존 코드
```java
// 값비싼 객체를 재사용해 성능을 개선한다. (32쪽)  
public class RomanNumerals {  
    // 코드 6-1 성능을 훨씬 더 끌어올릴 수 있다!  
    static boolean isRomanNumeralSlow(String s) {  
        return s.matches("^(?=.)M*(C[MD]|D?C{0,3})"  
                + "(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");  
    }  
}
```
- String.matches()는 정규표현식으로 문자열 형태를 확인하는 가장 쉬운 방법이다.
- 하지만 성능이 중요한 상황에서 반복해서 사용하기에는 적합하지 않다.
    - 내부에서 만드는 정규표현식용 Pattern 인스턴스는 입력받은 정규표현식에 대한 유한 상태 머신을 만들기 때문에 인스턴스 생성 비용이 높다.
- 성능을 개선하려면 **Pattern 인스턴스를 한번만 생성하고(클래스 초기화 과정에서 생성해 캐싱) 재사용**하는 것이 좋다.
#### 개선 코드
```java
public class RomanNumerals {  
    // 코드 6-2 값비싼 객체를 재사용해 성능을 개선한다.  
    private static final Pattern ROMAN = Pattern.compile(  
            "^(?=.)M*(C[MD]|D?C{0,3})"  
                    + "(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");  
  
    static boolean isRomanNumeralFast(String s) {  
        return ROMAN.matcher(s).matches();  
    }  
  
    public static void main(String[] args) {  
        int numSets = Integer.parseInt(args[0]);  
        int numReps = Integer.parseInt(args[1]);  
        boolean b = false;  
  
        for (int i = 0; i < numSets; i++) {  
            long start = System.nanoTime();  
            for (int j = 0; j < numReps; j++) {  
                // 성능 차이를 확인하려면 xxxSlow 메서드를 xxxFast 메서드로 바꿔 실행해보자.  
                b ^= isRomanNumeralSlow("MCMLXXVI");  
            }  
            long end = System.nanoTime();  
            System.out.println(((end - start) / (1_000. * numReps)) + " μs.");  
        }  
  
        // VM이 최적화하지 못하게 막는 코드  
        if (!b)  
            System.out.println();  
    }  
}
```

- 성능을 훨씬 더 끌어올릴 수 있다.

#### 지연 초기화
```java
public class RomanNumerals {
    private static Pattern ROMAN = null;

    static boolean isRomanNumeralFast(String s) {
        if (ROMAN == null) {
            ROMAN = Pattern.compile("^(?=.)M*(C[MD]|D?C{0,3})"
                    + "(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$");
        }
        return ROMAN.matcher(s).matches();
    }
}
```
- isRomanNumeralFast()이 처음 호출될때 필드를 초기화하는 지연 초기화로 불필요한 초기화를 없앨 수도 있지만 추천하지 않는다.
- 지연 초기화는 코드를 복잡하게 만드는데 성능은 크게 개선되지 않을 때가 많기 때문이다.
    - 위 코드에서는 멀티 스레드 환경을 고려하여 추가적인 동기화 처리가 필요하다.
    - 애플리케이션 시작시 초기화와 첫 사용시 초기화하는 것의 성능 차이가 크지 않다.

### 객체가 불변이라면 재사용해도 안전하다.
```java
public final class ImmutablePoint {
    private final int x;
    private final int y;

    private static final ImmutablePoint ZERO = new ImmutablePoint(0, 0);

    private ImmutablePoint(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public static ImmutablePoint of(int x, int y) {
        return (x == 0 && y == 0) ? ZERO : new ImmutablePoint(x, y);
    }
}
```

- 하지만 덜 명확하고 직관에 반대되는 상황도 있다.
#### 어댑터
- 실제 작업은 뒷단 객체에 위임하고, 자신은 제 2의 인터페이스 역할은 해주는 객체이다.
```java
public class AdapterExample {
    private final Map<String, Integer> map = new HashMap<>();
    private Set<String> keySet;

    public Set<String> keySet() {
        if (keySet == null) {
            keySet = map.keySet();  // 어댑터
        }
        return keySet;
    }
}
```
- Enum의 keySet 메서드는 Map 객체 안의 키 전부를 담은 Set 뷰를 반환한다.
    - 반환된 Set 인스턴스가 일반적으로 가변이더라도 반환된 인스턴스들은 기능적으로 모두 똑같다.
    - 뷰를 여러개 만들 필요가 없다. 항상 같은 객체를 반환하므로 덜 직관적이다.

#### 오토박싱
- 오토박싱은 불필요한 객체를 만들어낼 수 있다.
- 오토박싱은 프로그래머가 기본 타입과 박싱된 기본 타입을 섞어 쓸 때 자동으로 상호 변환해주는 기술이다.
- 성능에 영향을 줄 수 있다.
```java
// 코드 6-3 끔찍이 느리다! 객체가 만들어지는 위치를 찾았는가? (34쪽)  
public class Sum {  
    private static long sum() {  
        Long sum = 0L;  
        for (long i = 0; i <= Integer.MAX_VALUE; i++)  
            sum += i;  
        return sum;  
    }  
  
    public static void main(String[] args) {  
        int numSets = Integer.parseInt(args[0]);  
        long x = 0;  
  
        for (int i = 0; i < numSets; i++) {  
            long start = System.nanoTime();  
            x += sum();  
            long end = System.nanoTime();  
            System.out.println((end - start) / 1_000_000. + " ms.");  
        }  
  
        // VM이 최적화하지 못하게 막는 코드  
        if (x == 42)  
            System.out.println();  
    }  
}
```
- 위 코드에서 sum에 i를 더할때마다 매번 Long 객체를 생성한다.
  **=> 박싱된 기본 타입보다는 기본 타입을 사용하고, 의도치 않은  오토박싱이 숨어들지 않도록 주의하자.**

### 무거운 객체가 아니라면 객체 생성을 피하고자 객체 풀을 만들지 말자.
- 데이터베이스 연결은 생성 비용이 바싸므로 객체 풀을 만드는 것이 낫다.
- 하지만 일반적으로 자체 객체 풀은 코드를 헷갈리게 만들고 메모리 사용량을 늘리고 성능을 떨어뜨린다.

#### 주의점
- 불필요한 객체 생성을 피하라는 말이 객체 생성은 비싸니 피해야한다와는 다르다.
- 요즘에 JVM에서는 작은 객체를 생성하고 회수하는 일이 크게 부담되지 않는다.
- 프로그램의 명확성, 간결성, 기능을 위해서 객체를 추가로 생성하는 것이라면 일반적으로 좋은 일이다.

### 결론
- 방어적 복사를 다루는 아이템 50과 대조적이다.
- 이번 아이템이 **기존 객체를 재사용해야한다면 새로운 객체를 만들지 마라**라면, 아이템 50은 **새로운 객체를 만들어야한다면 기존 객체를 재사용하지 마라**이다.
- **방어적 복사가 필요한 상황에서 객체를 재사용했을 때의 피해가 필요 없는 객체를 반복 생성했을 때의 피해보다 훨씬 크다.**
- 방어적 복사에 실패하면 언제 터져 나올지 모르는 버그와 보안 구멍으로 이어지지만, 불필요한 객체 생성은 그저 코드 형태와 성능에만 영향을 준다.

