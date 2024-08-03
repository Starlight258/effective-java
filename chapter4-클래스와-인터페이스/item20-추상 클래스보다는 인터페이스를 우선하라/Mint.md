# 20. 추상 클래스보다는 인터페이스를 우선하라

### java가 제공하는 **다중 구현 메커니즘은 인터페이스와 추상 클래스**이다.
- **다중 구현** : 여러 기능을 조합해서 만드는 것
    - 한 클래스가 여러개의 인터페이스를 구현하거나, 하나의 추상 클래스를 상속받으면서 동시에 여러 인터페이스 구현하는 것
- 인터페이스와 추상 클래스 모두 디폴트 메서드를 제공한다.
- 추상 클래스 vs 인터페이스
    - **추상 클래스를 상속받는 클래스는 반드시 그 추상 클래스의 하위 클래스**가 된다.
    - **인터페이스를 구현한 클래스는** 다른 어떤 클래스를 상속했든 **해당 인터페이스 타입으로 취급**될 수 있다.
```java
interface Flyable {
    void fly();
}

class Vehicle { }

class Car extends Vehicle { }

class Airplane extends Vehicle implements Flyable {
    public void fly() {
        System.out.println("비행기가 날아갑니다.");
    }
}

class Bird implements Flyable {
    public void fly() {
        System.out.println("새가 날아갑니다.");
    }
}

public class Main {
    public static void main(String[] args) {
        Flyable airplane = new Airplane();
        Flyable bird = new Bird();
        
        airplane.fly();  // 비행기가 날아갑니다.
        bird.fly();      // 새가 날아갑니다.
    }
}
```

> 여러 인터페이스를 구현했더라도 해당 클래스의 인스턴스를 각 인터페이스 타입으로 다룰 수 있다.
```java
interface Flyable {
    void fly();
}

interface Swimmable {
    void swim();
}

class Duck implements Flyable, Swimmable {
    public void fly() {
        System.out.println("오리가 날아갑니다.");
    }

    public void swim() {
        System.out.println("오리가 수영합니다.");
    }

    public void quack() {
        System.out.println("꽥꽥!");
    }
}

public class Main {
    public static void main(String[] args) {
        Duck duck = new Duck();

        // Flyable 인터페이스로 다루기
        Flyable flyingDuck = duck;
        flyingDuck.fly(); 

        // Swimmable 인터페이스로 다루기
        Swimmable swimmingDuck = duck;
        swimmingDuck.swim(); 

        // Duck 클래스로 다루면 모든 메서드 사용 가능
        duck.fly();
        duck.swim();
        duck.quack();
    }
}
```

### 기존 클래스에도 손쉽게 새로운 인터페이스를 구현해넣을 수 있다.
- 인터페이스가 요구하는 메서드를 추가하고, 클래스 선언에 **implements** 구문만 추가하면 끝이다.
- **기존 클래스 위에 새로운 추상 클래스를 끼워넣기는 어렵다.**
    - 두 클래스가 같은 추상 클래스를 확장하길 원한다면, 그 추상 클래스는 계층구조상 두 클래스의 공통 조상이어야한다.
    - 새로 추가된 추상 클래스의 모든 자손이 이를 상속해야하므로 **클래스 계층구조에 혼란**을 주게 된다.

### 인터페이스는 **믹스인(mixin) 정의에 안성맞춤**이다.
- **믹스인**(mixin): 대상 타입의 주된 기능에 선택적 기능을 혼합한다.
- ex) Comparable 인터페이스는 자신을 구현한 클래스의 인스턴스들끼리는 순서를 정할 수 있다고 선언한다.
- **추상 클래스에는 믹스인을 정의할 수 없다.**
    - 기존 클래스를 덧씌울 수 없기 때문이다.
    - 클래스는 두 부모를 섬길 수 없고, 클래스 계층구조에는 믹스인을 삽입하기에 합리적인 위치가 없다.

###  인터페이스로는 계층 구조가 없는 타입 프레임워크를 만들 수 있다.
- 타입을 계층적으로 정의하면 구조적으로 잘 표현이 가능하지만, 현실에는 계층을 엄격히 구분하기 어려운 개념도 있다.
```java
public interface Singer {
	AutoClip sing(Song s);
}

public interface Songwriter {
	Song compose(int charPosition);
}

// Singer와 Songwriter를 섞은 제 3의 인터페이스
public interface SingerSongWriter extends Singer, Songwriter {
	AutoClip strum();
	void actSensitive();
}
```
- 인터페이스를 확장(extends)하여 새로운 인터페이스를 정의할 수 있다.
- 같은 구조를 클래스로 만드려면 가능한 조합 전부를 각 클래스로 정의한 고도비만 계층구조가 만들어진다.
    - 2^n : 조합 폭발이 일어난다.
    - 클래스는 단일 상속만 가능하기 때문이다.

### Wrapper 클래스 관용구와 함께 사용하면 인터페이스는 기능을 향상시키는 안전하고 강력한 수단이 된다.
- 타입을 **추상 클래스로 정의해두면 상속을 통해서만 기능을 추가**할 수 있다.
    - 상속해서 만든 클래스는 래퍼 클래스보다 활용도가 떨어지고 깨지기 더 쉽다.
- Wrapper 클래스를 통해 **런타임에 여러 기능을 자유롭게 조합**할 수 있다.
- 예시
    - 추상 클래스
```java
public abstract class AbstractCoffee {
    public abstract double getCost();
    public abstract String getDescription();
}

public class SimpleCoffee extends AbstractCoffee {
    @Override
    public double getCost() {
        return 1.0;
    }

    @Override
    public String getDescription() {
        return "Simple Coffee";
    }
}

public class MilkCoffee extends SimpleCoffee {
    @Override
    public double getCost() {
        return super.getCost() + 0.5;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + ", with Milk";
    }
}
// Sugar + Milk
public class SugarMilkCoffee extends MilkCoffee {
    @Override
    public double getCost() {
        return super.getCost() + 0.2;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + ", with Sugar";
    }
}
```
- 인터페이스 사용
```java
public interface Coffee {
    double getCost();
    String getDescription();
}

public class SimpleCoffee implements Coffee {
    @Override
    public double getCost() {
        return 1.0;
    }

    @Override
    public String getDescription() {
        return "Simple Coffee";
    }
}

// Wrapper 클래스 (데코레이터)
public abstract class CoffeeDecorator implements Coffee {
    protected Coffee decoratedCoffee;

    public CoffeeDecorator(Coffee coffee) {
        this.decoratedCoffee = coffee;
    }

    @Override
    public double getCost() {
        return decoratedCoffee.getCost();
    }

    @Override
    public String getDescription() {
        return decoratedCoffee.getDescription();
    }
}

public class MilkDecorator extends CoffeeDecorator {
    public MilkDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public double getCost() {
        return super.getCost() + 0.5;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + ", with Milk";
    }
}

public class SugarDecorator extends CoffeeDecorator {
    public SugarDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public double getCost() {
        return super.getCost() + 0.2;
    }

    @Override
    public String getDescription() {
        return super.getDescription() + ", with Sugar";
    }
}

public class Main {
    public static void main(String[] args) {
        Coffee coffee = new SimpleCoffee();

        Coffee milkCoffee = new MilkDecorator(coffee);

        Coffee sweetMilkCoffee = new SugarDecorator(new MilkDecorator(coffee)); // 런타임에 조합 가능
    }
}
```
인터페이스를 사용하면 런타임에 여러 기능을 조합할 수 있다.

### 인터페이스의 메서드 중 구현 방법이 명확한 것이 있다면 디폴트 메서드로 제공하면 된다.
- default 메서드를 제공할 경우 @implSpec 태그를 붙여 문서화해야한다.
- **`equals`나 `hashCode`같은 Object 메서드를 default 메서드로 제공해서는 안된다.**
    - `equals`나 `hashCode`는 객체의 동등성과 해시값을 정의하므로 객체의 상태에 기반하여 구현되어야 한다.
    - 인터페이스로 일반적인 `equals`나 `hashCode`를 제공하는 것보다는, 각 클래스에서 구현해야 한다.
- **인터페이스는 인스턴스 필드를 가질 수 없고, public이 아닌 정적 멤버도 가질 수 없다.(private 정적 메서드는 예외)**
    - 인터페이스는 contract를 정의한다. 인스턴스 필드는 상태를 나타내므로 구현의 세부사항에 해당한다. (추상화에 위반)
    - public이 아닌 정적 멤버는 계약의 일부가 아니므로 목적에 부합하지않는다.
    - private 정적 메서드의 경우 내부 구현 사항을 캡슐화하기 위해 허용되었다.
- **만들지 않은 인터페이스에는 디폴트 메서드를 추가할 수 없다.**
    - 인터페이스 제작자만 추가 가능하다.

### 인터페이스와 추상 골격 구현 클래스를 함께 제공하여 인터페이스와 추상 클래스의 장점을 모두 취할 수 있다.
- **인터페이스**로는 타입을 정의하고, 필요하면 디폴트 메서드 몇개도 함께 제공한다.
- **골격 구현 클래스**는 추상 클래스로, 인터페이스를 상속하여 구현하고, 공통 로직을 제공한다.
    - 보통 Abstract로 시작한다.
- **구체 클래스**는 골격 구현 클래스를 상속받아 나머지 메서드들까지 구현한다.
> 골격 구현 클래스에서 인터페이스의 대부분의 메서드를 구현하므로 구체 클래스의 구현이 용이하다.
```java
// 인터페이스
public interface List<E> {
    void add(E element);
    E get(int index);
    int size();
}

// 추상 골격 구현 클래스
public abstract class AbstractList<E> implements List<E> {
    // 공통 로직 구현
    public void add(E element) {
    }
    
    public E get(int index) {
    }
    
    // 추상 메서드 (하위 클래스에서 구현해야 함)
    public abstract int size();
    
    // 기타 유용한 메서드 구현
    public boolean isEmpty() {
        return size() == 0;
    }
}

// 구체 클래스, 추상 클래스 상속
public class ArrayList<E> extends AbstractList<E> {
    public int size() {
    }
}
```
> 템플릿 메서드 패턴 : 알고리즘의 골격을 정의하고 일부 단계를 하위 클래스에서 구현한다.
- 구체클래스 예시 2
```java
// 코드 20-1 골격 구현을 사용해 완성한 구체 클래스 (133쪽)  
public class IntArrays {  
    static List<Integer> intArrayAsList(int[] a) {  
        Objects.requireNonNull(a);  
  
        // 다이아몬드 연산자를 이렇게 사용하는 건 자바 9부터 가능하다.  
        // 더 낮은 버전을 사용한다면 <Integer>로 수정하자.  
        return new AbstractList<>() {  
            @Override public Integer get(int i) {  
                return a[i];  // 오토박싱(아이템 6)            
			}  
  
            @Override public Integer set(int i, Integer val) {  
                int oldVal = a[i];  
                a[i] = val;     // 오토언박싱  
                return oldVal;  // 오토박싱  
            }  
  
            @Override public int size() {  
                return a.length;  
            }  
        };  
    }  
  
    public static void main(String[] args) {  
        int[] a = new int[10];  
        for (int i = 0; i < a.length; i++)  
            a[i] = i;  
  
        List<Integer> list = intArrayAsList(a);  
        Collections.shuffle(list);  
        System.out.println(list);  
    }  
}
```
> int 배열을 받아 Integer 인스턴스의 리스트 형태로 보여주는 어댑터이다.

- 골격 구현 클래스는 추상 클래스처럼 구현을 도와주는 동시에 추상 클래스의 제약에서는 자유롭다.
#### 골격 구현 클래스 작성 방법
1. 인터페이스를 잘 살펴 **다른 메서드들의 구현에 사용되는 기반 메서드**들을 선정한다. (골격 구현 클래스의 추상 메서드 선정)
2. 기반 메서드들을 사용해 **직접 구현할 수 있는 메서드를 모두 디폴트 메서드로 제공**한다.
3. 기반 메서드나 디폴트 메서드로 만들지 못한 메서드가 남아 있다면, 이 인터페이스를 구현하는 골격 구현 클래스를 만들어 남은 메서드를 구현한다.
    - 필요하면 public이 아닌 필드와 메서드를 추가해도 된다.
```java
// 코드 20-2 골격 구현 클래스 (134-135쪽)  
public abstract class AbstractMapEntry<K,V>  
        implements Map.Entry<K,V> {  
    // 변경 가능한 엔트리는 이 메서드를 반드시 재정의해야 한다.  
    @Override public V setValue(V value) {  
        throw new UnsupportedOperationException();  
    }  
      
    // Map.Entry.equals의 일반 규약을 구현한다.  
    @Override public boolean equals(Object o) {  
        if (o == this)  
            return true;  
        if (!(o instanceof Map.Entry))  
            return false;  
        Map.Entry<?,?> e = (Map.Entry) o;  
        return Objects.equals(e.getKey(),   getKey())  
                && Objects.equals(e.getValue(), getValue());  
    }  
  
    // Map.Entry.hashCode의 일반 규약을 구현한다.  
    @Override public int hashCode() {  
        return Objects.hashCode(getKey())  
                ^ Objects.hashCode(getValue());  
    }  
  
    @Override public String toString() {  
        return getKey() + "=" + getValue();  
    }  
}
```
- getKey, getValue는 기반 메서드(추상 메서드)
    - setValue도 선택적으로 기반 메서드로 포함 가능
- equals나 hashCode는 인터페이스의 default 메서드로 제공하면 안되므로 골격 구현 클래스에 구현
- toString도 기반 클래스(getKey, getValue를 통해 구현)
> 골격 구현은 기본적으로 상속해서 사용하는 것을 가정하므로 설계 및 문서화 지침을 모두 따라야 한다.

#### 골격 구현 클래스를 확장할 수 없는 경우
- 인터페이스를 직접 구현해도 된다.
- 인터페이스를 구현한 클래스에서 **해당 골격 구현을 확장한 private 내부 클래스**를 정의하고, 각 **메서드 호출을 내부 클래스의 인스턴스에 전달**한다.
    - 시뮬레이트한 다중 상속(다중 상속을 흉내낸다)
```java
public interface MyInterface {
    void method1();
    void method2();
}

// 골격 구현 클래스
abstract class AbstractMyInterface implements MyInterface {
    public void method1() {
        System.out.println("Method 1 implementation");
    }
}

public class MyClass implements MyInterface {
    private class InnerClass extends AbstractMyInterface { // 골격 구현을 확장한 private 내부 클래스
        @Override
        public void method2() {
            System.out.println("Method 2 implementation");
        }
    }

    private final InnerClass inner = new InnerClass();

    @Override
    public void method1() {
        inner.method1();
    }

    @Override
    public void method2() {
        inner.method2();
    }
}
```

#### 단순 구현
- java.util의 AbstractMap.simpleEntry
```java
public static class SimpleEntry<K,V>  
    implements Entry<K,V>, java.io.Serializable  
{  
    @java.io.Serial  
    private static final long serialVersionUID = -8499721149061103585L;  
  
    @SuppressWarnings("serial") // Conditionally serializable  
    private final K key;  
    @SuppressWarnings("serial") // Conditionally serializable  
    private V value;  
  
    public SimpleEntry(K key, V value) {  
        this.key   = key;  
        this.value = value;  
    }  
  
    public SimpleEntry(Entry<? extends K, ? extends V> entry) {  
        this.key   = entry.getKey();  
        this.value = entry.getValue();  
    }  
  
   public K getKey() {  
        return key;  
    }  
  
   public V getValue() {  
        return value;  
    }  
  
   public V setValue(V value) {  
        V oldValue = this.value;  
        this.value = value;  
        return oldValue;  
    }
    //...
}
```
- 골격 구현의 작은 변종으로, **상속을 위해 인터페이스를 구현했지만 추상 클래스가 아니란 점**이 다르다.
- 동작하는 가장 단순한 구현이다.
- 필요에 따라 확장해도 된다.

## 결론
- **다중 구현용 타입으로는 인터페이스가 가장 적합**하다.
- **복잡한 인터페이스라면 구현하는 수고를 덜어주는 골격 구현을 함께 제공**하는 방법을 고려해보자.
- **골격 구현**은 가능한 한 **인터페이스의 디폴트 메서드로 제공**하여 **인터페이스를 구현한 모든 곳에서 활용**하도록 하는 것이 좋다.
    - 인터페이스를 구현한 모든 클래스가 자동으로 구현을 상속받을 수 있다.
    - '가능한 한'이라고 한 이유는, 인터페이스에 걸려 있는 구현상의 제약 때문에 **골격 구현을 추상 클래스로 제공하는 경우가 더 흔하기 때문**이다.
        - 제약 1: 상태를 가지는 메서드나 private 메서드를 작성할 수 없다.
        - 제약 2: 인터페이스 작성자가 아니면 디폴트 메서드를 추가할 수 없다.

