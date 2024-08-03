# 18. 상속보다는 컴포지션을 사용하라
- 상속은 코드를 재사용하는 강력한 수단이지만, 항상 최선은 아니다.
    - 잘못 사용하면 오류를 내기 쉬운 소프트웨어를 만들게 된다.
- 상속이 안전할 때
    - 상위 클래스와 하위 클래스가 모두 같은 패키지이다.
    - 확장할 목적으로 설계되었고 문서화도 잘 된 클래스이다.
- 다른 패키지의 구체 클래스를 상속하는 것은 위험하다.
> 여기서 말하는 상속은 구현 상속을 말하며, 인터페이스 상속과는 무관하다.

### 메서드 호출과 달리 상속은 캡슐화를 깨뜨린다.
- 상위 클래스가 어떻게 구현되냐에 따라 하위 클래스의 동작에 이상이 생길 수 있다.
    - 상위 클래스는 릴리즈마다 내부 구현이 달라질 수 있다. 하위 클래스는 달라진 상위 클래스의 영향을 받는다.
- 상위 클래스 설계자가 확장을 고려하지 않고 문서화도 제대로 하지 않으면 **하위 클래스는 상위 클래스에 맞춰 수정되어야 한다.**
- 예시
    - 상속
```java
// 코드 18-1 잘못된 예 - 상속을 잘못 사용했다! (114쪽)  
public class InstrumentedHashSet<E> extends HashSet<E> {  
    // 추가된 원소의 수  
    private int addCount = 0;  
  
    public InstrumentedHashSet() {  
    }  
  
    public InstrumentedHashSet(int initCap, float loadFactor) {  
        super(initCap, loadFactor);  
    }  
  
    @Override public boolean add(E e) {  
        addCount++;  
        return super.add(e);  
    }  
  
    @Override public boolean addAll(Collection<? extends E> c) {  
        addCount += c.size();  
        return super.addAll(c);  
    }  
  
    public int getAddCount() {  
        return addCount;  
    }  
  
    public static void main(String[] args) {  
        InstrumentedHashSet<String> s = new InstrumentedHashSet<>();  
        s.addAll(List.of("틱", "탁탁", "펑"));  
        System.out.println(s.getAddCount());  
    }  
}
```
- 이 클래스는 add와 addAll을 오버라이드하여 생성된 이후 추가된 원소의 개수를 센다.
- 잘못 구현되었다.
    - addAll로 3개의 원소를 더할 경우 처음 addCount가 3만큼 증가하고, super.addAll()은 add()를 더할때마다 호출하므로 addCount는 6이다.
    - **상위 클래스의 메서드 구현 방식을 고려해야한다.**
> 하위 클래스에서 오버라이드시 런타임에 하위 클래스의 메서드가 상위 클래스의 메서드를 대체한다. (동적 dispatch)
- addAll을 오버라이드하지않고 새로 함수를 만든다면 문제를 피할 수 있다.
    - 하지만 상위 클래스가 addAll을 구현하였으므로 **사용자가 오버라이드하지 않은 메서드를 (addAll())을 사용할 수 있다.**
    - 만약 상위 클래스의 메서드가 private 필드를 사용하는 메서드라면 오버라이드 외에 **새로 함수를 만들 수 없다.**
- 상위 클래스가 **새로운 메서드를 추가**할 경우 해당 메서드를 제때 오버라이드하지않으면, **해당 메서드가 하위 클래스를 깨뜨릴 수 있다.**

### 컴포지션 : 기존 클래스를 확장하는 대신, 새로운 클래스를 만들고 **private 필드로 기존 클래스의 인스턴스를 참조**하자.
- **기존 클래스를 새로운 클래스의 구성요소로 사용**한다.
- **전달** : 새 클래스의 인스턴스 메서드들은 **기존 클래스의 대응하는 메서드를 호출**해 결과를 반환한다.
    - 새로운 클래스는 기존 클래스의 내부 구현 방식의 영향에서 벗어나며, 기존 클래스에 새로운 메서드가 추가되더라도 영향받지 않는다.
- 재사용할 수 있는 전달 클래스(**컴포지션+전달 = 위임**)
```java
// 코드 18-3 재사용할 수 있는 전달 클래스 (118쪽)  
public class ForwardingSet<E> implements Set<E> {  
    private final Set<E> s;  
    public ForwardingSet(Set<E> s) { this.s = s; }  
  
    public void clear()               { s.clear();            }  
    public boolean contains(Object o) { return s.contains(o); }  
    public boolean isEmpty()          { return s.isEmpty();   }  
    public int size()                 { return s.size();      }  
    public Iterator<E> iterator()     { return s.iterator();  }  
    public boolean add(E e)           { return s.add(e);      }  
    public boolean remove(Object o)   { return s.remove(o);   }  
    public boolean containsAll(Collection<?> c)  
                                   { return s.containsAll(c); }  
    public boolean addAll(Collection<? extends E> c)  
                                   { return s.addAll(c);      }  
    public boolean removeAll(Collection<?> c)  
                                   { return s.removeAll(c);   }  
    public boolean retainAll(Collection<?> c)  
                                   { return s.retainAll(c);   }  
    public Object[] toArray()          { return s.toArray();  }  
    public <T> T[] toArray(T[] a)      { return s.toArray(a); }  
    @Override public boolean equals(Object o)  
                                       { return s.equals(o);  }  
    @Override public int hashCode()    { return s.hashCode(); }  
    @Override public String toString() { return s.toString(); }  
}
```
Set 인터페이스를 구현하면서 내부에 Set 구현체를 private 필드로 가진다.
Set의 모든 메서드를 구현하지만 실제 작업은 내부 Set에 위임한다.
**컴포지션과 전달의 조합**은 넓은 의미로 **위임**이라고 부른다.
> 컴포지션 : 내부에 Set 객체 가짐
> 전달: 메서드들이 내부 Set의 메서드를 호출

- Wrapper 클래스
```java
// 코드 18-2 래퍼 클래스 - 상속 대신 컴포지션을 사용했다. (117-118쪽)  
public class InstrumentedSet<E> extends ForwardingSet<E> {  
    private int addCount = 0;  
  
    public InstrumentedSet(Set<E> s) {  // Set을 감싸는 Wrapper 클래스
        super(s);  
    }  
  
    @Override public boolean add(E e) {  
        addCount++;  // // 기능에 덧붙임
        return super.add(e);  
    }  
    @Override public boolean addAll(Collection<? extends E> c) {  
        addCount += c.size();  // 기능에 덧붙임
        return super.addAll(c);  
    }  
    public int getAddCount() {  
        return addCount;  
    }  
  
    public static void main(String[] args) {  
        InstrumentedSet<String> s = new InstrumentedSet<>(new HashSet<>());  
        s.addAll(List.of("틱", "탁탁", "펑"));  
        System.out.println(s.getAddCount());  
    }  
}
```
**ForwardingSet를 상속받아 기능을 추가할 메서드만 오버라이드** 한다.
Set 인스턴스를 감싸고 있다는 뜻으로 wrapper 클래스라고 한다.
**기존 Set에 기능을 "장식"한다는 뜻에서 데코레이터 패턴**이라고 한다.
> 엄밀히 말하면 wrapper 객체가 내부 객체에 자기 자신의 참조를 넘기는 경우만 위임에 해당한다.

#### 상속 vs 컴포지션
- **상속** (`InstrumentedHashSet.class`)
```java
@Override public boolean addAll(Collection<? extends E> c) {
    addCount += c.size();
    return super.addAll(c);
}
```
`super.addAll()`은 상속한 클래스인 `HashSet의 addAll`을 호출한다.
HashSet의 addAll은 내부적으로 각 원소에 대해 `add()`를 추가한다.
`InstrumentedHashSet`에서 `add()`을 오버라이드했으므로 `오버라이드된 add()` 메서드를 호출하게 되고, addCount가 중복 계산된다.

- **컴포지션** (`InstrumentedSet.class`)
```java
@Override public boolean addAll(Collection<? extends E> c) {
    addCount += c.size();
    return super.addAll(c);
}
```
`super.addAll()`은 상위 클래스인 ForwardingSet의 `addAll`을 호출한다.
`ForwardingSet의 addAll`은 단순히 내부 Set 객체의 `addAll`을 호출하므로 `InstrumentedSet의 add()`가 호출되지 않는다.
즉 하위 클래스에서 오버라이드한 메서드인 `add()`가 호출되지 않으므로 중복 계산 문제가 발생하지 않는다.

#### Wrapper 클래스의 단점
- 래퍼 클래스는 단점이 거의 없다.
- 한가지, **래퍼 클래스는 콜백(callback) 프레임워크와는 어울리지 않는다.**
    - 콜백 프레임워크 : 자기 자신의 **참조를 다른 객체에 넘겨서 다음 호출(콜백) 때 사용**한다.
    - **SELF** 문제 : 내부 객체는 자신을 감싸고 있는 래퍼의 존재를 모르므로 **자신(this)의 참조**를 넘기고, **콜백때는 wrapper가 아닌 내부 객체를 호출**하게 된다.
        - 래퍼에 추가된 기능이 콜백시에 적용되지 않는다.
- 예시
```java
interface Callback {
    void call();
}

class RealWorker implements Callback {
    private String name;

    public RealWorker(String name) {
        this.name = name;
    }

    @Override
    public void call() {
        System.out.println(name + " is doing work");
    }

    public void registerWithManager(CallbackManager manager) {
        manager.registerCallback(this);  // 자신(this)을 등록
    }
}

// Wrapper 클래스
class WorkerWrapper implements Callback {
    private RealWorker worker;

    public WorkerWrapper(RealWorker worker) {
        this.worker = worker;
    }

    @Override
    public void call() {
        System.out.println("Wrapper: Before call");
        worker.call();
        System.out.println("Wrapper: After call");
    }

    public void registerWithManager(CallbackManager manager) {
        worker.registerWithManager(manager);  // RealWorker의 registerWithManager 호출
    }
}

class CallbackManager {
    private Callback callback;

    public void registerCallback(Callback callback) {
        this.callback = callback;
    }

    public void executeCallback() {
        if (callback != null) {
            callback.call();
        }
    }
}
```

```java
public class Main {
    public static void main(String[] args) {
        CallbackManager manager = new CallbackManager();
        
        RealWorker realWorker = new RealWorker("Real Worker");
        WorkerWrapper wrapper = new WorkerWrapper(realWorker);
        
        wrapper.registerWithManager(manager);
        
        manager.executeCallback();
    }
}
```
결과
```java
Real Worker is doing work
```
Wrapper가 아닌 내부 객체의 메서드가 호출된다.

- 전달 메서드가 성능에 주는 영향이나 래퍼 객체가 메모리 사용량에 영향은 별로 없다고 밝혀졌다.
- 재사용할 수 있는 전달 클래스를 인터페이스당 하나씩 만들어두면 원하는 기능을 덧씌우는 전달 클래스들을 손쉽게 구현할 수 있다.
    - 재사용할 수 있는 전달 클래스란 ForwardingSet같은 클래스를 의미한다.

#### 참고) 콜백 프레임워크
객체 A가 객체 B에게 **자신의 참조**를 넘기고, 나중에 **B가** **A의 메서드를 호출**(실행 시점을 결정)한다.
> 나중에 호출되는 A의 메서드를 콜백이라고 한다.
```java
// 콜백 인터페이스
interface ButtonClickListener {
    void onClick();
}

class Button {
    private ButtonClickListener listener;

    // 리스너 등록 메서드
    public void setOnClickListener(ButtonClickListener listener) {
        this.listener = listener;
    }

    public void click() {
        if (listener != null) {
            listener.onClick();
        }
    }
}

// 버튼 사용 예시
public class Main {
    public static void main(String[] args) {
        Button button = new Button();

        // 익명 클래스를 사용하여 콜백 정의
        button.setOnClickListener(new ButtonClickListener() {
            @Override
            public void onClick() {
                System.out.println("버튼이 클릭되었습니다!");
            }
        });

        button.click();
    }
}
```
- 실행될 코드는 A가 제공하지만, 메서드의 호출 시점은 B가 결정한다.
> 실행될 코드와 메서드 호출 시점을 결정하는 객체가 다르다.

### 상속은 상위 클래스가 하위 클래스와 **is-a** 관계일 때만 상속해야한다.
- 클래스 A를 상속하려면 클래스 B가 정말 A인지 확신할 수 있어야 한다.
- 아니라면 **A를 private 인스턴스로 두고 A와 다른 API를 제공**하자.
- java에서도 잘못된 상속 예시로 Stack이 Vector를 확장하고 있는데, Stack은 Vector가 아니므로 확장해서는 안됐다.
    - 컴포지션을 사용했다면 좋았을 것이다.

### 컴포지션을 써야 할 상황에서 상속을 사용하는 것은 내부 구현을 불필요하게 노출한다.
- **API가 내부 구현에 묶이고 클래스의 성능도 영원히 제한**된다.
- 클라이언트가 노출된 내부에 직접 접근할 수 있다.
    - 상위 클래스로부터 **물려받은 메서드를 직접 사용**할 수 있다.
    - **클라이언트에서 상위 클래스를 수정한다면 하위 클래스의 불변식을 해칠 수 있다.**

### 확장하려는 클래스의 API에 결함이 없는지 확인하자.
- 상속은 상위 클래스의 API를 그 결함까지도 그대로 승계한다.
- 컴포지션으로는 이러한 결함을 숨기는 새로운 API를 설계할 수 있다.

## 결론
- **상속은 강력하지만 캡슐화를 해친다.**
    - 상속은 상위 클래스와 하위 클래스가 순수한 **is-a 관계**일 때만 써야 한다.
    - is-a 관계여도 하위 클래스의 패키지가 상위 클래스와 다르고, 상위 클래스가 확장을 고려해 설게되지 않았다면 주의해야한다.
- **상속 대신 컴포지션과 전달을 사용하자.**
    - wrapper 클래스로 전달할 적당한 인터페이스가 있으면 더욱 그렇다.
    - **wrapper 클래스는 하위 클래스보다 견고하고 강력하다.**

