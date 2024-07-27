# 10. equals는 일반 규약을 지켜 재정의하라

- equals()를 재정의하지 않을 경우 클래스의 인스턴스는 오직 자기 자신과만 같게 된다. (객체 식별성)

## equals()를 재정의할 필요가 없는 경우

- **각 인스턴스가 본질적으로 고유할 경우**
    - ex) Thread
- **인스턴스의 논리적 동치성을 검사할 일이 없을 경우**
    - Object.equals()로 해결될 경우
- **상위 클래스에서 재정의한 equals()가 하위 클래스에도 딱 들어맞는 경우
    - \ex) Set 구현체는 AbstractSet이 구현한 equals를 상속받아 사용한다.
- **클래스가 private이거나 package-private이고 equals 메서드를 호출할 일이 없는 경우**
    - 외부에서 인스턴스를 비교하지 않고 내부 구현에서만 사용할 경우이다.
    - 또한 equals()를 호출할 일이 없다면 굳이 재정의할 필요가 없다. (호출시 AssertionError())

## equals()를 재정의해야 할 경우

- 객체 식별성(두 객체가 물리적으로 같은가)가 아니라 **논리적 동치성을 확인**해야하는데, **상위 클래스의 equals가 논리적 동치성을 비교하도록 재정의되지 않았을 경우**
    - 주로 **값 클래스**가 여기에 해당한다.
        - 값 클래스라도 값이 같은 인스턴스가 둘 이상 만들어지지 않음을 보장하는 **인스턴스 통제 클래스(정적 팩토리 메서드)라면 재정의할 필요가 없다.**
        - **enum의 경우도 논리적으로 같은 인스턴스가 2개 이상 만들어지지 않으므로 재정의할 필요가 없다.**

## equals() 재정의 규약

equals()메서드는 동치관계를 구현하며, 다음을 만족한다.

- **반사성** : x.equals(x) = true
    - 객체는 자기 자신과 같아야 한다.
- **대칭성**: x.equals(y)가 true이면 y.equals(x)도 true
    - 두 객체는 서로에 대한 동치 여부에 똑같이 답해야한다.
- **추이성**: x.equals(y)가 true이고 y.equals(z)도 true이면 x.equals(z)도 true이다.
    - 첫번째 객체와 두번째 객체가 같고, 두번째 객체와 세번째 객체가 같으면, 첫번째 객체와 세번째 객체도 같아야 한다.
- **일관성**: x.equals(y)를 반복해서 호출하면 항상 true를 반환하거나 항상 false를 반환한다.
    - 두 객체가 같다면 (어느 하나 혹은 두 객체 모두가 수정되지 않는 한) 앞으로도 영원히 같아야 한다.
- **null-아님** : null이 아닌 모든 참조 값 x에 대해, x.equals(null)은 false이다.

> equals 규약을 어기면 프로그램이 이상하게 동작하거나 종료될 수 있다.
> 세상에 홀로 존재하는 클래스는 없기 때문에, 빈번히 전달되어 상호작용한다.

### 동치 관계

집합을 서로 같은 원소들로 이뤄진 부분 집합(동치 클래스)으로 나누는 연산
> equals 메서드가 쓸모 있으려면 모든 원소가 같은 동치류에 속한 어떤 원소와도 서로 교환할 수 있어야 한다.

### 대칭성

- 아래 코드는 대칭성을 위배한다.

```java
package effectivejava.chapter3.item10;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

// 코드 10-1 잘못된 코드 - 대칭성 위배! (54-55쪽)  
public final class CaseInsensitiveString {
    private final String s;

    public CaseInsensitiveString(String s) {
        this.s = Objects.requireNonNull(s);
    }

    // 대칭성 위배!  
    @Override
    public boolean equals(Object o) {
        if (o instanceof CaseInsensitiveString)
            return s.equalsIgnoreCase(
                    ((CaseInsensitiveString) o).s);
        if (o instanceof String)  // 한 방향으로만 작동한다!  
            return s.equalsIgnoreCase((String) o);
        return false;
    }

    // 문제 시연 (55쪽)  
    public static void main(String[] args) {
        CaseInsensitiveString cis = new CaseInsensitiveString("Polish");
        String s = "polish";

        List<CaseInsensitiveString> list = new ArrayList<>();
        list.add(cis);

        System.out.println(list.contains(s));  // false이지만, JDK에 따라 어떤 동작을 할지 예상할 수 없다.
    }
}
```

cis.equals(s)는 true를 반환하지만, 일반 문자열인 s의 equals()를 호출하여 비교하면 s.equals(cis) false를 반환하기 때문이다.
문자열의 equals()는 대소문자를 구분하지만, CaseInsensitiveString의 equals를 대소문자를 구분하지 않고 비교한다.

- 대칭성을 지킨 equals()

```java
 // 수정한 equals 메서드 (56쪽)  
@Override public boolean equals(Object o){
        return o instanceof CaseInsensitiveString&&
        ((CaseInsensitiveString)o).s.equalsIgnoreCase(s);
        }
```

> CaseInsensitiveString과 같은 클래스의 인스턴스인지 확인한다.

### 추이성

상위 클래스에는 없는 필드를 하위 클래스에서 추가한다고 가정해보자.

- 상위 클래스

```java
package effectivejava.chapter3.item10;

// 단순한 불변 2차원 정수 점(point) 클래스 (56쪽)  
public class Point {
    private final int x;
    private final int y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Point))
            return false;
        Point p = (Point) o;
        return p.x == x && p.y == y;
    }

    // 아이템 11 참조  
    @Override
    public int hashCode() {
        return 31 * x + y;
    }
}
```

- 하위 클래스 (추이성 위배)

```java
package effectivejava.chapter3.item10.inheritance;

import effectivejava.chapter3.item10.Color;
import effectivejava.chapter3.item10.Point;

// Point에 값 컴포넌트(color)를 추가 (56쪽)  
public class ColorPoint extends Point {
    private final Color color;

    public ColorPoint(int x, int y, Color color) {
        super(x, y);
        this.color = color;
    }

    // 코드 10-2 잘못된 코드 - 대칭성 위배! (57쪽)  
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof ColorPoint))
            return false;
        return super.equals(o) && ((ColorPoint) o).color == color;
    }

    public static void main(String[] args) {
        // 첫 번째 equals 메서드(코드 10-2)는 대칭성을 위배한다. (57쪽)  
        Point p = new Point(1, 2);
        ColorPoint cp = new ColorPoint(1, 2, Color.RED);
        System.out.println(p.equals(cp) + " " + cp.equals(p));
    }
}
```

하위 클래스의 equals()는 추이성을 위배한다. p.equals(cp)는 true를, cp.equals(p)는 false를 반환하기 때문이다.
cp.equals(p)에서 Point 클래스인 p는 ColorPoint의 인스턴스가 아니기 때문이다.

- ColorPoint의 인스턴스가 아닐 경우 비교대상의 equals()를 사용한다면?

```java
// 코드 10-3 잘못된 코드 - 추이성 위배! (57쪽)  
@Override public boolean equals(Object o){
        if(!(o instanceof Point))
        return false;

        // o가 일반 Point면 색상을 무시하고 비교한다.  
        if(!(o instanceof ColorPoint))
        return o.equals(this);

        // o가 ColorPoint면 색상까지 비교한다.  
        return super.equals(o)&&((ColorPoint)o).color==color;
        }

public static void main(String[]args){
        // 두 번째 equals 메서드(코드 10-3)는 추이성을 위배한다. (57쪽)  
        ColorPoint p1=new ColorPoint(1,2,Color.RED);
        Point p2=new Point(1,2);
        ColorPoint p3=new ColorPoint(1,2,Color.BLUE);
        System.out.printf("%s %s %s%n",
        p1.equals(p2),p2.equals(p3),p1.equals(p3));
        }
        }
```

대칭성은 지켜주지만, 추이성을 깬다. (p1과 p2는 같고, p2는 p3와 같지만 p1과 p3는 다르다.)

- 무한 재귀에 빠질 수 있다.
  SmellPoint가 Point의 하위 클래스라고 가정할때,

```java
ColorPoint cp1=new ColorPoint(1,2,Color.RED);
        SmellPoint sp=new SmellPoint(1,2,"sweet");
```

1. ColorPoint의 equals가 호출되어 SmellPoint의 equals를 호출
2. SmellPoint의 equals가 ColorPoint의 equals를 다시 호출
3. 1번으로 돌아가 무한 반복

**=> 구체 클래스를 확장(extends)해 새로운 값을 추가하면서 equals 규약을 만족시킬 방법은 존재하지 않는다.**

- equals()의 instanceof를 getClass 검사로 바꾸면 어떨까?
  Point(상위 클래스)의 instanceof를 getClass로 바꿔 비교한다.

```java
// 잘못된 코드 - 리스코프 치환 원칙 위배! (59쪽)  
@Override public boolean equals(Object o){
        if(o==null||o.getClass()!=getClass())
        return false;
        Point p=(Point)o;
        return p.x==x&&p.y==y;
        }
```

상위 클래스의 Point를 instanceof가 아닌 getClass로 변경할 경우 같은 구현 클래스의 객체와 비교할 때만 true를 반환한다.

아래의 상황에서 직관에 반하는 문제가 발생한다.

```java
// Point의 평범한 하위 클래스 - 값 컴포넌트를 추가하지 않았다. (59쪽)  
public class CounterPoint extends Point {
    private static final AtomicInteger counter =
            new AtomicInteger();

    public CounterPoint(int x, int y) {
        super(x, y);
        counter.incrementAndGet();
    }

    public static int numberCreated() {
        return counter.get();
    }
}
```

```java
// CounterPoint를 Point로 사용하는 테스트 프로그램  
public class CounterPointTest {
    // 단위 원 안의 모든 점을 포함하도록 unitCircle을 초기화한다. (58쪽)  
    private static final Set<Point> unitCircle = Set.of(
            new Point(1, 0), new Point(0, 1),
            new Point(-1, 0), new Point(0, -1));

    public static boolean onUnitCircle(Point p) {
        return unitCircle.contains(p);
    }

    public static void main(String[] args) {
        Point p1 = new Point(1, 0);
        Point p2 = new CounterPoint(1, 0);

        // true를 출력한다.  
        System.out.println(onUnitCircle(p1));

        // true를 출력해야 하지만, Point의 equals가 getClass를 사용해 작성되었다면 그렇지 않다.  
        System.out.println(onUnitCircle(p2));
    }
}
```

unitCircle의 onUnitCircle 메서드에 new CounterPoint(1, 0)을 파라미터로 넘기면 false를 반환한다.
CounterPoint는 Point의 하위 클래스임에도 같은 클래스가 아니므로 다르다고 판단하는 것이다.
이는 리스코프 치환 원칙을 어긴다.
> 리스코프 치환 원칙: 어떤 타입에 있어 중요한 속성이라면 그 하위 타입에서도 마찬가지로 중요하다.
> 따라서 그 타입의 모든 메서드가 하위 타입에서도 똑같이 잘 작동해야한다.

위 원칙을 따르는 결과가 나오려면 Point를 상속받은 하위 클래스의 인스턴스가 비교대상으로 들어오더라도 논리적 동치성을 비교할 수 있어야 한다.
=> instanceof를 사용해야 한다.

### 상속 대신 컴포지션을 사용하면 대칭성과 추이성 모두 지킬 수 있다.

Point를 ColorPoint의 private 필드로 두고, ColorPoint와 같은 위치의 일반 Point를 반환하는 뷰 메서드를 public으로 추가하자.

```java
package effectivejava.chapter3.item10.composition;

import effectivejava.chapter3.item10.Color;
import effectivejava.chapter3.item10.Point;

import java.util.Objects;

// 코드 10-5 equals 규약을 지키면서 값 추가하기 (60쪽)  
public class ColorPoint {
    private final Point point;
    private final Color color;

    public ColorPoint(int x, int y, Color color) {
        point = new Point(x, y);
        this.color = Objects.requireNonNull(color);
    }

    /**
     * 이 ColorPoint의 Point 뷰를 반환한다.  
     */
    public Point asPoint() {
        return point;
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
}
```

p.equals(cp)는 false이고 cp.equals(p)도 false이므로 대칭성 문제를 해결한다.
또한 같은 클래스이거나 하위 클래스의 인스턴스가 아니면 false를 반환하므로 위 상황과 같은 추이성 문제도 발생하지 않는다.
ColorPoint 인스턴스를 Point 클래스의 인스턴스와 비교하고 싶을 경우 asPoint()를 사용하여 비교하면 된다.
p.equals(cp.asPoint()); // true

> 자바 라이브러리에도 구체 클래스를 확장해 값을 추가한 클래스가 있지만 (Timestamp) 실수이니 따라해서는 안된다.

### 일관성

- 가변 객체는 수정 가능하므로 비교 시점에 따라 결과가 다를 수도 혹은 같을 수도 있는 반면, 불변 객체는 한번 다르면 끝까지 달라야 한다.
    - 가변 클래스여도 두 객체가 상태가 변경되지 않은 경우를 비교할때는 항상 비교 결과가 같아야한다.

> 클래스를 작성할 때는 불변 클래스로 만드는게 나을지 심사숙고하자(item 17)

- 클래스가 불변이든 가변이든 equals의 판단에 신뢰할 수 없는 자원이 끼어들게 해서는 안된다.
    - Url의 equals는 ip주소로 비교하는데, 네트워크를 통하므로 결과가 항상 같다고 보장할 수 없으므로 설계 실수이다.
    - equals()는 항시 메모리에 존재하는 객체만을 사용한 결정적 계산만 수행해야 한다.

### null-아님

- 모든 객체가 null과 같지 않아야 한다.
- 명시적으로 null이 아닌지 체크할 필요는 없다. instanceof에서 묵시적으로 null을 검사하기 때문이다.

### 양질의 equals 메서드 구현 방법

```java
package effectivejava.chapter3.item10;

// 코드 10-6 전형적인 equals 메서드의 예 (64쪽)  
public final class PhoneNumber {
    private final short areaCode, prefix, lineNum;

    public PhoneNumber(int areaCode, int prefix, int lineNum) {
        this.areaCode = rangeCheck(areaCode, 999, "지역코드");
        this.prefix = rangeCheck(prefix, 999, "프리픽스");
        this.lineNum = rangeCheck(lineNum, 9999, "가입자 번호");
    }

    private static short rangeCheck(int val, int max, String arg) {
        if (val < 0 || val > max)
            throw new IllegalArgumentException(arg + ": " + val);
        return (short) val;
    }

    @Override
    public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof PhoneNumber))
            return false;
        PhoneNumber pn = (PhoneNumber) o;
        return pn.lineNum == lineNum && pn.prefix == prefix
                && pn.areaCode == areaCode;
    }

// 나머지 코드는 생략 - hashCode 메서드는 꼭 필요하다(아이템 11)!}
```

1. == 연산자를 이용해 입력이 자기 자신의 참조인지 확인한다.
    - float과 Double의 경우 compare, 참조 타입은 equals(), 기본 타입은 ==
    - null도 정상 값으로 취급해야할 경우 Object.equals(object, object) 사용하기

> 비교하기 어려울 경우 표준형끼리 비교하면 경제적이다.
> 필드 비교는 다를 가능성이 더 크거나 비용이 싼 필드를 먼저 비교하자.

2. instanceof 연산자로 입력이 올바른 타입인지 확인한다.
3. 입력을 올바른 타입으로 형변환한다.
4. 입력 객체와 자기 자신의 대응되는 핵심 필드들이 모두 일치하는지 하나씩 검사한다.

> equals를 다 구현했다면 대칭성, 추이성, 일관성이 지켜졌는지 확인해보자.
> 반사성과 null-아님도 만족해야하지만 이 둘이 문제되는 경우는 별로 없다.

### 마지막 주의사항

- equal를 재정의할땐 hashcode도 반드시 재정의하자
- 너무 복잡하게 해결하려 들지 말자 (필드들의 동치성만 비교해도 지킬 수 있다.)(별칭 사용은 X)
- Object 외의 타입을 매개변수로 받는 equals 메서드는 선언하지 말자.
    - 오버라이드가 아닌 다중정의이다.
- 사람이 직접 작성하는 것보다는 IDE나 구글의 AutoValue에 맡기는 편이 낫다.

### 결론

- 꼭 필요한 경우가 아니면 equals를 재정의하지 말자.
- 재정의해야할 때는 해당 클래스의 핵심 필드 모두를 빠짐없이, 다섯가지 규약을 확실히 지켜가며 비교해야 한다.

