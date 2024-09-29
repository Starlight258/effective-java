# 요약
---

## 정수 열거 패턴 **(int enum pattern)**

- **정수 열거 패턴을 위한 별도 namespace 를 지원하지 않음 (접두어 써서 구분)**
- 타입 안전을 보장 못함
- 같은 정수 열거 그룹에 속한 모든 상수를 순회할 수 있는 방법 없음 (전체 상수 개수 알기 힘듬)
- 표현력이 좋지 않음
- 문자열 출력이 까다로움 —> 문자열 하드 코딩

## **열거 타입 (enum)**

### 열거 타입 이란?

> 일정 개수의 상수값을 정의한 다음 그 외의 값은 허용하지 않는 타입으로, 완전한 타입의 **클래스**
> 

### 장점

- 상수 하나당 자신의 인스턴스가 존재 & public static final 필드로 공개 
- 타입 안전성 제공 
- 새로운 상수를 추가하거나 순서를 바꿔도 컴파일 하지 않아도 됨
- toString 메서드를 통해 출력하기 적합
- 임의의 메서드와 필드를 추가할 수 있고 인터페이스를 구현할 수 있다

## **데이터와 메서드를 갖는 열거 타입**

### 열거 타입 상수 각각을 특정 데이터와 연결 지으려면,

- 특정 데이터의 필드 추가
- 데이터를 받아 인스턴스 필드에 저장하는 생성자 추가
- 생성자에 넘겨지는 데이터는 각 열거 타입 상수 오른쪽 괄호 안에 기입

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

## 상수별 메서드 구현

추상 메서드를 선언하고 각 상수별 클래스 몸체를 상수에 맞게 재정의

### 문제. **값에 따라 분기하는 열거 타입**

```java
public enum Operation {
    PLUS, MINUS, TIMES, DIVIDE;

    public double apply(double x, double y) {
        switch (this) {
            case PLUS: return x+y;
            case MINUS: return x-y;
            case TIMES: return x*y;
            case DIVIDE: return x/y;
        }
        throw new AssertionError("알수없는연산: " + this);
    }

    public static void main(String[] args) {
        double x = 1;
        double y = 2;
        for (Operation op : Operation.values()) {
            System.out.println(op.apply(1, 2));
        }
    }
}
```

- 깨지기 쉬운 코드 — 새로운 상수를 추가하면 매번 case문 추가해야함

### 대안. **상수별 메서드**

```java
public enum Operation {
    PLUS("+") {
        public double apply(double x, double y) {
            return x + y;
        }
    },
    MINUS("-") {
        public double apply(double x, double y) {
            return x - y;
        }
    },
    TIMES("*") {
        public double apply(double x, double y) {
            return x * y;
        }
    },
    DIVIDE("/") {
        public double apply(double x, double y) {
            return x / y;
        }
    };

    private final String symbol;

    Operation(String symbol) {
        this.symbol = symbol;
    }

    public abstract double apply(double x, double y);

    public static void main(String[] args) {
        double x = 1;
        double y = 2;
        for (Operation op : Operation.values()) {
            System.out.println(op.apply(x, y));
        }
    }
}
```

- `apply` 라는 추상 메서드를 선언 —> 각 상수에서 용도에 맞게 재정의

### 상수별 메서드 구현의 단점

- 열거 타입 상수끼리 코드(메서드) 공유가 어려움

### 예시

```java
public enum PayrollDay {
    MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY;
    
    private static final int MINS_PER_SHIFT = 8 * 60;
    
    int pay(int minutesWorked, int payRate) {
        int basePay = minutesWorked * payRate;
        
        int overtimePay;
        switch (this) {
            case SATURDAY: case SUNDAY: //주말
                overtimePay = basePay / 2;
                break;
            default://주중
                overtimePay = minutesWorked <= MINS_PER_SHIFT 
                        ? 0
                        : (minutesWorked - MINS_PER_SHIFT) * payRate / 2;
        }
        
        return basePay + overtimePay;
    }
}
```

- 새로운 값을 열거 타입에 추가하려면 case문을 넣어줘야 함

### 대안. 전략 패턴

```java
public enum PayrollDay {
    MONDAY(WEEKDAY), TUESDAY(WEEKDAY), 
		WEDNESDAY(WEEKDAY), THURSDAY(WEEKDAY), FRIDAY(WEEKDAY),
    SATURDAY(WEEKEND), SUNDAY(WEEKEND);

    private final PayType payType;

    PayrollDay(PayType payType) {
        this.payType = payType;
    }

    int pay(int minutesWorkd, int payRate) {
        return payType.pay(minutesWorkd, payRate);
    }

    enum PayType {
        WEEKDAY {
            @Override
            int overtimePay(int mins, int payRate) {
                return minWorked <= MINS_PER_SHIFT
											? 0
											: (minWorked - MINS_PER_SHIFT) * payRate / 2;
            }
        },

        WEEKEND {
            @Override
            int overtimePay(int mins, int payRate) {
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
}
```

- 잔업수당을 계산하는 로직 자체 두 가지(평일, 휴일)를 **private 중첩 열거 타입**으로 만들어 옮기고, PayrollDay 열거타입의 생성자에서 주입받도록 하는 것
- swtich문 없이도 상수별 메서드 구현이 가능하면서 중복 최소화 —> 유연한 대처 가능.

### 그럼, switch문은 무조건 없는게 좋을까?

기존 열거 타입에 상수별 동작을 혼합할 경우 switch문이 좋을 선택이 될 수 있음

```java
public static Operation inverse(Operation op) {
    switch(op) {
        case PLUS: return Operation.MINUS;
        case MINUS: return Operation.PLUS;
        case TIMES: return Operation.DIVIDE;
        case DIVIDE: return Operation.TIMES;
        default: throw new AssertionError("알 수 없는 연산" + op);
    }
}
```