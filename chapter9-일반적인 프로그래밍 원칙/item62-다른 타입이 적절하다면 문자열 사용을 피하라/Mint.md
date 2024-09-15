# 62. 다른 타입이 적절하다면 문자열 사용을 피하라
## 문자열을 사용하지 않아야 할 사례
### 문자열은 다른 값 타입을 대신하기에 적합하지 않다.
- 입력 데이터가 문자열이 아닌 수치형이라면 int, float, BigInteger 등 적당한 수치 타입으로 변환해야 한다.
- 예/아니오 질문의 답이라면 적절한 열거 타입이나 boolean으로 변환해야 한다.
> 기본 타입이든 참조 타입이든 적절한 값 타입이 있다면 그것을 사용하고, 없다면 새로 하나 작성하라.

### 문자열은 열거 타입과 혼합 타입을 대신하기에 적합하지 않다.
- 열거 타입은 문자열에 비해 타입 안전하다.
- 혼합 타입 사용시 String이 제공하는 기능에만 의존해야 한다.
    - 차라리 전용 클래스를 새로 만드는 것이 낫다.
### 문자열은 권한을 표현하기에 적합하지 않다.
#### 문자열 키
```java
public class ThreadLocal {
    private ThreadLocal() {} // 객체 생성 방지

    public static void set(String key, Object value);

    public static Object get(String key);
}
```
- 클라이언트가 같은 키를 사용한다면 잘못된 결과가 반환되고 보안에도 취약하다.
> 문자열 대신 위조할 수 없는 키를 사용하면 된다. (전용 클래스)

```java
public class ThreadLocal {
    private ThreadLocal() {} // 객체 생성 방지

	public static class Key {
		Key() {}
	}

    public static Object get(Key key);

    public static void set(Key key, Object value);
}
```
- `set`과 `get`은 정적 메서드일 이유가 없으니 인스턴스 내에서 사용하도록 `인스턴스 메서드`로 바꾸자.
- `key 클래스`를 별도로 만들 필요가 없이, `ThreadLocal` 자체가 그 자체가 스레드 지역변수가 된다.

#### 전용 클래스 사용 - 매개변수화 타입 선언
```java
public final class ThreadLocal<T> {
    private ThreadLocal() {} // 객체 생성 방지

    public T get() {
    }

    public void set(T value) {
    }
}
```
- 타입 안전하다.
- 빠르고 우아하다.

## 결론
- 더 적합한 데이터 타입이 있거나 새로 작성할 수 있다면, 문자열을 쓰고 싶은 유혹을 뿌리쳐라.
- 문자열은 잘못 사용하면 번거롭고, 덜 유연하고, 느리고, 오류 가능성도 크다.
    - 잘못 사용하는 흔한 예시로 `기본 타입`, `열거 타입`, `혼합 타입`이 있다.

