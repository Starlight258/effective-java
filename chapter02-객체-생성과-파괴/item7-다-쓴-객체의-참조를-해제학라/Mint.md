### 해당 코드는 OutOfMemorError가 발생한다.
```java
package effectivejava.chapter2.item7;  
import java.util.*;  
  
// 코드 7-1 메모리 누수가 일어나는 위치는 어디인가? (36쪽)  
public class Stack {  
    private Object[] elements;  
    private int size = 0;  
    private static final int DEFAULT_INITIAL_CAPACITY = 16;  
  
    public Stack() {  
        elements = new Object[DEFAULT_INITIAL_CAPACITY];  
    }  
  
    public void push(Object e) {  
        ensureCapacity();  
        elements[size++] = e;  
    }  
  
    public Object pop() {  
        if (size == 0)  
            throw new EmptyStackException();  
        return elements[--size];  
    }  
  
    /**  
     * 원소를 위한 공간을 적어도 하나 이상 확보한다.  
     * 배열 크기를 늘려야 할 때마다 대략 두 배씩 늘린다.  
     */    private void ensureCapacity() {  
        if (elements.length == size)  
            elements = Arrays.copyOf(elements, 2 * size + 1);  
    }  
    
    public static void main(String[] args) {  
        Stack stack = new Stack();  
        for (String arg : args)  
            stack.push(arg);  
  
        while (true)  
            System.err.println(stack.pop());  
    }  
}
```
- 스택이 다 쓴 참조를 여전히 가지고 있기 때문이다.
    - 스택에서 꺼내진 객체들을 가비지 컬렉터는 회수 대상으로 생각하지 않는다. 가비지 컬렉터가 보기에 배열의 비활성 영역도 똑같이 유효한 객체이기 때문이다.
    - **해당 참조를 다 썼을때 명시적으로 null 처리**를 해야한다.
```java
// 코드 7-2 제대로 구현한 pop 메서드 (37쪽)  
public Object pop() {  
    if (size == 0)  
        throw new EmptyStackException();  
    Object result = elements[--size];  
    elements[size] = null; // 다 쓴 참조 해제  
    return result;  
}
```

- 위 Stack 클래스는 자기 메모리(elements)를 직접 관리하는 클래스이므로 프로그래머는 메모리 누수에 주의해야한다.

> 가비지 컬렉션의 메모리 누수를 찾기 어려운 이유는 객체 참조 하나를 살려두면 그 객체 뿐 아니라 해당 객체를 참조하는 모든 객체를 회수하지 못하기 때문이다.

### 객체 참조를 null 처리하는 일은 예외적인 경우여야한다.
- 다 쓴 참조를 해제하는 가장 좋은 방법은 **그 참조를 담은 변수를 유효 범위 밖으로 밀어내는 것**이다. (변수의 범위를 최소로 정하는 것이다.)
    - 유효 범위란 **변수의 스코프(범위)를 최소한으로 유지하라**는 의미이다.
    - 변수가 필요한 곳에서만 선언하고 사용하면 그 변수는 해당 범위를 벗어날 때 자동으로 해제된다.
```java
// 좋지 않은 예
public void processData() {
    Object someObject = new Object();
    someObject = null; // 명시적 null 처리 (불필요)
}

// 좋은 예
public void processData() {
    // 필요한 범위에서만 변수 선언
    {
        Object someObject = new Object();
    } // someObject의 유효 범위 끝
}
```

### 캐시 역시 메모리 누수를 일으키는 주범이다.
- 객체 참조를 캐시에 넣고 그 객체를 다 쓴 뒤에도 캐시에 두면 메모리 누수가 일어난다.
- 캐시 외부에서 키를 참조하는 경우에만 엔트리가 살아있는 캐시가 필요하다면, **WeakHashMap**을 사용하자.
    - WeakHashMap은 약한 참조만 가지므로, **강한 참조가 제거(key(참조)=null)될 경우 가비지 컬렉터의 대상**이 된다.
    - 그냥 해시맵을 사용할 경우 key=-null로 설정해도 엔트리는 맵에 계속 남아있으며 삭제를 원할 경우 remove()를 호출해야한다.
- 캐시 엔트리의 유효기간을 정의하기 어려우므로 시간이 지날수록 엔트리의 가치를 떨어뜨리는 방식을 주로 흔히 사용한다.
    - 쓰지 않는 엔트리는 청소해주어야한다


### 리스너 혹은 콜백은 메모리 누수를 일으킨다.
- 클라이언트가 콜백을 등록만 하고 명확하게 해지하지않는 경우 콜백은 계속 쌓여간다.
```java
import java.util.HashMap;
import java.util.Map;

public class CallbackManager {
    // 강한 참조를 사용하는 HashMap
    private final Map<Object, Callback> callbacks = new HashMap<>();

    public void registerCallback(Object key, Callback callback) {
        callbacks.put(key, callback);
    }

    public void doSomething() {
        for (Callback callback : callbacks.values()) {
            callback.call();
        }
    }

    // 콜백 해제 메서드 (클라이언트가 호출해야 함)
    public void unregisterCallback(Object key) {
        callbacks.remove(key);
    }

    public interface Callback {
        void call();
    }
}

class Client {
    public void start() {
        CallbackManager manager = new CallbackManager();
        manager.registerCallback(this, () -> System.out.println("Callback"));
        // 사용 후 unregisterCallback을 호출하지 않으면 메모리 누수 발생
    }
}
```

- 콜백을 약한 참조로 저장하면 가비지 컬렉터가 즉시 수거한다. (WeakHashMap에 키로 저장)
```java
import java.util.Map;
import java.util.WeakHashMap;

public class ImprovedCallbackManager {
    // WeakHashMap 사용
    private final Map<Object, Callback> callbacks = new WeakHashMap<>();

    public void registerCallback(Object key, Callback callback) {
        callbacks.put(key, callback);
    }

    public void doSomething() {
        callbacks.entrySet().removeIf(entry -> {
            if (entry.getValue() == null) {
                return true; // 약한 참조가 해제된 엔트리 제거
            }
            entry.getValue().call();
            return false;
        });
    }

    // 명시적인 unregister가 없어도 됨

    public interface Callback {
        void call();
    }
}

class ImprovedClient {
    public void start() {
        ImprovedCallbackManager manager = new ImprovedCallbackManager();
        manager.registerCallback(this, () -> System.out.println("Callback"));
        // 명시적인 unregister 없이도 Client 객체가 가비지 컬렉션되면 자동으로 콜백도 제거됨
    }
}
```

### 4가지 참조 유형
#### 강한 참조
- new로 새로운 객체 할당
- 참조 해제되지 않는 이상 gc 대상이 아니다.

#### 약한 참조
- 강한 참조가 사라지고 약한 참조가 남을 경우 gc에 의해 수집된다.

#### 소프트 참조
- 메모리 부족할때만 gc에 의해 수집된다.
#### 팬텀 참조
- 객체가 finalize 되더라도 메모리에서 완전히 제거되기전에 참조가 가능하다.
