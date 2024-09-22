## 요약


### 문자열은 열거 타입을 대신하기 적절치 않다.

### 문자열은 혼합 타입을 대신하기 적절치 않다.

```java
String compoundKey = className + "#" + i.next();
```

- 구분자와 데이터의 요소에 포함되면 처리하기 귀찮아진다
- 이는 적절한 `equals`, `toString`, `compareTo` 메서드를 제공할 수 없고 `String` 이 제공하는 기능에만 의존하게 된다
- 차라리 전용 클래스를 새로 선언하는 게 낫다

### 문자열은 권한을 표현하기에 적절치 않다.

- 스레드 지역변수 기능을 설계할 때, 클라이언트가 제공한 문자열 키로 스레드를 식별한다고 해보자
- 문자열 키로 스레드별 지역변수를 식별하게 되면 스레드 구분용 키가 전역 이름 공간에서 공유되어 같은 변수를 공유하게 될 수도 있다
- 문자열 대신 위조할 수 없는 키를 사용하여 해결한다


```java
public class ThreadLocal {
	private ThreadLocal(){};

	public static class Key{
		Key(){};
	}

	public static Key getKey(){
		return new Key(){};
	}

	public static void set(Key key, Object value);
	public static Object get(Key key);
}
```
- Set, Get 을 인스턴스 메서드로 바꾸자
- 그러면 key 는 스레드 지역변수를 구분하기 위한 키가 아니라, 그 자체가 스레드 지역변수가 된다

```java
public class ThreadLocal<T> {
	private ThreadLocal(){;
	public void set(T value);
	public T get();
}
```
- 매개변수화 타입을 이용해 타입 안전하게 만들면 실제 `java.lang.ThreadLocal` 과 흡사하다