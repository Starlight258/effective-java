## Java의 2가지 객체 소멸자
- 객체 소멸자: **객체가 메모리에서 제거될 때 자동으로 호출**된다.
- finalizer
    - 예측할 수 없고 상황에 따라 위험할 수 있어 일반적으로 불필요하다.
    - 기본적으로 쓰지 말아야한다.
- cleaner
    - finalizer의 대안이다.
    - finalizer보다 덜 위험하지만 예측 불가능하고 느리고 일반적으로 불필요하다.

### Java의 finalizer와 cleaner는 c++의 파괴자와 다르다.

- **특정 객체와 관련된 자원을 회수**
    - C++에서 **파괴자** : 프로그래머가 명시적으로 호출한다.
    - Java의 **가비지 컬렉터**: 가비지 컬렉터가 접근 불가능한 자원을 회수하고 프로그래머는 아무런 작업을 하지 않아도 된다.
- **비메모리 자원을 회수**
    - C++에서 **파괴자**가 수행
    - Java는 **try-with-resources**와 **try-finally**를 사용해 해결한다.
> 비메모리 자원: 메모리 외의 시스템 자원
> ex) 파일 핸들러, 네트워크 소켓, db 연결, 스레드, 그래픽 자원

- c++에서 파괴자
    - 특정 객체와 관련된 자원을 회수
- java
    - 접근할 수 없게 된 자원을 회수하는 역할을 가비지 컬렉터가 담당한다.
    - 프로그래머는 아무런 작업을 요구하지 않는다.

### 1. finalizer와 cleaner는 즉시 수행된다는 보장이 없다.
- 객체에 접근할 수 없게 된 후 finalizer가 실행되기까지 얼마나 걸릴지 알 수 없다.
- **제때 실행되어야하는 작업은 finalizer와 cleaner로는 할 수 없다.**
    - ex) 파일 닫기
- 실행 타이밍은 전적으로 가비지 컬렉터의 알고리즘에 달렸으며, 구현마다 천차만별이다.
- cleaner는 자신을 수행할 스레드를 제어할 수 있지만 백그라운드에서 수행되며 가비지 컬렉터의 통제하에 있으므로 즉각 수행되리라는 보장이 없다.

### 2. finalizer와 cleaner의 수행 시점뿐 아니라 수행 여부조차 보장하지 않는다.
- 따라서 상태를 영구적으로 수정하는 작업에서는 절대로 finalizer와 cleaner에 의존해서는 안된다.

### 3. finalizer 동작 중 발생한 예외는 무시되며, 처리할 작업이 있더라도 그 순간 종료된다.
- finalizer에서 발생한 예외로 인해 즉시 finalizer의 실행이 중단되며, 객체가 마무리가 덜 된 상태로 남을 수 있다.
    - 경고조차 출력하지 않는다.
- cleaner를 사용하는 라이브러리는 해당 스레드를 통제하므로 위와 같은 작업은 일어나지 않는다.

### 4. finalizer와  cleaner는 심각한 성능 문제도 동반한다.
- AutoClosable : 가비지 컬렉터 수거까지 12ns
- finalizer : 550ns (50배)
- cleaner: 500ns
    - 안전망 형태로만 사용하면 5배

### 5. finalizer를 사용한 클래스는 finalizer 공격에 노출되어 심각한 보안 문제를 일으킬 수 있다.

#### finalizer 공격
- 객체 생성 중 예외가 발생하면, 일반적으로 객체는 생성되지 않는다.
- 그러나 finalizer가 있는 클래스의 경우, **예외 발생 후에도 finalizer가 실행될 수 있다.**
- 공격 방법
    - 하위 클래스는 finalizer를 오버라이드한다.
        - finalizer는 객체의 참조를 **정적 필드에 저장**한다. (부활시킨다)
    - 가비지 컬렉터는 항상 도달가능한 이 객체를 수집할 수 없다.
        - 정적 필드는 클래스가 실행되는 동안 계속 존재한다. (**Root set에 포함되며 언제나 도달 가능한 것으로 간주되어 수집 대상이 아니다**.)
    - **생성자나 직렬화 과정에서 예외가 발생하면, 악의적인 하위 클래스의 finalizer가 수행될 수 있다.**
        - 예외가 발생하면 보안 검사가 제대로 수행되지 않은 **불완전한 객체**가 만들어진다.
        - 불완전한 객체가 언젠가 가비지 컬렉터에 의해 수집될때, **finalizer()**가 호출된다.
        - 해당 finalizer가 정적 필드에 자신의 참조를 할당하여 가비지 컬렉터가 수집하지 못하도록 막아 부활한다.
> 언제 부활할지 모른다. 타이밍을 예측할 수 없다. 가비지 컬렉터 마음이다.

```java
public class VulnerableClass {
    private final String sensitiveData;

    public VulnerableClass(String data) throws IllegalArgumentException {
        if (data == null) {
            throw new IllegalArgumentException("Data cannot be null");
        }
        this.sensitiveData = data;
    }
}

public class MaliciousSubclass extends VulnerableClass {
    static VulnerableClass stolenObject;

    public MaliciousSubclass(String data) throws IllegalArgumentException {
        super(data);  // 부모 생성자에서 예외가 발생할 것임
    }

    @Override
    protected void finalize() {
        // 부적절하게 생성된 객체를 "훔쳐서" 저장, 부활시킨다.
        stolenObject = this;
    }
}

// 공격 수행
try {
    new MaliciousSubclass(null);  // 예외 발생시킴
} catch (IllegalArgumentException e) {
    System.out.println("Exception caught: " + e.getMessage());
}

// 가비지 컬렉션 강제 실행
System.gc();
System.runFinalization();

if (MaliciousSubclass.stolenObject != null) {
    System.out.println("Object stolen!");
    // 이제 stolenObject를 통해 부적절하게 생성된 객체에 접근 가능
}
```
- 방어 방법
    - 클래스를 final로 선언하여 상속을 막는다.
    - final이 아닌 클래스의 경우 finalizer를 만들어 final로 선언한다.
```java
public class SafeClass {
    private final String sensitiveData;

    public SafeClass(String data) throws IllegalArgumentException {
        if (data == null) {
            throw new IllegalArgumentException("Data cannot be null");
        }
        this.sensitiveData = data;
    }

    protected final void finalize() {}
}
```

- 객체 생성을 막으려면 생성자에서 예외를 발생시키면 되지만, finalizer가 있다면 그렇지도 않다.
    - java 런타임이 **부분적으로 생성된 객체(생성자에서 예외 발생한 객체)에 대해서도 finalizer를 실행**하기 때문이다.
```java
public class FinalizerExample {
    private String data;

    public FinalizerExample() throws Exception {
        System.out.println("Constructor called");
        throw new Exception("Constructor failed");
    }

    @Override
    protected void finalize() throws Throwable {
        System.out.println("Finalizer called");
        super.finalize();
    }

    public static void main(String[] args) {
        try {
            new FinalizerExample();
        } catch (Exception e) {
            System.out.println("Exception caught: " + e.getMessage());
        }

        // 가비지 컬렉션 강제 실행
        System.gc();
        System.runFinalization();
    }
}
```
출력
```java
Constructor called
Exception caught: Constructor failed
Finalizer called
```
> 생성자에서 예외 발생 후에도 finalizer가 수행된다.

#### 가비지 컬렉터의 객체 수집
```java
public class GCInstanceExample {
    private Object storedObject;

    public void storeObject(Object obj) {
        this.storedObject = obj;
    }

    public static void main(String[] args) {
        demonstrateGC();
        
        // 가비지 컬렉션 요청
        System.gc();
        System.runFinalization();
    
    }

    private static void demonstrateGC() {
        GCInstanceExample gcExample = new GCInstanceExample();
        gcExample.storeObject(new Object());
    }
}
```
- demonstrateGC 호출 이후 gcExample과 storedObject는 더이상 참조되지 않으므로 가비지 컬렉터의 대상이다.
- 실제로 가비지 컬렉터를 직접 호출하는 것은 권장X

### finalizer, cleaner 대신 AutoClosable 사용하자. 🌟
#### AutoClosable 인터페이스
- try-with-resource 구문과 함께 사용된다.
- 해당 인터페이스의 **close()** 함수를 구현하면 **try-with-resources** 블록이 종료될때 자동으로 close()가 호출된다.
```java
public class MyResource implements AutoCloseable {
    public void doSomething() {
        System.out.println("리소스 사용 중");
    }

    @Override
    public void close() throws Exception {
        System.out.println("리소스 해제");
    }
}

// 사용 얘시
try (MyResource resource = new MyResource()) {
    resource.doSomething();
} // resource.close()가 자동으로 호출
```
> 각 인스턴스는 자신이 닫혔는지 추적하는 것이 좋다.
> 객체가 닫힌 후에 불렸다면 IllegalArgumentException을 던지자.

## finalizer와 cleaner의 쓰임새
### 1. 자원의 소유자가 close()를 호출하지 않는 것에 대한 안전망
- 클라이언트가 close() 호출을 안할 경우를 대비해 늦게라도 해주도록 finalizer나 cleaner를 구현한다.
    - FileInputStream, FileOutputStream, ThreadPoolExecutor

### 2. 네이티브 피어를 회수할 때 사용한다.
- **네이티브 피어: 일반 자바 객체가 네이티브 메서드를 통해 기능을 위임한 네이티브 객체**
    - Java 객체와 연결된 네이티브(비 Java) 자원(일반적으로 C, C++로 작성)
- **가비지 컬렉터는 네이티브 피어가 자바 객체가 아니므로 네이티브 피어의 존재를 알지 못한다.**
- cleaner와 finalizer를 이용해 네이티브 피어를 회수한다.
    - 성능 저하를 감당할 수 있고 네이티브 피어가 심각한 자원을 가지고 있지 않을때만 사용한다.
    - 즉시 회수해야하거나 성능 저하를 감당할 수 없을때는 close 메서드를 사용하자.

```java
public class NativePeerExample {
    private long nativeHandle; // 네이티브 리소스의 핸들

    // 네이티브 메서드 선언
    private native long createNativeResource();
    private native void destroyNativeResource(long handle);

    public NativePeerExample() {
        this.nativeHandle = createNativeResource();
    }

    // Cleaner를 사용한 리소스 관리
    private static final Cleaner cleaner = Cleaner.create();

    {
        cleaner.register(this, new ResourceCleaner(nativeHandle));
    }

    private static class ResourceCleaner implements Runnable {
        private long handle;

        ResourceCleaner(long handle) {
            this.handle = handle;
        }

        @Override
        public void run() {
            if (handle != 0) {
                destroyNativeResource(handle); // 가비지 컬렉션되어 cleaner가 호출될때 
            }
        }
    }

    // 명시적인 close 메서드 (권장)
    public void close() {
        if (nativeHandle != 0) {
            destroyNativeResource(nativeHandle); // close() 호출할때
            nativeHandle = 0;
        }
    }

    // 네이티브 라이브러리 로드
    static {
        System.loadLibrary("nativelib");
    }
}
```
- 네이티브 피어는 close() 호출되거나 가비지 컬렉션되어 cleaner가 호출될때 파괴된다.
- close()를 명시적으로 호출하는 것이 권장된다.

### cleaner를 안전망으로 사용하는 AutoClosable 클래스
```java
package effectivejava.chapter2.item8;  
  
import java.lang.ref.Cleaner;  
  
// 코드 8-1 cleaner를 안전망으로 활용하는 AutoCloseable 클래스 (44쪽)  
public class Room implements AutoCloseable {  
    private static final Cleaner cleaner = Cleaner.create();  
  
    // 청소가 필요한 자원. 절대 Room을 참조해서는 안 된다!  
    private static class State implements Runnable {  
        int numJunkPiles; // 방에 있는 쓰레기더미 수
  
        State(int numJunkPiles) {  
            this.numJunkPiles = numJunkPiles;  
        }  
  
        // close 메서드나 cleaner가 호출한다.  
        @Override public void run() {  
            System.out.println("Cleaning room");  
            numJunkPiles = 0;  // 쓰레기 비움
        }  
    }  
  
    // 방의 상태. cleanable과 공유한다.  
    private final State state;  
  
    // cleanable 객체. 수거 대상이 되면 방을 청소한다.  
    private final Cleaner.Cleanable cleanable;  
  
    public Room(int numJunkPiles) {  
        state = new State(numJunkPiles);  
        cleanable = cleaner.register(this, state);  
    }  
  
    @Override public void close() {  
        cleanable.clean();  
    }  
}
```
- **close() 호출**시 cleanable.clean() 호출되고 내부적으로 state의 run()을 호출한다. (cleanable에서 state를 등록했었다.)
- 사용자가 close()를 호출하지 않은 경우 **가비지 컬렉션 될 때 cleaner가 동작**한다. (안전망 역할)
    - 가비지 컬렉션의 시점은 예측할 수 없으므로 명시적으로 close() 꼭 호출하거나 try-with-resources 사용하기!
- State가 room을 참조하면 안되는 이유는 순환 참조가 발생하여 room이 가비지 컬렉트의 대상이 안되기 때문이다.

#### 실제 사용
```java
try (Room myRoom = new Room(3)) {  // 쓰레기 더미 3개로 방 생성
    // 방 사용
} // 여기서 자동으로 close() 호출되어 방 청소
```

```java
Room myRoom = new Room(3);
// 방 사용
myRoom.close();  // 수동으로 방 청소
```

#### 결론
- cleaner(java8까지는 finalizer)는 안전망 역할이나 중요하지 않은 네이티브 자원 회수 용으로만 사용하자.
- 물론 이런 경우라도 불확실성과 성능 저하에 주의해야한다.
