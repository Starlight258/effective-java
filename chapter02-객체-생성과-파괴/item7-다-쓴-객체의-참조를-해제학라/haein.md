## ✍️ 개념의 배경

Garbage Collection (GC)

- Java 의 자 메모리 관리 시스템
- 프로그램에 의해 할당된 메모리가 더 이상 인스턴스를 참조하지 않을 때 그 메모리를 자동으로 초기화해줌

메모리 누수(Memory Leak)

- 프로그램이 사용하지 않는 메모리 영역을 계속 차지하는 현상

# 요약

---

GC는 가 있다고 해서 항상 메모리 누수에 자유로운 것은 아니다.

## 1. 스택

```java
public class Stack {
private Object[] elements;
private int size = 0;
private static final int DEFAULT_INITIAL_CAPACITY = 16;

```
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
 */
private void ensureCapacity() {
    if (elements.length == size)
        elements = Arrays.copyOf(elements, 2 * size + 1);
}

```
```

- 위 코드에서 스택이 줄어들 때 (pop 메소드) 꺼내진 객체들을 GC가 회수하지 못한다.
- pop 메소드를 보면 인덱스만 줄어들 뿐, 여전히 스택이 원소들을 참조하고 있다.
- pop의 의도상  size가 인덱스보다 큰 원소들은 사용하지 않는 참조(obsolete reference)가 될 텐데 메모리에 남아 있는 것이다.
- 참조가 남아 있으므로 GC가 이 영역을 자동으로 회수하지 않는다.
- 결국, 이 코드를 반복하여 사용하면 메모리 누수가 발생할 수 있다!

```java
//    // 코드 7-2 제대로 구현한 pop 메서드 (37쪽)
    public Object pop() {
        if (size == 0)
            throw new EmptyStackException();
       Object result = elements[--size];
      elements[size] = null; // 다 쓴 참조 해제
      return result;
    }
```

- 해결책으로는 명시적으로 다 쓴 참조값을 해제해준다.
- null 예약어를 이용한다, NullPointerException 을 이용해 예상치 못한 실수를 방지할 수도 있다.
- null 을 활용하는 방식은 **자기 메모리를 직접 관리하는 클래스**에 적용하면 좋다.
    - 배열의 활성 영역(pop 을 하지 않은 인덱스들) 과 비활성 영역의 구분은 구현한 프로그래머만 안다.
    - 비활성 영역을 null을 이용해 명시적으로 GC 에 알려야 한다.

## 2. 캐시

### 2.1 WeakHashMap

- 객체 참조를 캐시에 넣고, 객체를 다 쓴 뒤에 이 사실을 잊어버렸다면 메모리 누수의 원인이 될 수 있다.
- 캐시 외부에서 키(key)를 참조하는 동안만(값이 아닌) 엔트리가 살아 있는 캐시가 필요한 상황이라면 WeakHashMap 클래스를 사용해 캐시를 만드는 방법이 있다.

```java
 		WeakHashMap<Person, String> weakHashMap = new WeakHashMap<>();
		Integer key1 = 1000;
		Integer key2 = 2000;
		
		weakHashMap.put(key1, "a");
		weakHashMap.put(key2, "b");
		
		key1 = null;

		...
```

1. 약한 참조(WeakReference)로 선언된 객체는 내부에 Strong Reference(new 로 선언하는 객체) 가 없는 경우 GC의 대상이 된다.
2. 1. WeakHaspMap은 Key 에 이런 특성을 적용하여, Key의 참조가 해제되는 경우 엔트리를 GC에 올린다.
3. 내부적으로 캐싱된 객체 (리터럴로 선언한 String 이라던가..) 를 Key로 쓰는 경우에는 이 방법을 써도 해제되지 않으니 new 를 사용하라고 되어있다.

### 2.2

- 캐시 앤트리의 유효기간은 생성 시에 정확히 정의내리기가 어렵다. 그래서 일반적으론 오래 된 엔트리의 가치를 점점 떨어트리는 방식으로 구현한다.
- 즉 우리가 직접 쓰지 않는 엔트리를 청소해줘야 한다. (**ScheduledThreadPoolExecutor** 등)
- LinkedHaspMap 의 예시는 다음과 같다.

```java
protected boolean removeEldestEntry(Map.Entry eldest){
    return size() > MAX_SIZE;
}
```

## 3. 리스너(Listener) 와 콜백(Callback)

- 클라이언트가 콜백을 등록만 하고 해지하지 않는다면 콜백은 쌓이게 될 것이다.
- 이럴 때 콜백을 약한 참조(weak reference)로 저장하면 GC가 즉시 수거해간다.
- 예를 들어 WeakHashMap에 키로 저장해두면 된다.

(( 콜백을 등록할 때 WeakReference 형태로 하라는 것 같다 ??))

## 개념 관련 경험

## 이해되지 않았던 부분

## ⭐️ **번외: 추가 조각 지식**

### 자바의 세 가지 참조 유형

**강한 참조 (Strong Reference)**

- `Integer prime = 1;` 와 같은 가장 일반적인 참조 유형
- 이 객체를 가리키는 강한 참조가 있는 객체는 GC대상이 되지않는다.

**부드러운 참조 (Soft Reference)**

- `SoftReference<Integer> soft = new SoftReference<Integer>(prime);`
- 와 같이 SoftReference Class를 이용하여 생성이 가능하다.
- 만약 prime == null 상태가 되어 더이상 원본(최초 생성 시점에 이용 대상이 되었던 Strong Reference) 은 없고 대상을 참조하는 객체가 SoftReference만 존재할 경우 GC대상으로 들어가도록 JVM은 동작한다.
- 다만 WeakReference 와의 차이점은 메모리가 부족하지 않으면 굳이 GC하지 않는 점이다. 때문에 조금은 엄격하지 않은 Cache Library들에서 널리 사용되는 것으로 알려져있다.

**약한 참조 (Weak Reference)**

- `WeakReference<Integer> soft = new WeakReference<Integer>(prime);`
- 와 같이 WeakReference Class를 이용하여 생성이 가능하다.
- prime == null 되면 (해당 객체를 가리키는 참조가 WeakReference 뿐일 경우) GC 대상이 된다.
- 앞서 이야기 한 내용과 같이 SoftReference와 차이점은 메모리가 부족하지 않더라도 GC 대상이 된다는 것이다. 다음 GC가 발생하는 시점에 무조건 없어진다.