# 22. 인터페이스는 타입을 정의하는 용도로만 사용하라
### 인터페이스는 타입을 정의하는 용도로 사용해야한다.
- 타입 : **데이터의 종류**와 그 데이터로 수행할 수 있는 **연산** 정의
- 인터페이스는 타입을 정의한다 = 인터페이스는 객체가 어떤 메서드를 가져야 하는지 명시한다.
    - **자신을 구현한 클래스의 인스턴스를 참조할 수 있는 타입** 역할
- 클래스가 어떤 **인터페이스를 구현**한다는 것은 자신의 인스턴스로 **무엇을 할 수 있는지 클라이언트에 얘기**해주는 것
```java
public interface Readable {
    String read();
}

public class Book implements Readable {
    public String read() {
        return "Reading a book...";
    }
}
```
### 상수 인터페이스 안티패턴은 인터페이스를 잘못 사용한 예다.
- 인터페이스는 타입을 정의하는 용도로 사용해야한다.
    - 단순히 상수를 그룹화하거나 유틸리티 메서드를 모아두는 용도가 아니다.
- **클래스 내부에 사용하는 상수는 외부 인터페이스가 아니라 내부 구현에 해당**한다.
    - 상수 인터페이스를 구현하는 것은 내부 구현을 클래스의 API로 노출하는 것과 같다.
    - 클라이언트 코드가 내부 구현에 해당하는 상수들에 종속되게 된다.
    - final이 아닌 클래스가 상수 인터페이스를 구현하면 모든 하위 클래스에서 상수에 접근할 수 있어 이름공간이 오염된다.
```java
// 코드 22-1 상수 인터페이스 안티패턴 - 사용금지! (139쪽)  
public interface PhysicalConstants {  
    // 아보가드로 수 (1/몰)  
    static final double AVOGADROS_NUMBER   = 6.022_140_857e23;  
  
    // 볼츠만 상수 (J/K)    
    static final double BOLTZMANN_CONSTANT = 1.380_648_52e-23;  
  
    // 전자 질량 (kg)    
    static final double ELECTRON_MASS      = 9.109_383_56e-31;  
}
```

## 상수를 올바르게 공개하는 방법
### 1. **특정 클래스나 인터페이스와 강하게 연관된 상수라면 그 클래스나 인터페이스 자체에 추가**해야 한다.
- 모든 숫자 기본 타입의 박싱 클래스가 대표적이다.
    - ex) Integer나 Double에 선언된 MIN_VALUE와 MAX_VALUE
```java
@jdk.internal.ValueBased  
public final class Integer extends Number  
        implements Comparable<Integer>, Constable, ConstantDesc {  
    /**  
     * A constant holding the minimum value an {@code int} can  
     * have, -2<sup>31</sup>.  
     */    
     @Native public static final int   MIN_VALUE = 0x80000000;  
  
    /**  
     * A constant holding the maximum value an {@code int} can  
     * have, 2<sup>31</sup>-1.  
     */    
     @Native public static final int   MAX_VALUE = 0x7fffffff;
```
> 해당 상수가 클래스와 연관성을 가져 맥락 안에서 의미를 가진다.

### 2. **열거 타입(Enum)** 으로 나타내기 적합한 상수라면 열거 타입으로 만들어 공개하면 된다.
> 열거 타입은 명확한 의미를 전달하며 관련 있는 상수끼리 그룹화된다.

### 3. 그것도 아니라면, 인스턴스화할 수 없는 **유틸리티 클래스에 담아 공개**하자.
```java
// 코드 22-2 상수 유틸리티 클래스 (140쪽)  
public class PhysicalConstants {  
  private PhysicalConstants() { }  // 인스턴스화 방지  
  
  // 아보가드로 수 (1/몰)  
  public static final double AVOGADROS_NUMBER = 6.022_140_857e23;  
  
  // 볼츠만 상수 (J/K)  
  public static final double BOLTZMANN_CONST  = 1.380_648_52e-23;  
  
  // 전자 질량 (kg)  
  public static final double ELECTRON_MASS    = 9.109_383_56e-31;  
}
```
관련 상수를 논리적으로 그룹화하고, 클래스명이 네임스페이스 역할을 하여 용도가 명확하다.
> 인터페이스는 계약을 정의하는 용도로만 사용하고, 상수를 모아두는 유틸리티 클래스를 이용해 캡슐화하자.

숫자 리터럴에 사용한 밑줄(`_`)은 값에는 아무런 영향을 주지 않으면서 읽기 훨씬 편하게 해준다.
> 고정 소수점 수든 부동소수점 수든 5자리 이상이라면 밑줄을 사용하는 것을 고려해보자.
> 십진수 리터럴도 밑줄을 사용해 세자릿씩 묶어주는게 좋다.

유틸리티 클래스에 정의된 상수를 클라이언트에서 사용하려면 클래스 이름까지 함께 명시해야 한다.
유틸리티 클래스의 상수를 빈번히 사용한다면 `static import`하여 클래스 이름은 생략할 수 있다.
```java
import static effectivejava.chapter4.item22.constantutilityclass.PhysicalConstants.*;

public class Test {
	double atoms(double mols){
		return AVOGADROS_NUMBER * mols;*
	}
}
```

> 단순히 상수를 공개할 수 있냐 없냐가 아닌, 인터페이스의 용도(타입 정의)와 상수가 클래스 안에서 가지는 연관성, 맥락을 고려하여
> 방법을 선택하자.

## 결론
**인터페이스는 타입을 정의하는 용도로만 사용**해야 한다.
**상수 공개용 수단으로 사용하지 말자.**
