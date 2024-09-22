# 요약
---

## 비트 필드 

```java
public class Text {
    public static final int BOLD = 1 << 0;
    public static final int ITALIC = 1 << 1;
    public static final int UNDERLINE = 1 << 2;
    public static final int STRIKETHROUGH = 1 << 3;

    public void applyStyles(int styles) {
        // ...
    }
}
```

- 비트 연산을 이용해 여러 상수를 하나의 집합으로 모을 수 있고 이를 비트 필드라고 한다 
- 정수 열거 패턴의 단점을 그대로 가진다
- 비트 필드 값을 해석하기 어렵다
- 비트 필드 하나에 녹아있는 모든 원소를 순회하기 까다롭다
- 최대 몇 비트가 필요한지 API 작성 시 미리 예측할 필요가 있다
(타입이 변경되는 경우 유지보수가 까다로울 수 있음)

## 대안 : java.util.EnumSet

```java
public class Text {
    public enum Style {BOLD, ITALIC, UNDERLINE, STRIKETHROUGH}

    // 어떤 Set을 넘겨도 되나, EnumSet이 가장 좋다.
    public void applyStyles(Set<Style> styles) {
        System.out.printf("Applying styles %s to text%n",
                Objects.requireNonNull(styles));
    }

    // 사용 예
    public static void main(String[] args) {
        Text text = new Text();
        text.applyStyles(EnumSet.of(Style.BOLD, Style.ITALIC));
    }
}
```

- EnumSet은 비트 필드를 대체할 수 있는 기능적인 대안이다
- Set 인터페이스를 완벽히 구현하였다 
- 내부가 비트 벡터로 구현되어 있다 (원소가 64개 이하라면, Enumset 전체를 long 변수 하나로 표현하여, 비트 필드에 견줄만한 성능을 보여줌)

```java
class RegularEnumSet<E extends Enum<E>> extends EnumSet<E> {
    private static final long serialVersionUID = 3411599620347842686L;

    private long elements = 0L;

    void addAll() {
        if (universe.length != 0)
            elements = -1L >>> -universe.length;
    }

    void complement() {
        if (universe.length != 0) {
            elements = ~elements;
            elements &= -1L >>> -universe.length;  // Mask unused bits
        }
    }


    public boolean add(E e) {
    typeCheck(e);
    long oldElements = elements;
    elements |= (1L << ((Enum<?>)e).ordinal());
    return elements != oldElements;
}

    // ...
}
```

- 단점 : 불변 Enumset 을 지원하지 않는다 (Collections.unmodifiableSet 사용)
