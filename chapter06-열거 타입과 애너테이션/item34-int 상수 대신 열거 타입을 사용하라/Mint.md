# 34. int 상수 대신 열거 타입을 사용하라
## 열거 타입
- 일정 개수의 상수 값을 정의한 다음, 그 외 값은 허용하지 않는 타입

### a) 정수 열거 패턴 - 매우 취약
```java
public static final int APPLE_FUJI = 0;
public static final int APPLE_PIPPIN = 1;
public static final int APPLE_GRANNY_SMITH = 2;

public static final int ORANGE_NABEL = 0;
public static final int ORANGE_TEMPLE = 1;
public static final int ORANGE_BLOOD = 2;

```

- **타입 안전을 보장할 수 없다.**
    - 오렌지를 건네야 할 메서드에 사과를 보내거나, 동등 연산자로 비교하더라도 컴파일러는 경고 메세지르 출력하지 않는다.
    - 서로 다른 의미를 가진 상수들 사이에 비교와 할당이 일어나더라도, 컴파일러는 정수로 인지하므로 컴파일러 시점에서 검사할 수 없ㅂ다.
- **표현력도 좋지 않다.**
    - 정수 상수는 디버깅시 숫자만 보인다.
- **별도의 이름 공간을 지원하지 않는다.**
    - 접두어(APPLE_, ORANGE_)를 사용해서 이름 충돌을 방지한다.
- **정수 열거 패턴을 사용한 프로그램은 깨지기 쉽다.**
    - 상수 값이 클라이언트 파일에 새겨지므로 상수의 값이 바뀌면 클라이언트도 다시 컴파일해야한다.
- **문자열로 출력하기 까다롭다.**
    - 디버거로 살펴봐도 다 숫자로만 보이므로 도움이 되지 않는다.
    - 같은 그룹에 속한 모든 상수를 한바퀴 순회하는 방법도 마땅치 않다.

### b) 문자열 열거 패턴 - 사용 금지
```java
public class Fruit {
    public static final String APPLE = "apple";
    public static final String ORANGE = "orange";
    public static final String BANANA = "banana";
    public static final String GRAPE = "grape";
}

public class FruitExample {
    public static void main(String[] args) {
        // 타입 안전성이 없음
        String notAFruit = "pear";  
        printFruitColor(notAFruit); // 컴파일러 시점에서 검사하지 못한다.
    }
    
    public static void printFruitColor(String fruit) {
        if (fruit.equals(Fruit.APPLE)) {
            System.out.println("Red");
        } else if (fruit.equals(Fruit.ORANGE)) {
            System.out.println("Orange");
        } else if (fruit.equals(Fruit.BANANA)) {
            System.out.println("Yellow");
        } else if (fruit.equals(Fruit.GRAPE)) {
            System.out.println("Purple");
        } else {
            System.out.println("Unknown fruit");
        }
    }
}
```

- 상수 이름 대신 문자열 값을 그대로 하드코딩한다.
- 열거 타입의 문자열에 오타가 있어도 컴파일러는 확인할 수 없어 런타임 에러가 생긴다.
- 문자열 비교에 따른 성능 저하가 생긴다.
- String 타입이므로 어떤 문자열이든 사용이 가능해 타입 안전성이 떨어진다.

### c) 열거 타입 (enum) - 추천 🌟
```java
public enum Apple { FUJI, PIPPIN, GRANNY_SMITH }
public enum Orange { NAVEL, TEMPLE, BLOOD }
```
- 열거 타입 자체는 클래스이며, 상수 하나당 자신의 인스턴스를 하나씩 만들어 `public static final 필드`로 공개한다.
- 열거 타입은 밖에서 접근할 수 있는 생성자를 제공하지 않으므로 사실상 **final 클래스**이다.
    - 클라이언트가 인스턴스를 생성하거나 확장할 수 없다.
    - 열거 타입으로 만들어진 인스턴스들은 딱 하나씩만 존재하는 싱글턴 인스턴스이다. (**인스턴스 통제된다**.)

#### 열거 타입의 장점
- 열거 타입은 `컴파일 타입 안전성`을 제공한다.
    - 열거 타입을 매개변수로 받는 메서드를 선언했다면, 건네받은 참조는 해당 `열거 타입의 참조`이다.
        - 다른 타입의 값을 넘기려고 하면 `컴파일 오류가` 난다.
- 각자 `이름 공간`이 있어서 이름이 같은 상수도 평화롭게 공존할 수 있다.
- 열거 타입에 새로운 상수를 추가하거나 순서를 바꿔도 **클라이언트 코드는 재컴파일하지 않아도 된다**.
    - 공개되는 것이 오직 필드의 이름뿐이라서 상수값이 각인되지 않기 때문이다.
- `toStriing` 메서드는 출력하기에 적합한 문자열을 내어준다.

- 열거 타입은 임의의 메서드가 필드를 추가할 수 있고, 임의의 `인터페이스`를 구현하게 할 수도 있다.
- `Object` 메서드들과 `Comparable` 과 `Serializable` 을 구현해두었다.

# 열거 타입 Enum
## 열거 타입에 메서드와 필드 추가하기
```java
// 코드 34-3 데이터와 메서드를 갖는 열거 타입 (211쪽)  
public enum Planet {  
    MERCURY(3.302e+23, 2.439e6),  
    VENUS  (4.869e+24, 6.052e6),  
    EARTH  (5.975e+24, 6.378e6),  
    MARS   (6.419e+23, 3.393e6),  
    JUPITER(1.899e+27, 7.149e7),  
    SATURN (5.685e+26, 6.027e7),  
    URANUS (8.683e+25, 2.556e7),  
    NEPTUNE(1.024e+26, 2.477e7);  
  
    private final double mass;           // 질량(단위: 킬로그램)  
    private final double radius;         // 반지름(단위: 미터)  
    private final double surfaceGravity; // 표면중력(단위: m / s^2)  
  
    // 중력상수(단위: m^3 / kg s^2)  
    private static final double G = 6.67300E-11;  
  
    // 생성자  
    Planet(double mass, double radius) {  
        this.mass = mass;  
        this.radius = radius;  
        surfaceGravity = G * mass / (radius * radius);  
    }  
  
    public double mass()           { return mass; }  
    public double radius()         { return radius; }  
    public double surfaceGravity() { return surfaceGravity; }  
  
    public double surfaceWeight(double mass) {  
        return mass * surfaceGravity;  // F = ma  
    }  
}
```
- 열거 타입 상수 각각을 특정 데이터와 연결지으려면, 생성자에서 데이터를 받아 **인스턴스 필드에 저장**하면 된다.
    - 열거 타입은 불변이므로 모든 필드는 `final` 이어야 한다. (프로그램 실행 중간에 변경되면 안된다.)
    - 필드를 `public` 으로 선언해도 되지만, `private` 으로 두고 별도의 `public` 접근자 메서드를 두는 것이 낫다. (필드 표현방식을 변경하더라도 외부 코드에 영향 X)

### values()
```java
public class WeightTable {
	public static void main(String[] args){
		double earthWeight = Double.parseDouble(args[0]);
		double mass = earthWeight / Planet.EAARTH.surfaceGravity();
		for (Planet p: Planet.values()){
			System.out.printf("%s 무게 : %f", p, p.surfaceWeight(mass));
		}
	}
}
```
- 열거 타입은 자신 안에 **정의된 상수들의 값을 배열에 담아 반환**하는 정적 메서드인 `values` 를 제공한다.
- 값들은 선언된 순서로 저장된다.

### toString()
- 상수 이름을 문자열로 반환한다.

## 열거 타입에 상수를 하나 제거한다면?
- 클라이언트 코드가 `컴파일`되지 않았을 경우 : 런타임 에러
- 클라이언트 코드가 `재컴파일` 되었을 경우 : 컴파일 에러
    - 해당 상수를 찾을 수 없다.

## 열거 타임을 선언한 `클래스`나 해당 `패키지`에서만 유용한 기능은 `private`이나 `package-private` 메서드로 구현한다.
- `private` 메서드 : 자신을 선언한 클래스에서 사용
- `package-private` 메서드 : 해당 패키지에서 사용
- 해당 메서드(기능)을 클라이언트에 노출해야할 합당한 이유가 없다면 `private` 으로, 필요하다면 `package-private` 으로 선언하라

## 널리 쓰이는 열거 타입은 `톱레벨 클래스`로 만들고, 특정 톱레벨 클래스에서만 쓰인다면 해당 클래스의 `멤버 클래스`로 만든다.
- **톱레벨 클래스**
    - 다른 클래스나 패키지에서 쉽게 접근, 사용 가능
```java
public enum Season { // 톱레벨 클래스
    SPRING("Spring", "Warm"),
    SUMMER("Summer", "Hot"),
    AUTUMN("Autumn", "Cool"),
    WINTER("Winter", "Cold");

    private final String name;
    private final String temperature;

    Season(String name, String temperature) {
        this.name = name;
        this.temperature = temperature;
    }

    public String getName() {
        return name;
    }

    public String getTemperature() {
        return temperature;
    }
}

public class WeatherApp {
    public void describeSeason(Season season) {
        System.out.println("It's " + season.getName() + " and it's " + season.getTemperature());
    }

    public static void main(String[] args) {
        WeatherApp app = new WeatherApp();
        app.describeSeason(Season.SUMMER);
    }
}
```

- **멤버 클래스**
    - 해당 클래스와 강하게 연결된 enum 타입 캡슐화
```java
public class Pizza {
    private final String name;
    private final PizzaSize size;
    private final double price;

    public enum PizzaSize {
        SMALL(10), MEDIUM(12), LARGE(14), EXTRA_LARGE(16);

        private final int inches;

        PizzaSize(int inches) {
            this.inches = inches;
        }

        public int getInches() {
            return inches;
        }
    }

    public Pizza(String name, PizzaSize size) {
        this.name = name;
        this.size = size;
        this.price = calculatePrice();
    }

    private double calculatePrice() {
        // 크기에 따른 가격 계산 로직
        return 10.0 + (size.getInches() - 10) * 2;
    }

    public String getDescription() {
        return name + " (" + size + " - " + size.getInches() + " inches): $" + price;
    }

    public static void main(String[] args) {
        Pizza margherita = new Pizza("Margherita", PizzaSize.MEDIUM);
        System.out.println(margherita.getDescription());
    }
}
```

## 상수마다 동작이 달라져야 하는 상황
### a) switch문 사용 - 비추천
```java
// 코드 34-6 상수별 클래스 몸체(class body)와 데이터를 사용한 열거 타입 (215-216쪽)  
public enum Operation {  
    PLUS, MINUS, TIMES, DIVIDE;  
  
    public double apply(double x, double y){
	    switch (this) {
		    case PLUS: return x + y;
			case MINUS: return x - y;
			case TIMES: return x * y;
			case DIVIDE: return x / y;
	    }
	    throw new ssertionError("알 수 없는 연산: " + this);
    }
}
```
- 깨지기 쉬운 코드이다.
    - 새로운 상수를 추가하면 해당 case문도 추가해야 한다.

### b) 상수별 메서드 구현 - 추천 🌟
- 추상 메서드 선언 후 상수마다 재정의한다.
```java
// 코드 34-6 상수별 클래스 몸체(class body)와 데이터를 사용한 열거 타입 (215-216쪽)  
public enum Operation {  
    PLUS {  
        public double apply(double x, double y) { return x + y; }  
    },  
    MINUS {  
        public double apply(double x, double y) { return x - y; }  
    },  
    TIMES {  
        public double apply(double x, double y) { return x * y; }  
    },  
    DIVIDE {  
        public double apply(double x, double y) { return x / y; }  
    };  
  
    public abstract double apply(double x, double y);  
}
```
- apply 메서드가 상수 선언 바로 옆에 붙어 있으니 새로운 상수를 추가할 때 `apply`도 재정의해야한다.
    - 재정의하지 않으면 컴파일 오류로 알려준다.
#### 상수별 메서드 구현 + 상수별 데이터
```java
// 코드 34-6 상수별 클래스 몸체(class body)와 데이터를 사용한 열거 타입 (215-216쪽)  
public enum Operation {  
    PLUS("+") {  
        public double apply(double x, double y) { return x + y; }  
    },  
    MINUS("-") {  
        public double apply(double x, double y) { return x - y; }  
    },  
    TIMES("*") {  
        public double apply(double x, double y) { return x * y; }  
    },  
    DIVIDE("/") {  
        public double apply(double x, double y) { return x / y; }  
    };  
  
    private final String symbol;  
  
    Operation(String symbol) { this.symbol = symbol; }  
  
    @Override public String toString() { return symbol; }  
  
    public abstract double apply(double x, double y);  
  
    public static void main(String[] args) {  
        double x = Double.parseDouble(args[0]);  
        double y = Double.parseDouble(args[1]);  
        for (Operation op : Operation.values())  
            System.out.printf("%f %s %f = %f%n",  
                    x, op, y, op.apply(x, y));  
    }  
}
```

#### valueOf(String)
- 열거 타입에는 상수 이름을 입력받아 그 이름에 해당하는 상수를 반환해주는 valueOf 메서드
- 컴파일러에 의해 자동 생성된다.

#### fromString(String)
- 열거 타입의 toString 메서드를 재정의하려거든 toString이 반환하는 **문자열을 해당 열거 타입 상수로 변환**해주는 `fromString` 메서드도 함께 제공하자.
```java
// 코드 34-7 열거 타입용 fromString 메서드 구현하기 (216쪽)  
private static final Map<String, Operation> stringToEnum =  
		Stream.of(values()).collect(  
				toMap(Object::toString, e -> e));  

// 지정한 문자열에 해당하는 Operation을 (존재한다면) 반환한다.  
public static Optional<Operation> fromString(String symbol) {  
	return Optional.ofNullable(stringToEnum.get(symbol));  
}  
```

- `enum` 초기화 순서
1. `enum` 클래스 로딩시 **상수**들이 먼저 초기화된다. + 생성자 호출
2. 그 다음에 `enum` 클래스의 **정적 필드**들이 초기화된다.

- 열거 타입 상수는 생성자에서 자신의 인스턴스를 맵에 추가할 수 없다.
    - 생성자 호출 시점에서는 정적 필드들이 아직 초기화되지 않았기 때문이다. (NPE 발생)
    - 열거 타입의 생성자에서 접근할 수 있는 것은 상수 변수 뿐이다.
> 상수란 값이 변하지 않은 필드를 의미한다.
> stringToEnum은 final이지만 런타임에 초기화되므로 엄밀한 의미의 상수는 아니다.


## 열거 타임끼리 코드를 공유하기
### a) 값에 따라 분기(`switch`)하여 코드를 공유 - 일반적으로 비추천
```java
enum PayrollDay {
    MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY,
    SATURDAY, SUNDAY;

    private static final int MINS_PER_SHIFT = 8 * 60; // 한 시프트의 분 단위 시간

    int pay(int minutesWorked, int payRate) {
        int basePay = minutesWorked * payRate; // 기본 급여 계산

        int overtimePay; // 초과 근무 수당
        switch (this) {
            case SATURDAY, SUNDAY: // 주말
                overtimePay = basePay / 2; // 기본 급여의 절반을 초과 근무 수당으로 지급
                break;
            default: // 주중
                overtimePay = minutesWorked <= MINS_PER_SHIFT ?
                        0 : (minutesWorked - MINS_PER_SHIFT) * payRate / 2; // 초과 근무 시간에 대한 수당 계산
        }

        return basePay + overtimePay; // 기본 급여와 초과 근무 수당을 합산하여 반환
    }
}
```
- 새로운 열거 타입을 추가하려면 case문도 추가해야한다.

#### 기존 열거 타입에 상수별 동작을 혼합해 넣을때는 switch문이 좋은 선택이다. - 🌟
```java
// 코드 34-10 switch 문을 이용해 원래 열거 타입에 없는 기능을 수행한다. (219쪽)  
public class Inverse {  
    public static Operation inverse(Operation op) {  
        switch(op) {  
            case PLUS:   return Operation.MINUS;  
            case MINUS:  return Operation.PLUS;  
            case TIMES:  return Operation.DIVIDE;  
            case DIVIDE: return Operation.TIMES;  
  
            default:  throw new AssertionError("Unknown op: " + op);  
        }  
    }  
  
    public static void main(String[] args) {  
        double x = Double.parseDouble(args[0]);  
        double y = Double.parseDouble(args[1]);  
        for (Operation op : Operation.values()) {  
            Operation invOp = inverse(op);  
            System.out.printf("%f %s %f %s %f = %f%n",  
                    x, op, y, invOp, y, invOp.apply(op.apply(x, y), y));  
        }  
    }  
}
```
- 추가하려는 메서드가  의미상 열거 타입에 속하지 않는다면 위 방식을 적용하자

### b) 잔업수당을 계산하는 코드를 모든 상수를 중복해서 넣는다. - 비추천
```java
enum PayrollDay {
    MONDAY {
        int pay(int minutesWorked, int payRate) {
            int basePay = minutesWorked * payRate;
            int overtimePay = minutesWorked <= MINS_PER_SHIFT ? 0 :
                    (minutesWorked - MINS_PER_SHIFT) * payRate / 2;
            return basePay + overtimePay;
        }
    },
    TUESDAY {
        int pay(int minutesWorked, int payRate) {
            int basePay = minutesWorked * payRate;
            int overtimePay = minutesWorked <= MINS_PER_SHIFT ? 0 :
                    (minutesWorked - MINS_PER_SHIFT) * payRate / 2;
            return basePay + overtimePay;
        }
    },
    SATURDAY {
        int pay(int minutesWorked, int payRate) {
            int basePay = minutesWorked * payRate;
            int overtimePay = minutesWorked * payRate / 2;
            return basePay + overtimePay;
        }
    },
    SUNDAY {
        int pay(int minutesWorked, int payRate) {
            int basePay = minutesWorked * payRate;
            int overtimePay = minutesWorked * payRate / 2;
            return basePay + overtimePay;
        }
    };

    private static final int MINS_PER_SHIFT = 8 * 60;
    
    abstract int pay(int minutesWorked, int payRate);

    public static void main(String[] args) {
        for (PayrollDay day : values())
            System.out.printf("%-10s%d%n", day, day.pay(8 * 60, 1));
    }
}
```
- **코드 중복**이 많아 유지보수가 어렵다.
- 새로운 요일을 추가하거나 급여 계산 로직을 변경할 때 **모든 상수를 수정**해야 한다.

### c) 계산 코드를 나눠서 각각을 도우미 메서드로 정의 - 비추천
```java
enum PayrollDay {
    MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;

    private static final int MINS_PER_SHIFT = 8 * 60;

    int pay(int minutesWorked, int payRate) {
        int basePay = minutesWorked * payRate;
        int overtimePay = isWeekend() ? 
            calculateWeekendOvertimePay(minutesWorked, payRate) :
            calculateWeekdayOvertimePay(minutesWorked, payRate);
        return basePay + overtimePay;
    }

    private boolean isWeekend() {
        return this == SATURDAY || this == SUNDAY;
    }

    private int calculateWeekdayOvertimePay(int minsWorked, int payRate) { // 평일
        return minsWorked <= MINS_PER_SHIFT ? 0 :
                (minsWorked - MINS_PER_SHIFT) * payRate / 2;
    }

    private int calculateWeekendOvertimePay(int minsWorked, int payRate) { // 주말
        return minsWorked * payRate / 2;
    }

    public static void main(String[] args) {
        for (PayrollDay day : values())
            System.out.printf("%-10s%d%n", day, day.pay(8 * 60, 1));
    }
}
```
- 새로운 급여 계산 방식을 추가하기 어렵다.

### d) 새로운 상수를 추가할 때 **전략**을 선택하도록 하는 것 - 추천 🌟
```java
// 코드 34-9 전략 열거 타입 패턴 (218-219쪽)  
enum PayrollDay {  
    MONDAY(WEEKDAY), TUESDAY(WEEKDAY), WEDNESDAY(WEEKDAY),  
    THURSDAY(WEEKDAY), FRIDAY(WEEKDAY),  
    SATURDAY(WEEKEND), SUNDAY(WEEKEND);  

    private final PayType payType;  
  
    PayrollDay(PayType payType) { this.payType = payType; }  

	int pay(int minutesWorked, int payRate) {  
        return payType.pay(minutesWorked, payRate);  
    }  
  
    // 전략 열거 타입  
    enum PayType {  
        WEEKDAY {  
            int overtimePay(int minsWorked, int payRate) {  
                return minsWorked <= MINS_PER_SHIFT ? 0 :  
                        (minsWorked - MINS_PER_SHIFT) * payRate / 2;  
            }  
        },  
        WEEKEND {  
            int overtimePay(int minsWorked, int payRate) {  
                return minsWorked * payRate / 2;  
            }  
        };  
  
        abstract int overtimePay(int mins, int payRate);  
        private static final int MINS_PER_SHIFT = 8 * 60;  
  
        int pay(int minsWorked, int payRate) {  
            int basePay = minsWorked * payRate;  
            return basePay + overtimePay(minsWorked, payRate);  
        }  
    }  
  
    public static void main(String[] args) {  
        for (PayrollDay day : values())  
            System.out.printf("%-10s%d%n", day, day.pay(8 * 60, 1));  
    }  
}
```
- 잔업수당 계산을 전략 열거 타입에 위임한다.
- switch문보다 복잡하지만 더 안전하고 유연하다.

## 열거 타입의 성능
- 정수 상수와 별반 다르지 않다.

## 열거 타입 사용 시기
- **필요한 원소를 컴파일타임에 다 알 수 있는 상수 집**합이라면, 열거 타입을 사용하자
- 열거 타입에 정의된 상수 개수가 영원히 고정 불변일 필요는 없다.

# 결론
- **열거 타입은 정수 상수보다 뛰어나다.**
    - 더 알기 쉽고 안전하고 강력하다
    - 각 상수를 **특정 데이터와 연결**짓거나 **상수마다 다르게 동작**시킬 수 있다.
- **하나의 메서드가 상수별로 다르게 동작**해야할 때도 있다.
    - switch문 대신 **상수별 메서드 구현을 사용하자.**
- 열거 타입 상수 **일부가 같은 동작을 공유**한다면 **전략 열거 타입 패턴**을 사용하자.


