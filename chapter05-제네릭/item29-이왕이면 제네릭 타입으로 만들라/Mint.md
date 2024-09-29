# 29. 이왕이면 제네릭 타입으로 만들라

## 제네릭으로 바꿔보자
### 기존 코드
- 스택에서 꺼낸 객체(Object)를 형변환해야하는데, 런타임 오류가 날 수 있다.
```java
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
  
    private void ensureCapacity() {  
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

변환 방법
1. 클래스 선언에 타입 매개변수를 추가한다.
2. Object를 적절한 타입 매개변수로 변환한다.

```java
public class Stack<E> {  
    private E[] elements;  
    private int size = 0;  
    private static final int DEFAULT_INITIAL_CAPACITY = 16;  
  
    public Stack() {  
        elements = new E[DEFAULT_INITIAL_CAPACITY];  
    }  
  
    public void push(E e) {  
        ensureCapacity();  
        elements[size++] = e;  
    }  
  
    public E pop() {  
        if (size == 0)  
            throw new EmptyStackException();  
        return elements[--size];  
    }  
  
    private void ensureCapacity() {  
        if (elements.length == size)  
            elements = Arrays.copyOf(elements, 2 * size + 1);  
    }  
  
    public static E main(String[] args) {  
        Stack stack = new Stack();  
        for (String arg : args)  
            stack.push(arg);  
  
        while (true)  
            System.err.println(stack.pop());  
    }  
}
```
#### 제네릭 배열을 직접적으로 생성할 수 없다.
```java
public Stack() {  
    elements = new E[DEFAULT_INITIAL_CAPACITY];  
}  
```

## 제네릭 배열 생성 문제 해결 방법
### 1. Object[]를 만든 이후 제네릭 배열로 형변환한다.
```java
public Stack() {  
    elements = (E[]) new Object[DEFAULT_INITIAL_CAPACITY];  
}  
```
- 컴파일러는 타입 안전함을 보장할 수 없다.
- 우리가 스스로 이 비검사 형변환이 타입 안전성을 해치지 않는지 확인해야한다.
    - elements는 private 필드에 저장되고, 생성자에서 생성되며 다른 클라이언트로 반환되거나 전달되지 않는다.
    - push 메서드를 통해 배열에 저장되는 원소의 타입은 항상 E다.
      => 타입 안전하다.

#### 비검사 형변환이 안전함을 증명했다면 범위를 최소로 좁혀 `@SuppressWarnings`으로 경고를 숨긴다
```java
// E[]를 이용한 제네릭 스택 (170-174쪽)  
public class Stack<E> {  
    private E[] elements;  
    private int size = 0;  
    private static final int DEFAULT_INITIAL_CAPACITY = 16;  
  
    // 코드 29-3 배열을 사용한 코드를 제네릭으로 만드는 방법 1 (172쪽)  
    // 배열 elements는 push(E)로 넘어온 E 인스턴스만 담는다.  
    // 따라서 타입 안전성을 보장하지만,  
    // 이 배열의 런타임 타입은 E[]가 아닌 Object[]다!  
    @SuppressWarnings("unchecked")  
    public Stack() {  
        elements = (E[]) new Object[DEFAULT_INITIAL_CAPACITY];  
    }  
  
    public void push(E e) {  
        ensureCapacity();  
        elements[size++] = e;  
    }  
  
    public E pop() {  
        if (size == 0)  
            throw new EmptyStackException();  
        E result = elements[--size];  
        elements[size] = null; // 다 쓴 참조 해제  
        return result;  
    }  
  
    public boolean isEmpty() {  
        return size == 0;  
    }  
  
    private void ensureCapacity() {  
        if (elements.length == size)  
            elements = Arrays.copyOf(elements, 2 * size + 1);  
    }  
  
    // 코드 29-5 제네릭 Stack을 사용하는 맛보기 프로그램 (174쪽)  
    public static void main(String[] args) {  
        Stack<String> stack = new Stack<>();  
        for (String arg : args)  
            stack.push(arg);  
        while (!stack.isEmpty())  
            System.out.println(stack.pop().toUpperCase());  
    }  
}
```

- 첫번째 방법은 가독성이 좋고 코드도 더 짧아 개발자들이 선호한다.
    - 형변환을 배열 생성시 한번만 해주어도 된다.
- 하지만 배열의 런타임 타입이 컴파일 타입과 달라 **힙 오염**을 일으킨다.

#### 참고) 힙 오염
```java
public class HeapPollutionExample {
    public static void main(String[] args) {
        // Object 배열 생성
        Object[] objectArray = new Long[1];
        
        // Object 배열을 String 배열로 캐스팅 (컴파일러 경고 발생)
        String[] stringArray = (String[]) objectArray;
        
        // Long 객체를 Object 배열에 할당 (OK)
        objectArray[0] = 42L;
        
        // 여기서 ClassCastException 발생
        String s = stringArray[0];
    }
}
```
- 변수가 해당 타입이 아닌 객체를 참조할 때 발생하며 런타임에 `ClassCastException`이 발생할 수 있다.

### 2. `elements` 필드의 타입을 `E[]`에서 `Object[]`로 바꾸고, 배열이 반환한 원소를 `E`로 형변환한다.
```java
// Object[]를 이용한 제네릭 Stack (170-174쪽)  
public class Stack<E> {  
    private Object[] elements;  
    private int size = 0;  
    private static final int DEFAULT_INITIAL_CAPACITY = 16;  
      
    public Stack() {  
        elements = new Object[DEFAULT_INITIAL_CAPACITY]; // Object 배열 
    }  
  
    public void push(E e) {  
        ensureCapacity();  
        elements[size++] = e;  
    }  
  
    // 코드 29-4 배열을 사용한 코드를 제네릭으로 만드는 방법 2 (173쪽)  
    // 비검사 경고를 적절히 숨긴다.  
    public E pop() {  
        if (size == 0)  
            throw new EmptyStackException();  
  
        // push에서 E 타입만 허용하므로 이 형변환은 안전하다.  
        @SuppressWarnings("unchecked") E result =  
                (E) elements[--size];  
  
        elements[size] = null; // 다 쓴 참조 해제  
        return result;  
    }  
  
    public boolean isEmpty() {  
        return size == 0;  
    }  
  
    private void ensureCapacity() {  
        if (elements.length == size)  
            elements = Arrays.copyOf(elements, 2 * size + 1);  
    }  
  
    // 코드 29-5 제네릭 Stack을 사용하는 맛보기 프로그램 (174쪽)  
    public static void main(String[] args) {  
        Stack<String> stack = new Stack<>();  
        for (String arg : args)  
            stack.push(arg);  
        while (!stack.isEmpty())  
            System.out.println(stack.pop().toUpperCase());  
    }  
}
```
- 형변환이 안전함이 증명되었으면, `@SuppressWarnings("unchecked")`를 사용하여 경고를 숨긴다.

### 대다수의 제네릭 타입은 타입 매개변수에 제약을 두지 않는다.
- `Stack<Object>`, `Stack<int[]>`, `Stack<List<String>>`, `Stack` 가능
- 타입 매개변수에 기본 타입은 사용할 수 없다.
    - 제네릭은 런타임에 타입 정보가 소거되고, 모든 제네릭 타입은 Object로 취급된다.
    - 기본 타입은 Object의 하위 타입이 아니므로 사용이 불가능하다.
    - 박싱된 기본 타입을 사용해 우회할 수 있다 (ex) `Integer`)

#### 타입 매개변수에 제약을 두는 제네릭 타입도 있다.
- **한정적 타입 매개변수**
    - `E extends Delayed`
    - **`Delayed`의 하위 타입만 받는다**는 뜻이다.
    - 형변환 없이 곧바로 `Delayed` 클래스의 메서드를 호출할 수 있다.
    - `ClassCastException` 걱정할 필요가 없다.
    - 모든 타입은 자기 자신의 하위 타입이므로 `E`는 `Delayed`도 가능하다.

## 결론
- 클라이언트에서 **직접 형변환하는 타입보다 제네릭 타입이 더 안전하고 쓰기 좋다.**
    - 새로운 타입을 설계할 때는 형변환 없이도 사용할 수 있도록 해라.
    - 대부분 제네릭 타입으로 만들면 된다.
- **기존 타입 중 제네릭 타입이어야 할 게 있다면 제네릭 타입으로 변경하자.**
    - 기존 클라이언트에는 아무 영향을 주지 않으면서, 새로운 사용자를 훨씬 편하게 해준다.
