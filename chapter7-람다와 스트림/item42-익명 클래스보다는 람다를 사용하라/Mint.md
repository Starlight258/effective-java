# 42. 익명 클래스보다는 람다를 사용하라
## 함수 타입 표현하기
### 1. 익명 클래스
```java
Collections.sort(words, new Comparator<String>(){

	public int compare(String s1, String s2){
		return Integer.compare(s1.length(), s2.length());
	}
})
```
- 코드가 너무 길기 때문에 함수형 프로그래밍에 적합하지 않다.

### 2. 함수형 인터페이스
```java
Collections.sort(words, (s1, s2)-> Integer.compare(s1.length(), s2.length()));
```
- **단 하나의 추상 메서드만을 가진 인터페이스**
    - `람다 표현식`을 직접 사용할 수 있다.
- 익명 클래스보다 코드는 훨씬 간결하다.
- 반환 타입을 컴파일러가 추론하는데, 모른다면 직접 명시해야한다.
    - **타입을 명시해야 코드가 더 명확할때를 제외하고는, 람다의 모든 매개변수 타입은 생략하자.**
- `Runnable`, `Callable`, `Comparator`

#### 비교자 생성 메서드를 사용하면 더 간결하게 만들 수 있다.
```java
Collections.sort(words, comparingInt(String::length));
```

#### List.sort() 를 사용하면 더 짧아진다.
```java
words.sort(comparingInt(String::length));
```


### 열거 타입에 람다를 활용하면 쉽게 구현할 수 있다.
```java
// 코드 42-4 함수 객체(람다)를 인스턴스 필드에 저장해 상수별 동작을 구현한 열거 타입 (256-257쪽)  
public enum Operation {  
    PLUS  ("+", (x, y) -> x + y),  
    MINUS ("-", (x, y) -> x - y),  
    TIMES ("*", (x, y) -> x * y),  
    DIVIDE("/", (x, y) -> x / y);  
  
    private final String symbol;  
    private final DoubleBinaryOperator op;  
  
    Operation(String symbol, DoubleBinaryOperator op) {  
        this.symbol = symbol;  
        this.op = op;  
    }  
  
    @Override public String toString() { return symbol; }  
  
    public double apply(double x, double y) {  
        return op.applyAsDouble(x, y);  
    }  
  
    // 아이템 34의 메인 메서드 (215쪽)  
    public static void main(String[] args) {  
        double x = Double.parseDouble(args[0]);  
        double y = Double.parseDouble(args[1]);  
        for (Operation op : Operation.values())  
            System.out.printf("%f %s %f = %f%n",  
                    x, op, y, op.apply(x, y));  
    }  
}
```
- `DoubleBinaryOperator` : double  타입 인수 2개를 받아 double 타입 결과를 돌려주는 함수형 인터페이스

## 람다 주의할 점
### 람다는 이름이 없고 문서화도 못한다.
- 코드 자체로 동작이 명확하게 설명되지 않거나, 코드 줄 수가 많아지면 람다를 쓰지 말아야 한다.
    - 람다는 한 줄일때 가장 좋고, 길어야 세 줄 안에 끝내는것이 좋다.
    - 세 줄을 넘어가면 가독성이 나빠진다.
> 람다가 길거나 읽기 어렵다면, 더 간단히 줄여보거나 람다를 쓰지 않는 쪽으로 리팩토링하자.

### 열거 타입 생성자 안의 람다는 열거 타입의 인스턴스 멤버에 접근할 수 없다.
- 람다 표현식은 컴파일 시점에 처리된다.
    - Java 컴파일러는 람다 표현식을 분석하고, 이를 익명 클래스의 인스턴스로 변환한다.
- 인스턴스는 런타임에 만들어지므로, 람다는 인스턴스 멤버에 접근할 수 없다.
- 일반 클래스에서는 람다가 인스턴스 멤버에 접근할 수 있다.
    - 람다 인스턴스가 생성될 때 모든 인스턴스 멤버가 이미 완전히 초기화된 상태이다.
```java
public class RegularClass {
    private int value = 10;

    public void someMethod() {
        Runnable r = () -> System.out.println(value);  // 인스턴스 멤버
        r.run();
    }
}
```
- **열거 타입의 생성자에서 사용되는 람다는 인스턴스 멤버에 접근할 수 없다.**
    - 열거 타입의 상수들은 `클래스 로딩 시점`에 자동으로 생성된다.
    - 상수 생성자 내의 람다는 열거 타입이 완전히 초기화되기 전에 정의된다.
    - 이 시점에 인스턴스 멤버에 접근하면 초기화되지 않은 멤버에 접근할 위험이 있어 Java에서 이를 금지한다.
```java
public enum WrongOperation {
    WRONG("Wrong", () -> this.someMethod()); // 컴파일 에러

    private final String name;
    private final Runnable action;

    WrongOperation(String name, Runnable action) {
        this.name = name;
        this.action = action;
    }

    private void someMethod() { // 인스턴스 멤버
        // ...
    }
}
```

## 람다는 함수형 인터페이스에만 쓰인다.
### 함수형 인터페이스가 아닌 곳에는 람다를 쓸 수 없다.
- 추상 클래스의 인스턴스를 만들 때 익명 클래스를 써야 한다.
- 추상 메서드가 여러 개인 인터페이스의 인스턴스를 만들 때는 익명 클래스를 써야 한다.

### 람다는 자신을  참조할 수 없다.
- 람다에서의 this : 바깥 인스턴스를 가리킨다.
- 익명 클래스에서의 this: 바깥 인스턴스를 가리킨다.
> 함수 객체가 자신을 참조해야한다면 익명 클래스를 써야 한다.


### 람다를 직렬화하는 일은 극히 삼가야 한다.
- 익명 클래스처럼 람다도 직렬화 형태가 구현별로(가상머신별로) 다를 수 있기 때문이다.
- 익명 클래스의 인스턴스도 마찬가지다.
> 직렬화해야하는 함수 객체가 있다면(ex) Comparator) private 정적 중첩 클래스의 인스턴스를 사용하자.

## 결론
- `Java8`이 되면서 작은 함수 객체를 구현하는데 적합한 람다가 도입되었다.
- 익명 클래스는 함수형 인터페이스가 아닌 타입의 인스턴스를 만들 때만 사용하라.
