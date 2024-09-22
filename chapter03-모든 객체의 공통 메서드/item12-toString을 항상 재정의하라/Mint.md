# 12. toString을 항상 재정의하라.

### Object의 기본 toString()은 단순히 `클래스_이름@16진수로_표시한_해시코드`를 반환한다.

- toString의 일반 규약에 따르면 **"간결하면서 사람이 읽기 쉬운 형태의 유익한 정보"** 를 반환해야 한다.
    - PhoneNumber@adbbd가 아닌 "707-867-5309"

### toString의 규약은 또한 **"모든 하위 클래스에서 toString을 재정의하라"** 이다.

- toString을 잘 구현한 클래스는 사용하기에 훨씬 즐겁고, 그 클래스를 사용한 시스템은 디버깅하기 쉽다.

```java
public static void main(String[] args) {  
    PhoneNumber jenny = new PhoneNumber(707, 867, 5309);  
    System.out.println("제니의 번호: " + jenny);  
}
```

단순히 객체를 출력하기만 해도 객체에 대한 정보를 알 수 있다.

### 실전에서 toString은 그 객체가 가진 주요 정보 모두를 반환하는게 좋다.

- 객체가 거대하거나 문자열로 표현하기에 적합하지 않다면 요약 정보(스스로를 완벽히 설명하는 문자열)이어야 한다.

### toString을 구현할때 반환값의 포맷을 문서화할지 정해야 한다.

- 포맷을 명시하면 그 객체는 표준적이고, 명확하고, 사람이 읽을 수 읽게 된다.
    - 포맷을 명시하기로 했다면, 명시한 포맷에 맞는 문자열과 객체를 상호 전환할 수 있는 **정적 팩터리나 생성자를 함께 제공**하면 좋다.

```java
/**  
 * 이 전화번호의 문자열 표현을 반환한다.  
 * 이 문자열은 "XXX-YYY-ZZZZ" 형태의 12글자로 구성된다.  
 * XXX는 지역 코드, YYY는 프리픽스, ZZZZ는 가입자 번호다.  
 * 각각의 대문자는 10진수 숫자 하나를 나타낸다.  
 * * 전화번호의 각 부분의 값이 너무 작아서 자릿수를 채울 수 없다면,  
 * 앞에서부터 0으로 채워나간다. 예컨대 가입자 번호가 123이라면  
 * 전화번호의 마지막 네 문자는 "0123"이 된다.  
 */
 @Override public String toString() {  
    return String.format("%03d-%03d-%04d",  
            areaCode, prefix, lineNum);  
}

// 정적 팩토리 예시
    /**
     * 지정된 문자열 표현에 해당하는 PhoneNumber 인스턴스를 반환합니다.
     * 문자열은 toString() 메서드에 명시된 형식이어야 합니다.
     *
     * @param phoneNumberString 전화번호의 문자열 표현
     * @return 해당 전화번호를 나타내는 PhoneNumber 인스턴스
     * @throws IllegalArgumentException 문자열이 올바른 형식이 아니면 발생
     */
    public static PhoneNumber parse(String phoneNumberString) {
        String[] parts = phoneNumberString.split("-");
        if (parts.length != 3) {
            throw new IllegalArgumentException("잘못된 전화번호 형식: " + phoneNumberString);
        }
        try {
            int areaCode = Integer.parseInt(parts[0]);
            int prefix = Integer.parseInt(parts[1]);
            int lineNumber = Integer.parseInt(parts[2]);
            return new PhoneNumber(areaCode, prefix, lineNumber);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("잘못된 전화번호 형식: " + phoneNumberString);
        }
    }
    // equals와 hashCode 메서드 생략
}
```

### 포맷 명시 여부와 상관없이, toString이 반환한 값에 포함된 정보를 얻어올 수 있는 api를 제공하자.

- PhoneNumber 클래스는 지역 코드, 프리픽스, 가입자 번호용 **접근자**를 제공해야한다.

### 기타 참고사항

- 정적 유틸리티 클래스는 toString을 제공할 이유가 없다.
- 열거 타입도 이미 java가 toString을 제공하니 따로 재정의하지 않아도 된다.
- 하지만 하위 클래스들이 공유해야 할 문자열 표현이 있는 **추상 클래스라면 toString을 재정의해줘야 한다.**
    - 추상 클래스

```java
public abstract class Shape {
    private String color;

    public Shape(String color) {
        this.color = color;
    }

    public abstract double getArea();

    @Override
    public String toString() {
        return getClass().getSimpleName() + "{color='" + color + "', area=" + getArea() + "}";
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof Shape)) {
            return false;
        }
        Shape shape = (Shape) o;
        return Objects.equals(color, shape.color) &&
                Double.compare(shape.getArea(), getArea()) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hash(color, getArea());
    }
}
```

	- 하위 클래스

```java
public class Circle extends Shape {
    private double radius;

    public Circle(String color, double radius) {
        super(color);
        this.radius = radius;
    }

    @Override
    public double getArea() {
        return Math.PI * radius * radius;
    }

    // toString을 재정의하지 않음 (상위 클래스의 toString을 그대로 사용)
}
```

### 결론

- 모든 구체 클래스에서 Object의 toString을 재정의하자.
    - 상위 클래스에서 이미 알맞게 재정의한 경우는 예외다.
- toString을 재정의한 클래스는 사용하기도 즐겁고 그 클래스를 사용한 시스템을 디버깅하기 쉽게 해준다.
- toString은 해당 객체에 관한 명확하고 유용한 정보를 읽기 좋은 형태로 반환해야 한다.


