# 24. 멤버 클래스는 되도록 static으로 만들라
## 중첩 클래스(nested class)
- 다른 클래스 안에 정의된 클래스
- 자신을 감싼 바깥 클래스에서만 사용된다.
    - 그 외의 쓰임새가 있다면 top-level 클래스로 만들어야 한다.
- 정적 멤버 클래스, (비정적) 멤버 클래스, 익명 클래스, 지역 클래스가 있다.

## 정적 멤버 클래스
```java
public class OuterClass {
    private static int staticField = 10;

    public static class StaticNestedClass {
        public void display() {
            System.out.println("Static field: " + staticField);
        }
    }
}

// 사용 예
OuterClass.StaticNestedClass nestedObject = new OuterClass.StaticNestedClass();
nestedObject.display();
```
- 외부 클래스의 정적 멤버처럼 동작한다.
    - 외부 클래스의 인스턴스 없이도 생성 가능하며, 외부 클래스의 정적 멤버에 접근 가능하다.
- 다른 클래스 안에 선언되고, 바깥 클래스의 private 멤버에도 접근할 수 있다.
- 흔히 바깥 클래스와 함께 쓰일때만 유용한 **public 도우미 클래스**로 쓰인다.
    - 클래스는 바깥 클래스의 사용자에게 공개되어 직접 사용될 수 있다.
    - 주 기능을 보조하는 부가적인 기능을 제공한다.
```java
public class Calculator {
    public static class MathOperations {
        public static int add(int a, int b) {
            return a + b;
        }

        public static int subtract(int a, int b) {
            return a - b;
        }
    }

    public double calculateComplex(int x, int y) {
        int sum = MathOperations.add(x, y);
        int difference = MathOperations.subtract(x, y);
        return Math.sqrt(sum * difference);
    }
}

public class Main {
    public static void main(String[] args) {
        Calculator calc = new Calculator();
        System.out.println(calc.calculateComplex(10, 5));

        // 직접 사용할 수도 있음
        int result = Calculator.MathOperations.add(7, 3);
        System.out.println(result);
    }
}
```

### 멤버 클래스에서 바깥 인스턴스에 접근할 일이 없다면 무조건 **static**을 붙여서 정적 멤버 클래스로 만들자.
- static을 생략하면 **바깥 인스턴스로의 숨은 외부 참조**를 갖게 된다.
    - 참조를 저장하려면 **시간과 공간이 소요**된다.
- `가비지 컬렉션`이 바깥 클래스의 인스턴스를 수거하지 못하는 **메모리 누수**가 생길 수 있다.

#### private 정적 멤버 클래스는 바깥 클래스가 표현하는 구성요소(객체의 한 부분)을 나타낼 때 쓴다.
- Map 구현체는 `키-값` 쌍을 표현하는 `Entry` 객체들을 가지고 있다.
- 모든 Entry가 맵과 연관되어 있지만, **Entry의 메서드들은 Map을 직접 사용하지는 않는다**.
    - Entry 안에서 작동한다.
    - 바깥 인스턴스를 접근하지 않으므로 **private 정적 멤버 클래스**로 사용한다.
```java
public class SimpleHashMap<K, V> implements Map<K, V> {
    
    private static class Entry<K, V> implements Map.Entry<K, V> {
        final K key;
        V value;
        Entry<K, V> next;

        Entry(K key, V value, Entry<K, V> next) {
            this.key = key;
            this.value = value;
            this.next = next;
        }

        public K getKey() {
            return key;
        }

        public V getValue() {
            return value;
        }

        public V setValue(V newValue) {
            V oldValue = value;
            value = newValue;
            return oldValue;
        }
    }

    private Entry<K, V>[] buckets;
    private int size;

}
```

> public 클래스의 public이나 protected 멤버라면 sttaic을 붙이면 하위 호환성이 깨질 수 있다.

## 비정적 멤버 클래스
```java
public class OuterClass {
    private int instanceField = 20;

    public class NonStaticNestedClass {
        public void display() {
            System.out.println("Instance field: " + instanceField);
        }
    }
}

// 사용 예
OuterClass outerObject = new OuterClass();
OuterClass.NonStaticNestedClass nestedObject = outerObject.new NonStaticNestedClass();
nestedObject.display();
```
- 비정적 멤버 클래스의 인스턴스는 **바깥 클래스의 인스턴스와 암묵적으로 연결**된다.
- 비정적 멤버 클래스의 인스턴스 메서드에서 정규화된 `this`를 사용해 **바깥 인스턴스의 메서드를 호출**하거나 **바깥 인스턴스의 참조**를 가져올 수 있다.
    - 정규화된 this : `클래스명.this`, 바깥 클래스의 이름을 명시한다.
```java
public class OuterClass {
    private int outerField = 10;
    
    public void outerMethod() {
        System.out.println("OuterClass method");
    }

    public class InnerClass {
        private int innerField = 20;

        public void innerMethod() {
            // 바깥 클래스의 인스턴스 메서드 호출
            OuterClass.this.outerMethod();

            // 바깥 클래스의 인스턴스 필드 참조
            System.out.println("Outer field: " + OuterClass.this.outerField);

            // 내부 클래스의 필드 참조 (this만 사용)
            System.out.println("Inner field: " + this.innerField);

            // 바깥 클래스의 인스턴스 참조 얻기
            OuterClass outerInstance = OuterClass.this;
            System.out.println("Outer instance: " + outerInstance);
        }
    }

    public static void main(String[] args) {
        OuterClass outer = new OuterClass();
        InnerClass inner = outer.new InnerClass(); // 수동으로 만들기
        inner.innerMethod();
    }
}
```
바깥 클래스의 참조는 비정적 멤버 클래스 인스턴스 안에 만들어져 생성 시간이 길어지며, 메모리 공간을 차지한다.
> 중첩 클래스의 인스턴스가 **바깥 인스턴스와 독립적으로 존재할 수 있다면, 정적 멤버 클래스로 만들어야 한다**.

### 비정적 멤버 클래스는 **어댑터**를 정의할 때 자주 쓰인다.
- 어댑터 : 한 인터페이스를 다른 인터페이스로 변환
- 어떤 클래스의 인스턴스를 감싸 **마치 다른 클래스의 인스턴스**처럼 보이게 하는 **뷰**로 사용한다.
    - Map 인터페이스의 구현체들은 보통 자신의 컬렉션 뷰를 구현할때 비정적 멤버 클래스를 사용한다.
    - Set과 List 같은 다른 컬렉션 인터페이스 구현들도 자신의 반복자를 구현할 때 비정적 멤버 클래스를 주로 사용한다.
```java
public class SimpleHashMap<K, V> implements Map<K, V> {

    // keySet() 메서드가 반환하는 Set 뷰
    private class KeySet extends AbstractSet<K> {
        public Iterator<K> iterator() {
            return new KeyIterator();
        }

        public int size() {
            return SimpleHashMap.this.size();
        }
    }

    // entrySet() 메서드가 반환하는 Set 뷰
    private class EntrySet extends AbstractSet<Map.Entry<K, V>> {
        public Iterator<Map.Entry<K, V>> iterator() {
            return new EntryIterator();
        }

        public int size() {
            return SimpleHashMap.this.size();
        }
    }

    // Map 인터페이스의 메서드 구현
    public Set<K> keySet() {
        return new KeySet();
    }

    public Set<Map.Entry<K, V>> entrySet() {
        return new EntrySet();
    }
}
```
Map의 데이터를 Set 인터페이스에 맞게 변환한다.

## 익명 클래스
```java
interface Greeting {
    void greet();
}

public class AnonymousClassExample {
    public void sayHello() {
        Greeting greeting = new Greeting() {
            @Override
            public void greet() {
                System.out.println("Hello from anonymous class!");
            }
        };
        greeting.greet();
    }
}

// 사용 예
AnonymousClassExample example = new AnonymousClassExample();
example.sayHello();
```
- 익명 클래스는 **이름이 없다.**
- 바깥 클래스의 **멤버도 아니다.**
    - 멤버는 이름을 가지며, 여러번 인스턴스화가 가능하다.
- 익명 클래스는 쓰이는 시점에 **선언과 동시에 인스턴스가 만들어진다**.
- **비정적인 문맥**에서 사용될 때만 바깥 클래스의 인스턴스를 참조할 수 있다.
    - 외부 클래스의 인스턴스에 대한 **암묵적 참조**를 가지기 때문이다.
- **정적 문맥**에서는 바깥 클래스의 **정적 멤버**만 참조 가능하다.
    - 인스턴스 멤버는 참조할 수 없다. (바깥 클래스의 인스턴스에 대한 참조를 가지지 않기 때문)
    - **상수 변수 이외의 정적 멤버는 가질 수 없다**.
        - 익명 클래스는 일회성이다. 정적 멤버는 클래스 수준의 공유 요소인데 일회성 특성과 맞지 않는다.
```java
public class OuterClass {
    private int instanceField = 1;
    private static int staticField = 2;
    
    // 비정적 문맥에서의 익명 클래스
    public void instanceMethod() {
        Runnable r = new Runnable() {
            @Override
            public void run() {
                System.out.println(instanceField);
            }
        };
        r.run();
    }

    // 정적 문맥에서의 익명 클래스
    public static void staticMethod() {
        Runnable r = new Runnable() {
            static final int CONSTANT = 100;
            
            @Override
            public void run() {
                System.out.println(staticField);
				System.out.println(CONSTANT);
            }
        };
        r.run();
    }

    public static void main(String[] args) {
        staticMethod();  
        
        OuterClass outer = new OuterClass();
        outer.instanceMethod();  
    }
}
```

### 익명 클래스는 제약이 많다.
- 선언한 지점에서만 인스턴스를 만들 수 있다.
- 이름이 필요한 작업은 수행할 수 없다.
    - `instanceof`
- 여러 인터페이스를 구현할 수 없고, 인터페이스를 구현하는 동시에 다른 클래스를 상속할 수도 없다.
    - 한 인터페이스나 한 클래스 상속처럼 **하나의 타입만 지정이 가능**하다.
```java
// 인터페이스
public class AnonymousRunnableExample {
    public static void main(String[] args) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                System.out.println("익명 클래스에서 실행된 run 메서드");
            }
        };

        Thread thread = new Thread(runnable);
        thread.start();
    }
}

// 클래스
public class AnonymousClassExample {
    public static void main(String[] args) {
        // Thread 클래스를 상속받는 익명 클래스
        Thread thread = new Thread() {
            @Override
            public void run() {
                System.out.println("익명 클래스에서 오버라이드된 run 메서드 실행");
                System.out.println("현재 스레드 이름: " + Thread.currentThread().getName());
            }
        };
        
        thread.start();
    }
}
```
- 익명 클래스를 사용하는 클라이언트는 **그 익명 클래스가 상위 타입에서 상속한 멤버 외에는 호출**할 수 없다.
```java
interface Printable {
    void print();
}

public class AnonymousClassExample {
    public static void main(String[] args) {
        Printable printer = new Printable() {
            @Override
            public void print() {
                System.out.println("익명 클래스에서 구현한 print 메서드");
            }

            // 익명 클래스 내부에 추가 메서드 정의
            private void additionalMethod() {
                System.out.println("익명 클래스의 추가 메서드");
            }
        };

        // 인터페이스에 정의된 메서드 호출 (가능)
        printer.print();

        // 익명 클래스에서 추가로 정의한 메서드 호출 시도 (불가능)
        // printer.additionalMethod(); // 컴파일 에러

        // 익명 클래스의 실제 타입으로 캐스팅 불가능
        // ((익명클래스타입)printer).additionalMethod(); // 문법적으로 불가능
    }
}
```

- 익명 클래스는 표현식 중간에 등장하므로 짧지 않으면 가독성이 떨어진다.

### 익명 클래스 사용처
- 람다를 지원하기 전에는 즉석에서 작은 함수 객체나 처리 객체를 만드는데 익명 클래스를 주로 사용했다.
    - 이제는 람다를 주로 상요한다.
- 익명 클래스의 다른 주 쓰임은 정적 팩토리 메서드를 구현할 때이다.

## 지역 클래스
```java
public class LocalClassExample {
    public void processData(int value) {
        class DataProcessor {
            void process() {
                System.out.println("Processing data: " + value);
            }
        }

        DataProcessor processor = new DataProcessor();
        processor.process();
    }
}

// 사용 예
LocalClassExample example = new LocalClassExample();
example.processData(30);
```
- 네가지 중첩 클래스 중 가장 드물게 사용된다.
- 메서드 내부에 정의되며, 메서드 내에서만 사용할 수 있다.
    - 메서드를 실행할때마다 새롭게 정의된다.
- 지역 클래스는 지역변수를 선언할 수 있는 곳이면 어디서든 선언할 수 있고, 유효범위도 지역 변수와 같다.
- 자신을 감싸고 있는 메서드의 지역 변수나 매개변수에 접근이 가능하지만, `실질적 final`이어야 한다.
    - 지역 변수는 실행이 끝나면 스택에서 사라지지만, 지역 클래스나 익명 클래스는 힙 메모리에 남아있는다.
        - 클래스가 지역 변수를 사용할 때 실제로는 그 **변수의 복사본을 캡쳐**하고, 복사본은 클래스 인스턴스와 함께 유지된다.
    - 변수가 변경될 수 있다면, **메서드의 로컬 컨텍스트와 클래스 인스턴스 사이에 불일치가 발생**할 수 있다.
```java
public class OuterClass {
    public void someMethod() {
        final int finalVar = 10;
        int effectivelyFinalVar = 20;  // 실질적 final

        class LocalClass {
            void printVars() {
                System.out.println(finalVar);  // OK
                System.out.println(effectivelyFinalVar);  // OK
            }
        }

        new LocalClass().printVars();
        
        // effectivelyFinalVar = 30;  // 이렇게 변경하면 LocalClass에서 사용 불가, 변수가 재할당되므로 실질적 final이어야 한다.
    }
}
```

```java
import java.util.function.Supplier;

public class Example {
    public static void main(String[] args) {
        Supplier<Integer> supplier = createSupplier();
        System.out.println(supplier.get());  // 여전히 10을 출력
    }

    public static Supplier<Integer> createSupplier() {
        final int[] number = {10};  // 배열을 사용하여 "effectively final" 우회
        
        return new Supplier<Integer>() {
            @Override
            public Integer get() {
                return number[0];
            }
        };
    }
}
```

#### 참고) Java 클래스 로딩 메커니즘
- jvm 시작시 로딩되는 것
    - java runtime 라이브러리 핵심 클래스들
        - Object, String...
    - 애플리케이션 메인 클래스
- 사용 시점에 로드되는 것
    - 대부분의 사용자 정의 클래스
    - static 멤버 (필드, 메서드)

- jvm이 프로그램 실행할 때
1. main 메서드를 포함한 클래스를 로드한다.
2. main을 실행한다.

- static 멤버 vs 인스턴스 멤버
    - static 멤버는 **클래스가 처음 로드될 때** 한번만 초기화된다.
        - 한번만 메모리에 할당된다.
    - 인스턴스 멤버는 **객체가 생성할 때**마다 초기화된다.
        - 객체마다 별도로 메모리에 할당된다.
    - 클래스 로딩은 대부분 지연 로딩으로, 필요할때까지 로딩을 미룬다.
    - 예시
```java
public class Main {
    public static void main(String[] args) {
        System.out.println("Main class loaded");
        
        // Class A is not loaded yet
        System.out.println("Class A static field: " + ClassA.staticField);
        
        // Now ClassA is loaded, but ClassB is not
        System.out.println("Creating instance of ClassA");
        ClassA objA = new ClassA();
        
        // ClassB is still not loaded
        System.out.println("Calling method that uses ClassB");
        objA.methodUsingClassB();
        
        // Now ClassB is loaded
        System.out.println("Creating instance of ClassB");
        ClassB objB = new ClassB();
    }
}

class ClassA {
    public static int staticField = 10;
    
    static {
        System.out.println("ClassA static initializer executed");
    }
    
    {
        System.out.println("ClassA instance initializer executed");
    }
    
    public ClassA() {
        System.out.println("ClassA constructor executed");
    }
    
    public void methodUsingClassB() {
        System.out.println("Method using ClassB called, but not using it yet");
    }
}

class ClassB {
    static {
        System.out.println("ClassB static initializer executed");
    }
    
    {
        System.out.println("ClassB instance initializer executed");
    }
    
    public ClassB() {
        System.out.println("ClassB constructor executed");
    }
}
```

```java
Main class loaded
ClassA static initializer executed
Class A static field: 10
Creating instance of ClassA
ClassA instance initializer executed
ClassA constructor executed
Calling method that uses ClassB
Method using ClassB called, but not using it yet
Creating instance of ClassB
ClassB static initializer executed
ClassB instance initializer executed
ClassB constructor executed
```
