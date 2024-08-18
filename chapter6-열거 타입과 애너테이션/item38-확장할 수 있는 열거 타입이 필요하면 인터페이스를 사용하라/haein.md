
# 요약
---

## 타입 안전 열거 타입
- 거의 모든 상황에서 타입 안전 열거 패턴보다 열거 타입이 우수하지만 열거타입은 확장이 불가능하다 
- 대부분 상황에서 열거 타입을 확장하는 것은 좋지 않다
    - 확장한 원소는 기반 타입으로 취급하지만, 그 반대가 성립하지 않으면 이상함
    - 기반 타입과 확장 타입을 모두 순회할 방법이 마땅치 않다
    - 확장성을 높이려면 설계와 구현이 복잡해진다 
- 그런데 열거 타입의 연산 코드를 확장하는 경우 합리적

```java
public interface Operation {
    double apply(double x, double y);
}

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
- 연산 코드용 인터페이스를 정의하고 열거 타입이 이를 구현하도록 한다 
- 인터페이스는 확장할 수 있으므로 이를 연산의 타입으로 사용하면 된다

```java
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
```
- Operation을 구현한 또 다른 열거 타입인 ExtenedOperation 이
BasicOperation 을 대체할 수 있고, 기존 연산을 쓰는 곳이면 어디든 사용 가능


## 타입 수준으로 확장된 열거 타입을 사용하는 경우

```java
public static void main(String[] args) {
    double x = Double.parseDouble(args[0]);
    double y = Double.parseDouble(args[1]);
    test(ExtendedOperation.class, x, y);
}


private static <T extends Enum<T> & Operation> void test(
            Class<T> opEnumType, double x, double y) {
        for (Operation op : opEnumType.getEnumConstants())
            System.out.printf("%f %s %f = %f%n",
                    x, op, y, op.apply(x, y));
    }
```
- `ExtendedOperation.class` 리터럴을 넘겨 확장된 연산을 알려줌
- <T extends Enum<T> & Operation> 는 열거 타입이며 Operation 을 구현해야 한다는 뜻, 열거 타입이어야 순회할 수 있고, Operation 이어야 연산을 수행할 수 있음 



## 한정적 와일드카드 타입인 Collection<? extends Operation> 을 사용하는 경우  

```java
public static void main(String[] args) {
        double x = Double.parseDouble(args[0]);
        double y = Double.parseDouble(args[1]);
        test(Arrays.asList(ExtendedOperation.values()), x, y);
    }
    private static void test(Collection<? extends Operation> opSet,
                             double x, double y) {
        for (Operation op : opSet)
            System.out.printf("%f %s %f = %f%n",
                    x, op, y, op.apply(x, y));
    }
```
- 여러 구현 타입의 연산을 조합하여 호출할 수 있으므로 test() 가 더 유연해짐 


## 단점
- 열거 타입끼리 구현을 상속할 수 없음
- 아무 상태에 의존하지 않는다면 디폴트 구현을 사용하여 인터페이스에 추가할 수 있음
- 상태에 의존하는 메서드는 인터페이스를 구현한 모든 열거 타입에 추가해야 함 
- 공유하는 기능이 많다면 도우미 클래스나 정적 도우미 메서드로 분리하는 방식으로 중복 코드를 없앨 수 있다 
