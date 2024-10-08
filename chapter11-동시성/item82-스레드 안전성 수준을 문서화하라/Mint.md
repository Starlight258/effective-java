# 82. 스레드 안전성 수준을 문서화하라
### synchronized는 스레드 안전을 보장하지 않는다
- 메서드 선언에 `synchronized` 한정자를 선언할지는 구현 이슈일 뿐 API에 속하지 않는다.
    - `synchronized`만으로는 그 메서드가 스레드 안전하다고 믿기 어렵다.


## 스레드 안전성 수준
- 멀티 스레드 환경에서도 API를 안전하게 사용하게 하려면 클래스가 지원하는 스레드 안전성 수준을 정확히 명시해야 한다.
### 스레드 안전성
- **불변**
    - 이 클래스의 인스턴스는 상수와 같아서 외부 동기화도 필요 없다.
    - `String`, `Long`, `BigInteger`
- **무조건적 스레드 안전**
    - 이 클래스의 인스턴스는 수정될 수 있으나, 내부에서 충실히 동기화하여 별도의 외부 동기화 없이 동시에 사용해도 안전하다.
    - `AtomicLong`, `ConcurrentHashMap`
- **조건부 스레드 안전**
    - 무조건적 스레드 안전과 같으나, 일부 메서드는 동시에 사용하려면 외부 동기화가 필요하다.
    - `Collections.synchronized` 래퍼 메서드가 반환한 컬렉션 (동기화한 컬렉션)
        - Java 5 이후로는 `java.util.concurrent` 패키지의 동시성 컬렉션(ex) `ConcurrentHashMap`, `CopyOnWriteArrayList` 등)을 사용하는 것이 더 권장된다.
- **스레드 안전하지 않음**
    - 이 클래스의 인스턴스는 수정될 수 있다.
    - 동시에 사용하려면 각각의 메서드 호출을 클라이언트가 선택한 외부 동기화 메커니즘으로 감싸야 한다. (동기화 블록으로 감싼다)
    - `ArrayList`, `HashMap`
- **스레드 적대적**
    - 이 클래스는 모든 메서드 호출을 외부 동기화로 감싸더라도 멀티스레드 환경에서 안전하지 않다.
    - 일반적으로 정적 데이터를 아무 동기화 없이 수정한다.

### 스레드 안전성 어노테이션
- `@Immutable`, `@ThreadSafe`, `@NotThreadSafe`
- `클래스의 스레드 안전성`은 보통 클래스의 문서화 주석에 기재한다.
    - 독특한 특성의 메서드라면 `해당 메서드의 주석`에 기재한다.
- 반환 타입만으로는 명확히 알 수 없는 `정적 팩터리`라면 자신이 반환하는 객체의 스레드 안전성을 반드시 문서화해야 한다.


### 조건부 스레드 안전한 클래스
- 주의해서 문서화해야 한다.
- 어떤 순서로 호출할 때 외부 동기화가 필요한지, 그 순서로 호출하려면 어떤 락 혹은 락들을 얻어야하는지 알려줘야한다.
- 일반적으로 인스턴스 자체를 락으로 얻지만 예외도 있다.
    - ex) `Collections.synchronizedMap`은 컬렉션 뷰를 순회하기 위해 해당 맵을 락으로 사용해서 수동으로 동기화해야한다.

#### 클래스가 외부에서 락을 사용
- 클라이언트에서 일련의 **메서드 호출을 원자적으로 수행**할 수 있다.
- 내부에서 처리하는 고성능 동시성 제어 메커니즘과는 혼용할 수 없게 된다.
    - `ConcurrentHashMap` 같은 동시성 컬렉션과는 함께 사용하지 못한다.
- 클라이언트가 공개된 락을 오래 쥐고 놓지 않는 서비스 거부 공격(`DoS`)을 수행할 수도 있다.
```java
public class MaliciousClient {
    public void blockAccount(BankAccount account) {
        synchronized(account) {
            // 락을 오래 보유하여 다른 스레드의 접근을 막음
            while(true) {
                // 무한 루프
            }
        }
    }
}
```

#### 비공개 락 객체
`synchronized` 메서드 대신 비공개 락 객체를 사용해야 한다. (백엔드 코드 내에서 동기화 수행)
```java
private final Object lock = new Object();

public void foo(){
	synchronized(lock){
	
	}
}
```
- 락 필드는 항상 `final`로 선언하여 교체되지 못하게 하자.
- 비공개 락 객체 관용구는 무조건적 스레드 안전 클래스에서만 사용할 수 있다.
    - 조건부 스레드 안전 클래스에서는 특정 호출 순서에 필요한 락이 무엇인지를 클라이언트에게 알려줘야 하므로 이 관용구를 사용할 수 없다.
- 비공개 락 객체 관용구는 상속용으로 설계한 클래스에 특히 잘 맞는다.
    - **락 분리**: 기반 클래스의 동기화 메커니즘이 하위 클래스와 분리된다.
    - **간섭 방지**: 하위 클래스가 실수로 기반 클래스의 동기화를 방해할 가능성이 줄어든다.
```java
public class Base {
    private final Object lock = new Object(); // 비공개 락 객체

    public void baseMethod() {
        synchronized(lock) {
            // 안전하게 동기화를 수행한다.
        }
    }
}

public class Derived extends Base {
    public void derivedMethod() {
        synchronized(this) { // 'this'를 락으로 사용
            // 이 동기화는 Base 클래스의 동기화와 독립적이다.
        }
    }
}
```

# 결론
- 모든 스레드가 자신의 스레드 안전성 정보를 명확히 문서화해야한다.
    - `synchronized` 한정자는 문서화와 관련이 없다.
- 조건부 스레드 안전 클래스는 메서드를 어떤 순서로 호출할 때 외부 동기화가 요구되고, 그때 어떤 락을 얻어야 하는지 알려줘야한다.
- 무조건적 스레드 안전 클래스를 작성할 때는 `synchronized` 메서드가 아닌 `비공개 락 객체`를 사용하자.
    - 이렇게 해야 클라이언트나 하위 클래스에서 동기화 메커니즘을 깨뜨리는 것을 예방할 수 있다.

