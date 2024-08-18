# 36. 비트 필드 대신 EnumSet을 사용하라
## 열거 타입이 주로 집합으로 사용될 경우
### a) 정수 열거 패턴 - 비추천
```java
public class Text {
    public static final int STYLE_BOLD =  1 << 0;
	public static final int STYLE_ITALIC = 1 << 1;    
	public static final int STYLE_UNDERLINE = 1 << 2;   

    // 매개변수 styles는 0개 이상의 STYLE_ 상수를 비트별 OR한 값이다.
    public void applyStyles(int styles) {
        // ...
    }
}
```
- 에전에는 **각 상수에 서로 다른 2의 거듭제곱 값을 할당한 정수 열거 패턴**을 사용했다.
- `비트별 OR`을 사용해서 **여러 상수를 하나의 집합으로 모은다**.
    - 비트 필드
```java
text.applyStyles(STYLE_BOLD | STYLE_ITALIC);
```
- 비트 필드를 사용하면 비트별 연산을 사용해 합집합과 교집합 같은 **집합 연산**을 효율적으로 수행할 수 있다.

#### 정수 열거 패턴 단점
- 비트 필드는 정수 열거 상수의 단점을 그대로 가진다.
    - 타입 안전성 X
    - 표현력 X
    - `namespace` 충돌
- 비트 필드 값이 출력되면 **해석하기 어렵다.**
- 비트 필드 하나에 녹아있는 **모든 원소를 순회하기 어렵다.**
- **최대 몇 비트가 필요한지 API 작성시 미리 예측**하여 적절한 타입을 선택해야 한다.

### b) EnumSet - 추천 🌟
- java.util 패키지의 `EnumSet` 은 **열거형 상수 집합**을 다룰 때 사용한다.
- `Set` 인터페이스를 구현하며, **타입 안전**하고, 다른 `Set` 구현체와 함께 사용할 수 있다.
- 내부적으로 `비트 벡터`(각 비트는 상수 존재 여부 표현)로 구현되어, 원소가 64개 이하라면 `long` 변수 하나로 표현한 성능을 보여준다.
- `removeAll` 과 `retainAll` 같은 대량 작업은 비트를 효율적으로 처리할 수 있는 산술 연산을 써서 구현한다.

```java
// 코드 36-2 EnumSet - 비트 필드를 대체하는 현대적 기법 (224쪽)  
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
> applyStyles에서 `Set<Style>`을 인자로 받은 이유 : 모든 클라이언트가 `EnumSet`을 건네리라 짐작되더라도 **이왕이면 인터페이스로 받는 것이 좋다.**
> 클라이언트가 다른 `Set` 구현체를 넘기더라도 처리할 수 있기 때문이다.


## 결론
- 열거할 수 있는 타입을 한데 모아 집합 형태로 사용한다고 해도 **비트 필드를 사용할 이유는 없다.**
- **`EnumSet` 클래스가 비트 필드 수준의 명료함과 성능을 제공하고, 열거 타입의 장점까지 선사하기 때문이다.**
- `EnumSet`의 유일한 단점은, `불변 EnumSet`을 만들 수 없다는 것이다.
    - 대신 `Collections.unmodifiableSet`으로 `EnumSet`을 감싸 사용할 수 있다.

