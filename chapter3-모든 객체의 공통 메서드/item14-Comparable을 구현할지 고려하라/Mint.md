# 14. Comparable을 구현할지 고려하자.

## Comparable

- compareTo는 Object의 메서드가 아니다.
- compareTo는 단순 동치성 비교에 더해 순서까지 비교할 수 있으며, 제네릭하다.
    - **자연적인 순서**를 정할 수 있다.
    - 배열이라면 Arrays.sort()를 이용해 손쉽게 정렬할 수 있다.
    - 검색, 극단값 계산, 자동 정렬되는 컬렉션 관리도 쉽게 할 수 있다.
- 사실상 자바 플랫폼 라이브러리의 모든 값 클래스와 열거 타입이 Comparable을 구현했다.
    - 정렬된 컬렉션인 TreeSet과 TreeMap, 검색과 정렬 알고리즘을 사용하는 유틸리티 클래스인 Collections와 Arrays
    - **알파벳, 숫자, 연대 같이 순서가 명확한 값 클래스를 작성한다면 반드시 Comparable 인터페이스를 구현하자.**

```java
public interface Comparable<T> {
    int compareTo(T t);
}
```

## compareTo 메서드의 일반 규약

- 이 객체와 주어진 객체의 순서를 비교한다.
    - 주어진 객체보다 작으면 음의 정수를, 같으면 0을, 크면 양의 정수를 반환한다.
    - 객체와 비교할 수 없는 타입의 객체가 주어지면 **ClassCastException**을 던진다.

1. **대칭성** : sgn(x.compareTo(y)) == -sgn(y.compareTo(x))
    - 두 객체 참조의 순서를 바꿔 비교해도 예상한 결과가 나와야 한다.
2. **추이성** : (x.compareTo(y) >0 && y.compareTo(z) >0)이면 x.compareTo(z) >0이다.
    - 첫번째가 두번째보다 크고 두번째가 세번째보다 크면, 첫번째는 세번째보다 커야한다.
3. **반사성** : x.compateTo(y)=\=0 이면 (x.compateTo(z)=\=0) == (y.compateTo(z)=\=0)다.
    - 크기가 같은 객체들끼리는 어떤 객체와 비교하더라도 항상 같아야한다.
4. 필수는 아니지만 꼭 지키는 것이 좋다 : x.compateTo(y)=\=0 이면 (x.equals(y))여야한다.
    - **compareTo 메서드로 수행한 동치성 테스트의 결과가 equals와 같아야 한다.**
        - compareTo로 줄지은 순서와 equals의 결과가 일관되게 한다.
        - **정렬된 컬렉션은 동치성을 비교할때 compareTo를 사용**하기 때문이다.

### 상속대신 컴포지션을 사용하자.

- Comparable을 구현한 클래스를 확장해 값 컴포넌트를 추가하고 싶다면, 확장하는 대신 독립된 클래스를 만들자.
- 이 클래스에 원래 클래스의 인스턴스를 가리키는 필드를 두자.
- 내부 인스턴스를 반환하는 뷰 메서드를 제공하면 된다.
- 예시
    - 상위 클래스

```java
public class Point implements Comparable<Point> {
    final int x, y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    @Override
    public int compareTo(Point p) {
        int result = Integer.compare(x, p.x);
        if (result == 0) {
            result = Integer.compare(y, p.y);
        }
        return result;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Point))
            return false;
        Point p = (Point) o;
        return x == p.x && y == p.y;
    }

    @Override
    public int hashCode() {
        return 31 * x + y;
    }

    @Override
    public String toString() {
        return "(" + x + ", " + y + ")";
    }
}
```

- 하위 클래스

```java
public class ColorPoint implements Comparable<ColorPoint> {
    private final Point point;
    private final Color color;

    public ColorPoint(int x, int y, Color color) {
        point = new Point(x, y);
        this.color = Objects.requireNonNull(color);
    }

    // 뷰 메서드
    public Point asPoint() {
        return point;
    }

    @Override
    public int compareTo(ColorPoint cp) {
        int result = point.compareTo(cp.point);
        if (result == 0) {
            result = color.compareTo(cp.color);
        }
        return result;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ColorPoint))
            return false;
        ColorPoint cp = (ColorPoint) o;
        return cp.point.equals(point) && cp.color.equals(color);
    }

    @Override
    public int hashCode() {
        return 31 * point.hashCode() + color.hashCode();
    }

    @Override
    public String toString() {
        return point + " in " + color;
    }
}
```

> equals와 방법이 같다.
> 반사성, 대칭성, 추이성을 모두 충족한다.

### Comparable은 제네릭 인터페이스이다.

- compareTo 메서드의 인수 타입은 컴파일타임에 정해진다.
- 입력 인수의 타입을 확인하거나 형변환할 필요가 없다.
- null을 인수로 넣어 호출하면 NPE를 던지면 된다.

### compareTo는 필드의 동치가 아닌 순서를 비교한다.

```java
// 자바가 제공하는 비교자를 사용해 클래스를 비교한다.  
public int compareTo(CaseInsensitiveString cis) {  
    return String.CASE_INSENSITIVE_ORDER.compare(s, cis.s);  
}
```

- **객체 참조 필드를 비교**하려면 **compareTo 메서드를 재귀적으로 호출**한다.
    - Comparable을 구현하지 않은 필드이거나 표준이 아닌 순서로 비교해야한다면 **Comparator**를 대신 사용하자.
    - Comparator는 직접 만들거나 java가 제공하는 것을 사용하면 된다.
- 정수 기본 타입이든 실수 기본 타입이든 관계 연산자인 <, >을 사용하지말고 compare을 이용하자.

### 비교시 가장 핵심적인 필드부터 비교해나가자.

- 비교 결과가 0이 아니라면(순서가 결정되면) 비교가 끝나기 때문이다.

```java
// 코드 14-2 기본 타입 필드가 여럿일 때의 비교자 (91쪽)  
public int compareTo(PhoneNumber pn) {  
    int result = Short.compare(areaCode, pn.areaCode);  
    if (result == 0)  {  
        result = Short.compare(prefix, pn.prefix);  
        if (result == 0)  
            result = Short.compare(lineNum, pn.lineNum);  
    }  
    return result;  
}
```

> 위 코드는 간결하지만 성능 저하가 따른다.

### 비교자 생성 메서드를 사용하자.

- 비교자 생성 메서드를 사용하여 코드를 좀 더 깔끔하게 만들 수 있다.
    - `comparingInt(ToIntFunction<\? super T> keyExtractor)`
    - `comparingLong(ToLongFunction<\? super T> keyExtractor)`
    - `comparingDouble(ToDoubleFunction<\? super T> keyExtractor)`

```java
// 코드 14-3 비교자 생성 메서드를 활용한 비교자 (92쪽)  
private static final Comparator<PhoneNumber> COMPARATOR =  
        comparingInt((PhoneNumber pn) -> pn.areaCode)  
                .thenComparingInt(pn -> pn.prefix)  
                .thenComparingInt(pn -> pn.lineNum);
```

- 객체 참조용 비교자 메서드를 이용해 비교자를 생성할 수 있다.
    - 객체 참조용 비교자 메서드

```java
public static <T, U extends Comparable<? super U>> Comparator<T> comparing(
    Function<? super T, ? extends U> keyExtractor)
```

- 사용 예시

```java
Comparator<Person> nameComparator = Comparator.comparing(Person::getName);
Comparator<Person> ageComparator = Comparator.comparing(Person::getAge, (a, b) -> b.compareTo(a)); // 역순
```

- thenComparing
    - 이미 존재하는 비교자에 추가적인 비교 기준을 더할때 사용

```java
  default Comparator<T> thenComparing(Comparator<? super T> other)
```

- 사용 에시

```java
Comparator<Person> fullComparator = Comparator
    .comparing(Person::getLastName)
    .thenComparing(Person::getFirstName)
    .thenComparing(Person::getAge)
    .thenComparing(Person::getHeight, (h1, h2) -> Double.compare(h2, h1)); // 키 역순
```

### 값의 차를 기준으로 비교할 때 -를 사용하지 말자.

- `-`을 사용할 경우 정수 오버플로우를 일으키거나 부동소수점 계산 방식에 따른 오류를 낼 수 있다.
- 정적 compare 메서드를 활용한 비교자를 사용하자.

```java
// 코드 14-5 정적 compare 메서드를 활용한 비교자
static Comparator<Object> hashCodeOrder = new Comparator<>() {
    public int compare(Object o1, Object o2) {
        return Integer.compare(o1.hashCode(), o2.hashCode());
    }
};
```

- 비교자 생성 메서드를 활용한 비교자를 사용하자.

```java
// 코드 14-6 비교자 생성 메서드를 활용한 비교자
static Comparator<Object> hashCodeOrder = 
    Comparator.comparingInt(o -> o.hashCode());
```

### 결론

- **순서를 고려해야 하는 값 클래스를 작성한다면 꼭 Comparable 인터페이스를 구현하자.**
    - 쉽게 정렬하고 검색하고 비교 기능을 제공하는 컬렉션과 어우러질 수 있다.
- compareTo 메서드에서 필드의 값을 비교할 때 <나 > 연산자는 사용하지 말자.
    - 대신, 박싱된 기본 타입 클래스가 제공하는 **정적 compare 메서드**나 **Comparator 인터페이스가 제공하는 비교자 생성 메서드**를 사용하자.

