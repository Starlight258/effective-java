## ✍️ 개념의 배경

클래스 생성자(constructor)

- 생성자는 new 를 이용해 객체가 생성될 때 가장 먼저 호출된다.
- 생성자를 명시하지 않은 경우 컴파일러에서 기본 생성자를 자동으로 추가한다.
- 객체의 인스턴스를 만드는 가장 기본적인 방법이다.

# 요약

---

## 정적 필드와 메서드만을 담은 클래스

- 특정 자료 타입에 관한 메서드를 모아놓고 싶을 때 ex) java.lang.Math, java.util.Arrays
- 객체를 생성하는 정적 메소드를 모아놓고 싶을 때 ex) java.Collections
- final class 와 관련한 메소드를 모아놓고 싶을 때 ex) junit 의 StringUtils

```java
public final class StringUtils {

    private static final char[] DIGITS = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

    private StringUtils() {
        // Prevent Instantiation
    }

    public static String sha1Hex(String data) {
        if (data == null) {
            throw new IllegalArgumentException("data must not be null");
        }

        byte[] bytes = digest("SHA1", data);

        return toHexString(bytes);
    }
  // .....
}
```

이런  소위 “유틸리티 클래스” 는 인스턴스화 되어서는 안된다!

## 추상 클래스로 만드는 것만으론 인스턴스화를 막을 수 없다

- 추상 클래스는 객체를 만들 수 없다. 그럼 추상 클래스를 사용하면 되지 않을까?

```java
public abstract class Animal{
	// .....
} 

// ...

public class Dog extends Animal{
 // ..

	public Dog(){}
}

Dog puppy = new Dog();
```

## 유틸리티 클래스와 생성자

- private 생성자를 사용하여 인스턴스화 되는 것을 막자.
- 혹시나 모를 예외를 방지하기 위해 AssertionError 를 던지자.

```java
public class UtilityClass(){
	private UtilityClass(){
		throw new AssertionError();
}
```

## 개념 관련 경험

## 이해되지 않았던 부분

### 

## ⭐️ **번외: 추가 조각 지식**