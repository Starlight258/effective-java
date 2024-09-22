# 38. 확장할 수 있는 열거 타입이 필요하면 인터페이스를 사용하라
### 열거 타입 vs 타임 안전 열거 패턴
- 타입 안전 열거 패턴
  java 5 이전에 열거 타입이 없었을 때 사용되는 방식
```java
public class Day {
    private final String name;

    // private 생성자로 외부에서 인스턴스 생성 방지
    private Day(String name) {
        this.name = name;
    }

    public String toString() {
        return name;
    }

    // public static final 필드로 유일한 인스턴스들을 정의
    public static final Day MONDAY = new Day("월요일");
    public static final Day TUESDAY = new Day("화요일");
    public static final Day WEDNESDAY = new Day("수요일");
    public static final Day THURSDAY = new Day("목요일");
    public static final Day FRIDAY = new Day("금요일");
    public static final Day SATURDAY = new Day("토요일");
    public static final Day SUNDAY = new Day("일요일");

    public static void main(String[] args) {
        Day today = Day.MONDAY;
        System.out.println("오늘은 " + today);  // 출력: 오늘은 월요일
    }
}
```
> enum이 거의 모든 상황에서 더 우수하다.

### 타입 안전 열거 패턴은 확장할 수 있으나 열거 타입은 그럴 수 없다.
- 타입 안전 열거 패턴은 열거한 값들을 그대로 가져온 다음 값을 더 추가하여 다른 목적으로 쓸 수 있다.
- **열거 타입은 확장할 수 없다.**
    - 확장한 타입의 원소는 기반 타입의 원소로 취급하지만, 그 반대가 성립되지 않는다면 이상하다.
    - 기반 타입과 확장된 타입들의 원소 모두를 순회할 수 없다.
    - 확장성을 높이려면 고려할 요소가 많아져 설계화 구현이 복잡하다.

## 인터페이스를 사용하여 `확장된 열거 타입` 효과 내기
- **열거 타입이 임의의 인터페이스를 구현할 수 있음**을 이용한다.
    - `인터페이스`를 정의하고 **열거 타입이 해당 인터페이스를 구현**한다.
    - 확장을 원할 경우 해당 **인터페이스를 구현한 또다른 열거 타입을 정의하여 대체**할 수 있다.

- `인터페이스`
```java
// 코드 38-1 인터페이스를 이용해 확장 가능 열거 타입을 흉내 냈다. (232쪽)  
public interface Operation {  
    double apply(double x, double y);  
}
```
- `BasicOperation`
```java
// 코드 38-1 인터페이스를 이용해 확장 가능 열거 타입을 흉내 냈다. - 기본 구현 (233쪽)  
public enum BasicOperation implements Operation {  
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
  
    BasicOperation(String symbol) {  
        this.symbol = symbol;  
    }  
  
    @Override public String toString() {  
        return symbol;  
    }  
}
```
- `ExtendedOperation`
```java
// 코드 38-2 확장 가능 열거 타입 (233-235쪽)  
public enum ExtendedOperation implements Operation {  
    EXP("^") {  
        public double apply(double x, double y) {  
            return Math.pow(x, y);  
        }  
    },  
    REMAINDER("%") {  
        public double apply(double x, double y) {  
            return x % y;  
        }  
    };  
    
    private final String symbol;  
    
    ExtendedOperation(String symbol) {  
        this.symbol = symbol;  
    }  
    
    @Override public String toString() {  
        return symbol;  
    }  
}
```
- 새로 작성한 연산은 기존 연산을 쓰던 곳이면 어디든 쓸 수 있다.

### 1. 클래스 넘겨서 사용하기
- 기본 열거 타입 대신 확장된 열거 타입을 넘겨 확장된  열거 타입의 원소 모두를 사용하게 할 수 있다.
```java
// 열거 타입의 Class 객체를 이용해 확장된 열거 타입의 모든 원소를 사용하는 예 (234쪽)  
public static void main(String[] args) {  
	double x = Double.parseDouble(args[0]);  
	double y = Double.parseDouble(args[1]); 
	test(BasicOperation.class, x, y);   
	test(ExtendedOperation.class, x, y);  
}  

private static <T extends Enum<T> & Operation> void test(  
		Class<T> opEnumType, double x, double y) {  
	for (Operation op : opEnumType.getEnumConstants())  
		System.out.printf("%f %s %f = %f%n",  
				x, op, y, op.apply(x, y));  
} 
```
- class 리터럴을 넘겨 연산들을 알려준다.
    - 여기서 class 리터럴은 한정적 타입 토큰이다.
- Class 객체가 열거 타입(`Enum<T>`)인 동시에 `Operation`의 하위 타입이어야 한다.
    - 열거 타입 : 원소 순회
    - Operation : 연산 구현

- 단점 : 넘긴 열거 타입만 전달할 수 있다.

### 2. 한정적 와일드카드 타입인 Collection을 넘기는 방법
```java
private static void test(Collection<? extends Operation> opSet, 
						 double x, double y) {  
```
- 인터페이스를 구현한 클래스로 한정한다.
    - 해당 인터페이스르 구현한 클래스이면 모두 인자로 들어올 수 있다.
    - 해당 인터페이스를 확장한 인터페이스도 가능하다.
```java
// 컬렉션 인스턴스를 이용해 확장된 열거 타입의 모든 원소를 사용하는 예 (235쪽)  
private static void test(Collection<? extends Operation> opSet,  
                         double x, double y) {  
    for (Operation op : opSet)  
        System.out.printf("%f %s %f = %f%n",  
                x, op, y, op.apply(x, y));  
}

public static void main(String[] args) {  
    double x = Double.parseDouble(args[0]);  
    double y = Double.parseDouble(args[1]);  
    
    test(Arrays.asList(BasicOperation.values()), x, y);
    test(Arrays.asList(ExtendedOperation.values()), x, y);  
    
    // 여러 연산 조합 가능
    test(Arrays.asList(BasicOperation.PLUS, ExtendedOperation.EXP), x, y);
}  
```
- 덜 복잡하고 test 메서드가 유연해졌다.
    - 여러 구현 타입의 연산을 조합해 호출할 수 있다.
- 특정 연산에서 `EnumSet` 이나 `EnumMap` 을 사용할 수 없다.
    - 단일 `EnumSet` 이나 `EnumMap` 에만 담을 수 있기 때문에, 여러 `Enum` 을 한번에 담을 수 없다.

#### 열거 타입끼리 구현을 상속할 수 없다.
- 아무 상태에도 의존하지 않는 경우에는 `디폴트 구현`을 이용해 인터페이스에 추가한다.
- 상태에 의존하며, 공유하는 기능이 많다면 중복 코드를 별도의 `도우미 클래스`나 `정적 도우미 메서드`로 분리한다.
```java
// 공통 인터페이스
interface Operation {
    double apply(double x, double y);
    String getSymbol();
}

// 도우미 클래스
class OperationHelper {
    private static final Map<String, Operation> symbolToOperation = new HashMap<>();

    // 연산을 등록하는 메서드
    static void registerOperation(String symbol, Operation operation) {
        symbolToOperation.put(symbol, operation);
    }

    // 기호로 연산을 찾는 메서드
    static Operation fromSymbol(String symbol) {
        Operation op = symbolToOperation.get(symbol);
        if (op == null) {
            throw new IllegalArgumentException("Unknown operation: " + symbol);
        }
        return op;
    }

    // 연산 결과를 포맷팅하는 메서드
    static String formatOperation(String symbol, double x, double y, double result) {
        return String.format("%.2f %s %.2f = %.2f", x, symbol, y, result);
    }
}

enum BasicOperation implements Operation {
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

    BasicOperation(String symbol) {
        this.symbol = symbol;
        OperationHelper.registerOperation(symbol, this);
    }

    @Override
    public String getSymbol() {
        return symbol;
    }

    // 공통 기능을 사용하는 메서드
    public String formatOperation(double x, double y) {
        return OperationHelper.formatOperation(symbol, x, y, apply(x, y));
    }
}

enum ExtendedOperation implements Operation {
    EXP("^") {
        public double apply(double x, double y) { return Math.pow(x, y); }
    },
    REMAINDER("%") {
        public double apply(double x, double y) { return x % y; }
    };

    private final String symbol;

    ExtendedOperation(String symbol) {
        this.symbol = symbol;
        OperationHelper.registerOperation(symbol, this);
    }

    @Override
    public String getSymbol() {
        return symbol;
    }

    // 공통 기능을 사용하는 메서드
    public String formatOperation(double x, double y) {
        return OperationHelper.formatOperation(symbol, x, y, apply(x, y));
    }
}

public class OperationExample {
    public static void main(String[] args) {
        double x = 10, y = 5;

        // 기호로 연산 찾기
        try {
            Operation op = OperationHelper.fromSymbol("+");
            System.out.println(op.formatOperation(x, y));

            op = OperationHelper.fromSymbol("^");
            System.out.println(op.formatOperation(x, y));

            // 존재하지 않는 연산 기호 시도
            op = OperationHelper.fromSymbol("&");
        } catch (IllegalArgumentException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}
```

# 결론
- 열거 타입 자체는 확장할 수 없지만, `인터페이스`와 그 인터페이스를 구현하는 기본 열거 타입을 함께 사용해 같은 효과를 낼 수 있다.
    - 클라이언트는 해당 인터페이스를 구현해 자신만의 열거 타입을 만들 수 있다.
- API가 인터페이스 기반으로 작성되었다면, 기본 열거 타입의 인스턴스가 쓰이는 모든 곳을 새로 확장한 열거 타입의 인스턴스로 **대체해 사용**할 수 있다.
```java
interface Operation {
    double apply(double x, double y);
    String getSymbol();
}

enum BasicOperation implements Operation {
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

    BasicOperation(String symbol) {
        this.symbol = symbol;
    }

    @Override
    public String getSymbol() {
        return symbol;
    }
}

enum ExtendedOperation implements Operation {
    EXP("^") {
        public double apply(double x, double y) { return Math.pow(x, y); }
    },
    REMAINDER("%") {
        public double apply(double x, double y) { return x % y; }
    };

    private final String symbol;

    ExtendedOperation(String symbol) {
        this.symbol = symbol;
    }

    @Override
    public String getSymbol() {
        return symbol;
    }
}

class Calculator {
    public static void performOperations(Collection<? extends Operation> operations, double x, double y) {
        for (Operation op : operations) {
            System.out.printf("%.2f %s %.2f = %.2f%n", 
                              x, op.getSymbol(), y, op.apply(x, y));
        }
    }
}

public class OperationExample {
    public static void main(String[] args) {
        double x = 10, y = 5;

        System.out.println("Basic operations:");
        Calculator.performOperations(Arrays.asList(BasicOperation.values()), x, y);

        System.out.println("\nExtended operations:");
        Calculator.performOperations(Arrays.asList(ExtendedOperation.values()), x, y);

        System.out.println("\nMixed operations:");
        Calculator.performOperations(Arrays.asList(
            BasicOperation.PLUS,
            ExtendedOperation.EXP,
            BasicOperation.MINUS,
            ExtendedOperation.REMAINDER
        ), x, y);
    }
}
```


