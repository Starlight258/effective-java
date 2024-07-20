# 3. private 생성자나 열거 타입으로 싱글턴임을 보장하라.
### 싱글턴
- **인스턴스를 오직 하나만 생성할 수 있는 클래스**
- 함수와 같은 무상태 객체나 설계상 유일해야하는 시스템 컴포넌트
- 클래스를 싱글턴으로 만들면 이를 사용하는 **클라이언트를 테스트하기가 어렵다.**
	- 싱글턴 인스턴스는 private 생성자를 가지므로 새로 생성하여 테스트할 수 없다.
	- 접근만 가능한데, 실제 싱글턴 인스턴스에 접근하여 테스트할 경우 **싱글턴 인스턴스는 전역상태이므로 테스트 독립성을 깨뜨린다.**
	- 타입을 인터페이스로 정의하여 **인터페이스를 구현해 만든 싱글턴일 경우 테스트가 가능하다.**
	- 현재는 static에 대해 mocking이 가능하지만 권장하지 않는다.
#### 인터페이스를 구현한 싱글턴
```java
// 인터페이스 정의
public interface DatabaseConnection {
    void connect();
}

// 싱글턴 구현
public class RealDatabaseConnection implements DatabaseConnection {
    private static final RealDatabaseConnection INSTANCE = new RealDatabaseConnection();

    private RealDatabaseConnection() {}

    public static RealDatabaseConnection getInstance() {
        return INSTANCE;
    }

    public void connect() {
    }
}

// 테스트
class RealDatabaseConnectionTest {
    @Test
    void testConnect() {
        // 가짜 DatabaseConnection 구현체 생성
        FakeDatabaseConnection fakeDatabaseConnection = new FakeDatabaseConnection();

        // connect() 메서드 호출
        fakeDatabaseConnection.connect();

        // 연결이 성공했는지 확인
        assertTrue(fakeDatabaseConnection.isConnected());
    }
}
// 가짜 싱글턴 객체
class FakeDatabaseConnection implements DatabaseConnection {
    private boolean connected = false;

    @Override
    public void connect() {
        this.connected = true;
    }

    public boolean isConnected() {
        return this.connected;
    }
}
```

## 싱글턴을 만드는 방식
### 1. public static final 필드
- 싱글턴을 **public static 멤버로 직접 접근**한다.
	- 싱글턴 인스턴스를 public으로 공개
- 생성자는 private으로 감춰놓는다.
```java
// 코드 3-1 public static final 필드 방식의 싱글턴 (23쪽)  
public class Elvis {  
    public static final Elvis INSTANCE = new Elvis();  
  
    private Elvis() { }  
  
    public void leaveTheBuilding() {  
        System.out.println("Whoa baby, I'm outta here!");  
    }  
  
    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!  
    public static void main(String[] args) {  
        Elvis elvis = Elvis.INSTANCE;  
        elvis.leaveTheBuilding();  
    }  
}
```

- 해당 클래스가 싱글턴임이 api에 명확하게 드러난다.
- 간결하다.

#### 리플렉션
- private 생성자라도 리플렉션 API인 **AccessibleObject.setAccessible()** 을 사용해 private 생성자를 호출할  수 있다.
- 이를 방어하기 위해 생성자가 두번 이상 호출될 경우 에러를 반환하게 할 수 있다.
```java
public class SingletonBreaker {
    public static void main(String[] args) throws Exception {
        Singleton singleton1 = Singleton.getInstance();
        
        // 리플렉션을 사용하여 private 생성자에 접근
        Constructor<Singleton> constructor = Singleton.class.getDeclaredConstructor();
        constructor.setAccessible(true);
        Singleton singleton2 = constructor.newInstance();

        System.out.println(singleton1 == singleton2);  // false 출력
    }
}
```

### 2. 정적 팩터리 방식의 싱글턴
- 싱글턴 인스턴스를 private으로 하고 정적 팩터리 (`getInstance()`)로 접근한다.
```java
// 코드 3-2 정적 팩터리 방식의 싱글턴 (24쪽)  
public class Elvis {  
    private static final Elvis INSTANCE = new Elvis();  
    private Elvis() { }  
    public static Elvis getInstance() { return INSTANCE; }  
  
    public void leaveTheBuilding() {  
        System.out.println("Whoa baby, I'm outta here!");  
    }  
  
    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!  
    public static void main(String[] args) {  
        Elvis elvis = Elvis.getInstance();  
        elvis.leaveTheBuilding();  
    }  
}
```
- 정적 팩터리를 수정하여 api를 바꾸지 않고도 싱글턴이 아니게 변경할 수 있다.
- 정적 팩터리를 **제네릭** 싱글턴 팩터리로 만들 수 있다.
```java
public class GenericSingletonFactory {
    private static final Set EMPTY_SET = new HashSet();

    // 제네릭 싱글턴 팩터리 메서드
    @SuppressWarnings("unchecked")
    public static <T> Set<T> emptySet() {
        return (Set<T>) EMPTY_SET;
    }
}

// 사용 예
Set<String> stringSet = GenericSingletonFactory.emptySet();
Set<Integer> integerSet = GenericSingletonFactory.emptySet();
```
- 정적 팩터리의 메서드 참조를 **공급자**로 사용할 수 있다.
```java
public class SupplierFactory {
    public static Integer createInteger() {
        return Integer.valueOf(42);
    }
}

Supplier<Integer> integerSupplier = SupplierFactory::createInteger;
Integer value = integerSupplier.get();  // 42
```

#### 직렬화, 역직렬화
- 위 두 방식으로 만든 싱글턴 클래스를 직렬화(객체->바이트스트림)하려면 단순히 Serializable을 구현하는 것으로는 부족하다.
- 모든 인스턴스를 **transient**(직렬화에서 제외)로 선언하고 **readResolve()** 메서드(역직렬화시 호출)를 제공해야한다.
- 위를 지키지 않으면 **직렬화된 인스턴스를 역직렬화**할때마다 새로운 인스턴스가 만들어진다.
```java
public class Singleton implements Serializable {
    private static final Singleton INSTANCE = new Singleton();
    
    private transient String data;

    private Singleton() {
        data = "Singleton Data";
    }

    public static Singleton getInstance() {
        return INSTANCE;
    }

    // 역직렬화 시 호출
    private Object readResolve() {
        // 싱글턴의 기존 인스턴스를 반환
        return INSTANCE;
    }

    public String getData() {
        return data;
    }
}
```

### 3. Enum 타입의 싱글턴 🌟
- **원소가 하나인 enum 타입**을 선언한다.
- **싱글턴을 만드는 가장 좋은 방법이다.**
- 간결하고 추가 노력 없이 직렬화가 가능하며 리플렉션 공격을 완벽히 막아준다.
	- enum은 상수 집합이며 각 필드는 public static final 필드이다.
	- 생성자는 private이다.
	- 기본적으로 Serializable을 구현한다.
	- 직렬화, 역직렬화시 같은 인스턴스를 반환한다.
	- 리플렉션을 사용해도 인스턴스 생성이 불가능하다. jvm에서 생성자 호출을 막는다.
```java
// 열거 타입 방식의 싱글턴 - 바람직한 방법 (25쪽)  
public enum Elvis {  
    INSTANCE;  
  
    public void leaveTheBuilding() {  
        System.out.println("기다려 자기야, 지금 나갈께!");  
    }  
  
    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!  
    public static void main(String[] args) {  
        Elvis elvis = Elvis.INSTANCE;  
        elvis.leaveTheBuilding();  
    }  
}
```



