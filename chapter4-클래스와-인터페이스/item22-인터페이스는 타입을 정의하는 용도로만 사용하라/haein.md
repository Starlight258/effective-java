## ✍️ 개념의 배경

상수 인터페이스란?

메서드 없이 static final 필도로만 가득 찬 인터페이스

```java
public interface PhysicalConstants {
	static final double AVO_NUMBER = 6.022_140_857e23;
	static final double BOLTZM_CONSTANT = 1.380_648_52e-23;
	static final double ELECTRON_MASS = 9.109_383_56e-31;
}
```

# 요약

---

### 상수 인터페이스는 안티패턴

- 클래스 내부에서 사용하는 상수는 내부 구현에 해당
    
    —> 상수 인터페이스를 구현하는 것은 내부 구현을 노출하는 행위 (캡슐화 x)
    
- 클라이언트 코드가 내부 구현에 해당하는 상수들에 종속하게 될수있음
    
    —> 상수들을 쓰지않게 되더라도 바이너리 호환성을 위해 여전히 구현하고 있어야함
    
- 인터페이스 목적에 부합x

### 대안

특정 클래스나 인터페이스와 강하게 연관된 상수라면, 클래스나 인터페이스 자체에 추가

```java
public class MyClass {
	private static final int MAX_VALUE = 100_000_000;
	,,,,
}
```

상수 유틸리티 클래스

```java
public class PhysicalConstants {
	private PhysicalConstants() {}
	
	public static final double AVO_NUMBER = 6.022_140_857e23;
	public static final double BOLTZM_CONSTANT = 1.380_648_52e-23;
	public static final double ELECTRON_MASS = 9.109_383_56e-31;
}
```

