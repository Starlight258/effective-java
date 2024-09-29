# 17. 변경 가능성을 최소화하라
## 불변 클래스
- 인스턴스의 내부 값을 수정할 수 없는 클래스
- String, 내부 값으로 박싱된 클래스들, BigInteger, BigDecimal....
- 블변 클래스는 가변 클래스보다 설계하고 구현하고 사용하기 쉬우며, 오류가 생길 여지도 적고 훨씬 안전하다.

### 클래스를 불변으로 만드는 방법
- **1. 객체의 상태를 변경하는 메서드(변경자-setter)를 제공하지 않는다.**
- **2. 클래스를 확장할 수 없도록 한다.**
    - 하위 클래스에서 상위 클래스의 불변 조건을 깨뜨릴 수 있다.
    - 하위 클래스에서 가변 필드를 추가하거나 오버라이드하여 불변성을 해칠 수 있다.
- **3. 모든 필드를 final로 선언한다.**
- **4. 모든 필드를 private으로 선언한다.**
    - 외부에서 접근하지 못하게 하면 내부 구현 변경시에 api는 변경하지 않아도 된다.
- **5. 자신 외에는 내부의 가변 컴포넌트에 접근할 수 없도록 한다.**
    - 컴포넌트 : 독립적으로 동작할 수 있는 모듈, 재사용, 상호작용 가능
        - 클래스의 필드, 내부 클래스, 컬렉션
    - 클라이언트가 제공한 객체 참조를 필드가 가져서도 안되고, 접근자 메서드가 필드를 그대로 반환해서도 안된다.
    - **방어적 복사**를 수행하자.

- 예시 코드(불변 복소수 클래스)
```java
package effectivejava.chapter4.item17;  
  
// 코드 17-1 불변 복소수 클래스 (106-107쪽)  
public final class Complex {  
    private final double re;  
    private final double im;  
  
    public static final Complex ZERO = new Complex(0, 0);  
    public static final Complex ONE  = new Complex(1, 0);  
    public static final Complex I    = new Complex(0, 1);  
  
    public Complex(double re, double im) {  
        this.re = re;  
        this.im = im;  
    }  
  
    public double realPart()      { return re; }  
    public double imaginaryPart() { return im; }  
  
    public Complex plus(Complex c) {  
        return new Complex(re + c.re, im + c.im);  
    }  
  
    // 코드 17-2 정적 팩터리(private 생성자와 함께 사용해야 한다.) (110-111쪽)  
    public static Complex valueOf(double re, double im) {  
        return new Complex(re, im);  
    }  
  
    public Complex minus(Complex c) {  
        return new Complex(re - c.re, im - c.im);  
    }  
  
    public Complex times(Complex c) {  
        return new Complex(re * c.re - im * c.im,  
                re * c.im + im * c.re);  
    }  
  
    public Complex dividedBy(Complex c) {  
        double tmp = c.re * c.re + c.im * c.im;  
        return new Complex((re * c.re + im * c.im) / tmp,  
                (im * c.re - re * c.im) / tmp);  
    }  
  
    @Override public boolean equals(Object o) {  
        if (o == this)  
            return true;  
        if (!(o instanceof Complex))  
            return false;  
        Complex c = (Complex) o;  
  
        // == 대신 compare를 사용하는 이유는 63쪽을 확인하라.  
        return Double.compare(c.re, re) == 0  
                && Double.compare(c.im, im) == 0;  
    }  
    @Override public int hashCode() {  
        return 31 * Double.hashCode(re) + Double.hashCode(im);  
    }  
  
    @Override public String toString() {  
        return "(" + re + " + " + im + "i)";  
    }  
}
```
- setter는 제공하지 않는다.
- 사칙연산 메서드들이 인스턴스 자신은 수정하지 않고 새로운 인스턴스를 만들어서 반환한다.
    - 함수형 프로그래밍 : 피연산자에 함수를 적용해 그 결과를 반환하지만, 피연산자 자체는 그대로인 프로그래밍 패턴
    - 절차적 혹은 명령형 프로그래밍 : 메서드에서 피연산자인 자신을 수정해 자신의 상태가 변한다.
- 사칙연산 메서드에서 동사(add) 대신 전치사(plus, minus)를 사용하여 객체의 값을 직접 변경하지 않고 새로운 인스턴스를 만들어 반환함을 암시한다.

### 성능을 위해 불변 클래스 완화하기
- 불변 클래스 규칙 목록에 따르면 모든 필드가 final이고 어떤 메서드도 그 객체를 수정할 수 없어야 한다.
- 성능을 위해 **"외부에 비치는 필드의 값을 변경할 수 없다"** 로 수정해도 된다.
    - 계산 비용이 큰 값을 처음 쓰일 때 계산하여 final이 아닌 필드에 캐시해 놓을 수 있다.

## 불변 객체는 단순하다.
- 불변 객체는 생성된 시점의 상태를 파괴될 때까지 그대로 간직한다.
- 가변 객체는 임의의 복잡한 상태에 놓일 수 있어 믿고 사용하기 어려울 수도 있다.

### 불변 객체는 근본적으로 스레드 안전하다.
- 따로 동기화할 필요가 없다.
    - 여러 스레드가 동시에 사용해도 훼손되지 않는다.
- 불변 객체는 **안심하고 공유**할 수 있다.
- **불변 클래스라면 한번 만든 인스턴스를 최대한 재활용하자.**
    - 자주 쓰이는 값들을 **상수**로 제공하자.
    - **자주 사용되는 인스턴스를 캐싱**하여 같은 인스턴스를 중복 생성하지 않게 해주는 **정적 팩토리 메서드**를 제공하자.
        - 메모리 사용량과 가비지 컬렉션 비용이 줄어든다.
```java
Integer a = Integer.valueOf(100);
Integer b = Integer.valueOf(100);
System.out.println(a == b);  // true, 

Boolean a = Boolean.valueOf(true);
Boolean b = Boolean.valueOf(true);
System.out.println(a == b);  // true

BigInteger a = BigInteger.valueOf(10);
BigInteger b = BigInteger.valueOf(10);
System.out.println(a == b);  // true
```
Integer는 -128\~127 사이의 정수는 캐시되어 재사용된다.
Boolean은 true, false값은 항상 같은 인스턴스를 반환한다.
BigInteger는 자주 사용되는 작은 값들(-16\~16)을 캐시한다.

> 새로운 클래스를 설계할때 public 생성자 대신 정적 팩토리 메서드를 만들어 두면, 필요에 따라 캐싱 기능을 덧붙일 수 있어 좋다.

- 불변 객체는 clone 메서드나 복사 생성자(가변 객체의 독립적인 복사본 만들 때 사용)를 제공하지 않는 게 좋다.
    - 방어적 복사도 필요 없다.
    - 복사해봤자 원본과 동일하기 때문이다.
> String의 복사 생성자는 되도록 사용하지 말자. 잘못 만들어진 것이다.

### 불변 객체는 자유롭게 공유할 수 있음은 물론, 불변 객체끼리는 내부 데이터를 공유할 수 있다.
- 필드가 배열이라 가변일지라도, 불변 객체는 내부 데이터를 변경하지 않기 때문에 내부 데이터를 공유해도 된다.
- BigInteger에서 크기를 나타내는 int 배열의 참조를 서로 공유한다.

### 객체를 만들 때 다른 불변 객체들을 구성요소로 사용하면 이점이 많다.
- 구조가 복잡하더라도 불변식을 유지하기 훨씬 수월하다.
    - map의 key와 집합의 원소로 사용하기 좋다.

### 불변 객체는 그 자체로 실패 원자성을 제공한다.
- **실패 원자성**: 메서드 실행 중 예외가 발생하더라도 객체의 상태가 메서드 호출 전의 상태로 유지되는 특성
- 불변 객체는 생성된 이후로 상태가 변하지 않기 때문에 작업이 실패하더라도 일관된 상태를 유지한다.
    - 불변 객체는 항상 유효한 상태를 유지하므로 실패 원자성을 제공한다.
- 가변 객체
```java
public class MutablePerson {
    private String name;
    private int age;

    public void updatePerson(String newName, int newAge) {
        this.name = newName;  /
        if (newAge < 0) throw new IllegalArgumentException("Age cannot be negative");
        this.age = newAge;    // 예외 발생 시 객체는 불일치 상태가 될 수 있음
    }
}
```
- 불변 객체 (실패 원자성을 갖는다)
```java
public final class ImmutablePerson {
    private final String name;
    private final int age;

    public ImmutablePerson(String name, int age) {
        if (age < 0) throw new IllegalArgumentException("Age cannot be negative");
        this.name = name;
        this.age = age;
    }

    public ImmutablePerson updatePerson(String newName, int newAge) {
        return new ImmutablePerson(newName, newAge);  // 예외가 발생하더라도 원본은 변경되지 않음
    }
}
```

## 불변 클래스의 단점
### 값이 다르면 반드시 독립된 객체로 만들어야 한다.
- 불변 객체 vs 가변 객체
    - 불변 객체 BigInteger는 백만 비트 중 한 비트를 바꾸기 위해 또다른 백만 비트짜리 인스턴스를 만들어야한다.
    - 가변 객체 BigSet은 원하는 비트 하나만 상수 시간 안에 바꿀 수 있다.
- 불변 객체를 만들기 위해 단계적으로 만들어지는 객체들이 버려진다면 성능 문제가 발생한다.

### 해결 방법 : 다단계 연산을 예측하여 기본 기능으로 제공하면 된다.
- 각 단계마다 객체를 생성할 필요가 없다.
- BigInteger는 **가변 동반 클래스**를 package-private으로 두어 사용한다.
    - 중간 결과는 가변 동반 클래스로 처리하고, 최종 결과만 불변 클래스로 변환하여 반환한다.
    - 중간 연산에서 새 객체 생성을 줄여 성능을 개선할 수 있다.
```java
public class BigInteger {
    private final int[] magnitude;
    private final int signum;

    // 복잡한 연산 메서드
    public BigInteger complexOperation() {
        MutableBigInteger result = new MutableBigInteger(this);
        result.operation1();
        result.operation2();
        // 최종 결과를 불변 BigInteger로 변환
        return result.toBigInteger();
    }
}
```
- String도 가변 동반 클래스인 StringBuilder를 사용하여 불필요한 String 객체 생성을 줄인다.
```java
StringBuilder sb = new StringBuilder();
for (int i = 0; i < 1000; i++) {
    sb.append("a");  // StringBuilder 사용
}
String result = sb.toString();  // 최종 결과를 String으로 변환
```

## 불변 클래스의 상속을 막는 방법
### 1. final 클래스로 선언한다.
```java
public final class Complex {  
    private final double re;  
    private final double im;  
  
    public static final Complex ZERO = new Complex(0, 0);  
    public static final Complex ONE  = new Complex(1, 0);  
    public static final Complex I    = new Complex(0, 1);  
  
    public Complex(double re, double im) {  
        this.re = re;  
        this.im = im;  
    }
}
```

### 2. 모든 생성자를 private 혹은 package-private으로 만들고 public 정적 팩토리 메서드를 제공한다.
```java
public final class Complex {  
    private final double re;  
    private final double im;  
  
    private Complex(double re, double im) {  
        this.re = re;  
        this.im = im;  
    }

	public static Complex valueOf(double re, double im){
		return new Complex(re, im);
	}
}
```
- 정적 팩토리를 통해서만 인스턴스 얻기가 가능하다.
- 생성자를 private으로 둘 경우 상속 자체가 불가능하고, package-private으로 둘 경우 다른 패키지에서 상속이 불가능하다.
- package-private 구현 클래스를 원하는 만큼 만들어 활용이 가능하므로 1번 방법보다 유연하다.
- 정적 팩토리를 사용하므로 후에 캐싱도 가능하다.

#### BigInteger와 BigDecimal은 상속을 받을 수 있어 불변성이 깨질 수 있다.
- 믿을 수 없는 클라이언트로부터 BigInteger나 BigDecimal을 받을 경우 가변이라 가정하고 방어적으로 복사해 사용해야 한다.

#### 직렬화시 불변이 깨질 수 있다.
- Serializable을 구현한 불변 클래스의 내부에 **가변 객체**를 참조하는 필드가 있다면?
    - 직렬화(객체->바이트스트림)시 내부 가변 객체의 참조를 그대로 직렬화한다.
    - 역직렬화시 공격자가 이 **참조를 조작해서 불변성을 깨뜨릴 수 있다.**
- readObject나 readResolve 메서드를 반드시 제공하자.
    - **readObject** : 객체의 역직렬화 과정 커스터마이즈
```java
private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
    in.defaultReadObject();
    // 내부 가변 객체에 대한 방어적 복사 수행
    this.mutableField = new ImmutableCopy(this.mutableField);
}
```
- **readResolve** : 역직렬화 후 객체 참조를 다른 객체로 대체(역직렬화된 객체 대신 사용)
```java
private Object readResolve() {
    // 안전한 불변 인스턴스 반환
    return new SafeVersion(this);
}
```
- 또는**ObjectOuputStream.writeUnshared**와 **ObjectInputStream.readUnshared**를 사용해야한다.
    - 같은 객체라도 매번 새로운 인스턴스로 처리하여 반환한다.
- 그렇지 않으면 공격자가 가변 인스턴스를 만들어 낼 수 있다.

## 결론
- **클래스는 꼭 필요한 경우가 아니라면 불변이어야 한다.**
    - getter가 있다고 해서 무조건 setter를 만들지는 말자.
    - 단순한 값 객체는 항상 불변으로 만들자.
    - String과 BigInteger처럼 무거운 값 객체도 불변으로 만들 수 있는지 고심하자.
        - 성능을 고려하여 불변 클래스와 쌍을 이루는 **가변 동반 클래스**를 public으로 제공해도 된다.
- 불변으로 만들 수 없는 클래스라도 **변경할 수 있는 부분을 최대한으로 줄이자.**
    - 객체가 가질 수 있는 상태의 수를 줄이면 그 객체를 예측하기 쉬워지고 오류가 생길 가능성이 줄어든다.
    - 꼭 변경해야 할 필드를 뺀 나머지 모두를 **final**로 선언하자.
    - **다른 합당한 이유가 없다면 모든 필드는 private final 이어야 한다.**
- **생성자는 불변식 설정이 모두 완료된, 초기화가 완벽히 끝난 상태의 객체를 생성해야 한다.**
    - 확실한 이유가 없다면 생성자와 정적 팩터리 외에는 그 어떤 초기화 메서드도 public으로 제공해서는 안된다.
        - 객체의 초기화는 생성 시점에만 일어나는 것이 상태가 일관적이고 예측하기 쉽다.
    - 상태를 다시 초기화하는 메서드도 public으로 제공해서는 안된다.
        - 새로운 상태가 필요하다면 새 객체를 생성하자.
