# 13. clone 재정의는 주의해서 진행하라

- Cloneable은 복제해도 되는 클래스임을 명시하는 용도의 믹스인 인터페이스(기능 혼합)이지만, 의도한 목적을 제대로 이루지 못했다.
- clone 메서드가 선언된 곳이 Object이고 protected이다.
    - 따라서 Cloneable을 구현하는 것만으로는 외부 객체에서 clone 메서드를 호출할 수 없다.
    - 리플렉션을 사용하면 가능하지만 객체가 접근이 허용된 clone()을 제공하지 않을 경우 실패한다.
- 하지만 Cloneable 방식은 널리 쓰이고 있어 잘 알아두는 것이 좋다.

### Cloneable 인터페이스

- 어떤 메서드도 정의하지 않는다.
- 단지 **Object의 protected 메서드인 clone의 동작 방식을 결정**한다.
    - Cloneable을 구현한 클래스의 인스턴스에서 **clone을 호출하면 그 객체의 필드들을 하나하나 복사한 객체를 반환**한다.
    - Cloneable을 구현하지 않은 클래스에서 clone을 호출하면 **CloneNotSupportedException**을 던진다.
- Cloneable은 상위 클래스(Object)에 정의된 protected 메서드의 동작 방식을 변경했다.
    - 일반적으로 인터페이스를 구현한다는 것은 해당 클래스가 그 인터페이스에 정의한 기능을 제공한다고 선언하는 것이다.
    - Cloneable은 일반적인 인터페이스를 이례적으로 사용했다. (따라하지 말자)

### Cloneable 구현 클래스

- 실무에서 Cloneable을 구현한 클래스는 clone 메서드를 public으로 제공하며, 사용자는 당연히 복제가 제대로 이뤄지리라 기대한다.
- clone을 통해 생성자를 호출하지 않고도 객체를 생성할 수 있게 된다. (매우 위험하고 허술하다.)

## clone 메서드의 일반 규약

- clone()은 객체의 복사본을 생성해 반환한다.
- x.clone() != x
- x.clone().getClass() == x.getClass()
- x.clone.equals(x) : 일반적으로 참이지만 필수는 아니다.
- x.clone().getClass() == x.getClass() : 모든 상위 클래스가 이 관례를 따른다면 참이다.
- 관례상 반환된 객체와 원본 객체는 독립적이어야 한다.

### clone() 이 생성자를 호출하여 인스턴스를 반환한다면?

- 클래스의 하위 클래스에서 super.clone을 호출한다면 잘못된 클래스의 객체가 만들어져, 결국 하위 클래스의 clone 메서드가 제대로 동작하지 않는다.
    - 상위 클래스를 더 구체적인 하위 클래스로 캐스팅할 수 없다.

```java
class Parent implements Cloneable {
    @Override
    public Parent clone() {
        return new Parent();
    }
}

class Child extends Parent {
    private int childField;

    public Child(int childField) {
        this.childField = childField;
    }

    @Override
    public Child clone() {
        Child cloned = (Child) super.clone();
        // ClassCastException 발생! Parent를 하위 클래스로 캐스팅 불가
        cloned.childField = this.childField;
        return cloned;
    }
}

    Child original = new Child(5);
    Child cloned = original.clone();  // ClassCastException 발생
```

- clone을 재정의한 클래스가 final이라면 하위 클래스가 없으니 무시해도 된다.
    - final 클래스의 clone 메서드가 **super.clone을 호출하지 않는다면 Cloneable을 구현할 이유도 없다**.

## 불변 클래스 복제

### 불변 클래스는 굳이 clone 메서드를 제공하지 않는게 좋다.

- 불변 객체는 복제해도 원본과 똑같기 때문에 새로운 객체를 만들 필요가 없다. (기존 객체를 반환하면 된다)

#### 참고

```java
// 코드 13-1 가변 상태를 참조하지 않는 클래스용 clone 메서드 (79쪽)  
@Override public PhoneNumber clone(){
        try{
        return(PhoneNumber)super.clone();
        }catch(CloneNotSupportedException e){
        throw new AssertionError();  // 일어날 수 없는 일이다.  
        }
        }
```

- 공변 반환 타이핑 : 재정의한 메서드의 반환 타입은 상위 클래스의 메서드가 반환하는 타입의 하위 타입일 수 있다.
- CloneNotSupportedException은 검사 예외지만 사실은 비검사 예외였어야했다.

## 가변 클래스 복제

```java
package effectivejava.chapter3.item13;

import java.util.Arrays;

// Stack의 복제 가능 버전 (80-81쪽)  
public class Stack implements Cloneable {
    private Object[] elements;
    private int size = 0;
    private static final int DEFAULT_INITIAL_CAPACITY = 16;

    public Stack() {
        this.elements = new Object[DEFAULT_INITIAL_CAPACITY];
    }

    public void push(Object e) {
        ensureCapacity();
        elements[size++] = e;
    }

    public Object pop() {
        if (size == 0)
            throw new EmptyStackException();
        Object result = elements[--size];
        elements[size] = null; // 다 쓴 참조 해제  
        return result;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    // 원소를 위한 공간을 적어도 하나 이상 확보한다.  
    private void ensureCapacity() {
        if (elements.length == size)
            elements = Arrays.copyOf(elements, 2 * size + 1);
    }
}
```

=> elements 필드는 원본 Stack 인스턴스와 똑같은 배열을 참조하므로 원본이나 복제본 중 하나를 수정하면 다른 하나도 수정되어 불변식을 해친다.

### clone 메서드는 사실상 생성자와 같은 효과를 낸다

- . 즉, clone은 **원본 객체에 아무런 해를 끼치지 않는 동시에 복제된 객체의 불변식을 보장**해야한다.
- elements 배열의 clone을 재귀적으로 호출한다.

```java
// 코드 13-2 가변 상태를 참조하는 클래스용 clone 메서드  
@Override public Stack clone(){
        try{
        Stack result=(Stack)super.clone();
        result.elements=elements.clone();
        return result;
        }catch(CloneNotSupportedException e){
        throw new AssertionError();
        }
        }

// clone이 동작하는 모습을 보려면 명령줄 인수를 몇 개 덧붙여서 호출해야 한다.  
public static void main(String[]args){
        Stack stack=new Stack();
        for(String arg:args)
        stack.push(arg);
        Stack copy=stack.clone();
        while(!stack.isEmpty())
        System.out.print(stack.pop()+" ");
        System.out.println();
        while(!copy.isEmpty())
        System.out.print(copy.pop()+" ");
        }  
```

> 배열을 복제할 때는 배열의 clone 메서드를 사용하라고 권장한다.(clone 기능을 사용하는 유일한 예시)

- elements 필드가 final이라면 작동하지 않는다. 새로운 값을 할당할 수 없기 때문이다.
    - Cloneable 아키텍처는 가변 객체를 참조하는 필드는 final로 선언하라는 일반 용법과 충돌한다.

### 깊은 복사를 지원해야 할 때도 있다.

- 참조 타입의 배열의 경우 복제본은 자신만의 버킷 배열을 갖지만, 이 배열은 원본과 같은 연결리스트를 참조하기 때문이다.

```java
public class HashTable implements Cloneable {
    private Entry[] buckets = ...;

    private static class Entry {
        final Object key;
        Object value;
        Entry next;

        Entry(Object key, Object value, Entry next) {
            this.key = key;
            this.value = value;
            this.next = next;
        }

        // 이 엔트리가 가리키는 연결 리스트를 재귀적으로 복사
        Entry deepCopy() {
            return new Entry(key, value, next == null ? null : next.deepCopy());
        }
    }

    @Override
    public HashTable clone() {
        try {
            HashTable result = (HashTable) super.clone();
            result.buckets = new Entry[buckets.length];
            for (int i = 0; i < buckets.length; i++)
                if (buckets[i] != null)
                    result.buckets[i] = buckets[i].deepCopy();
            return result;
        } catch (CloneNotSupportedException e) {
            throw new AssertionError();
        }
    }
}
```

- 깊은 복사를 지원하면 된다.
    - Entry의 deepCopy 메서드는 반복자를 써서 순회하여 복사한다.

```java
private static class Entry {
    final Object key;
    Object value;
    Entry next;

    Entry(Object key, Object value, Entry next) {
        this.key = key;
        this.value = value;
        this.next = next;
    }

    // 이 엔트리가 가리키는 연결 리스트를 반복적으로 복사
    Entry deepCopy() {
        Entry result = new Entry(key, value, next);
        for (Entry p = result; p.next != null; p = p.next)
            p.next = new Entry(p.next.key, p.next.value, p.next.next);
        return result;
    }
}
```

### 고수준 메서드를 호출한다.

1. 먼저 super.clone을 호출하여 얻은 객체의 모든 필드를 초기 상태로 설정한다.
2. 원본 객체의 상태를 다시 생성하는 고수준 메서드들을 호출한다.
    - HashTable 예시라면 buckets 필드를 새로운 버킷 배열로 초기화한다음 원본 테이블에 담긴 모든 키-값 쌍 각각에 대해 복제본 테이블의 put 메서드를 호출해 내용을 같게 한다.
    - 고수준 메서드는 저수준에서 바로 처리할때보다는 느리다.
    - 필드 단위 객체 복사를 우회하므로 Cloneable 아키텍처와 어울리지 않기도 한다.

### 기타 주의사항

#### 하위 클래스에서 재정의될 수 있는 메서드는 호출해서는 안된다.

- clone이 하위 클래스에서 재정의한 메서드를 호출하면 원본과 복제본의 상태가 달라질 가능성이 크다.
    - HashTable의 경우 put 메서드는 **final**이거나 **private**(public의 도우미 메서드)여야 한다.

#### public인 clone 메서드에서는 throws 절을 없애야 한다.

- 검사 예외를 던지지 않아야 메서드를 사용하기 편하다.

#### 상속용 클래스는 Cloneable을 구현해서는 안된다.

- 하위 클래스에서 재정의하지 못하도록 막을 수 있다.

```java
@Override public Object clone()throws CloneNotSupportedException{
        throw new CloneNotSupportedException();
        }
```

> 또는 구현 여부를 하위 클래스에서 선택할 수 있도록 할 수 있다.

#### Cloneable을 구현한 스레드 안전 클래스를 작성할 때는 clone메서드 동기화해줘야 한다.

### Cloneable 요약

- Cloneable을 구현하는 모든 클래스는 clone을 재정의해야 한다.
    - 접근 제어자는 public으로, 반환 타입은 클래스 자신으로 변경한다.
    - super.clone을 호출한 후 필요한 필드를 적절히 수정한다.
        - 즉, 모든 가변 객체를 복사하고, 복제본이 가진 객체 참조 모두가 복사된 객체들을 가리키게 한다.
        - 불변 객체의 경우 일련번호와 고유 id의 경우 수정해야한다.

### 객체 복사 방식은 복사 생성자와 복사 팩터리를 사용할 수 있다.

- Cloneable을 구현하는 것보다 더 나은 방식이다.
- 복사 생성자란 단순히 자신과 같은 클래스의 인스턴스를 인수로 받는 생성자를 말한다.

```java
public Yum(Yum yum){...};
```

- 복사 팩터리는 복사 생성자를 모방한 정적 팩터리다.

```java
public static Yum newInstance(Yum yum){...};
```

- 생성자를 사용하며 final 필드 용법과도 충돌하지 않으며 불필요한 검사 예외를 던지지 않고 형변환도 필요하지 않다.
- 복사 생성자와 복사 팩터리는 **해당 클래스가 구현한 인터페이스 타입의 인스턴스를 인수**로 받을 수 있다.
    - 모든 범용 컬렉션 구현체는 Collection이나 Map 타입을 받는 생성자를 제공한다.
    - 원본의 구현 타입에 얽매이지 않고 복제본의 타입을 직접 선택할 수 있다.

```java
interface Animal {
    String makeSound();
}

class Dog implements Animal {
    @Override
    public String makeSound() {
        return "Woof!";
    }
}

class Cat implements Animal {
    @Override
    public String makeSound() {
        return "Meow!";
    }
}

class AnimalShelter {
    private List<Animal> animals;

    // 기본 생성자
    public AnimalShelter() {
        this.animals = new ArrayList<>();
    }

    // 복사 생성자
    public AnimalShelter(Collection<? extends Animal> animals) {
        this.animals = new ArrayList<>(animals);
    }

    // 복사 팩터리 메서드
    public static AnimalShelter newInstance(Collection<? extends Animal> animals) {
        return new AnimalShelter(animals);
    }

    public void addAnimal(Animal animal) {
        animals.add(animal);
    }

    public void makeAllSounds() {
        for (Animal animal : animals) {
            System.out.println(animal.makeSound());
        }
    }
}

public class Main {
    public static void main(String[] args) {
        AnimalShelter originalShelter = new AnimalShelter();
        originalShelter.addAnimal(new Dog());
        originalShelter.addAnimal(new Cat());

        // 복사 생성자를 사용한 복제
        AnimalShelter copiedShelter1 = new AnimalShelter(originalShelter.getAnimals());

        // 복사 팩터리를 사용한 복제
        AnimalShelter copiedShelter2 = AnimalShelter.newInstance(originalShelter.getAnimals());

        List<Animal> animalList = new LinkedList<>();
        animalList.add(new Dog());
        animalList.add(new Cat());
        AnimalShelter linkedListShelter = new AnimalShelter(animalList);

        System.out.println("Original Shelter:");
        originalShelter.makeAllSounds();

        System.out.println("\nCopied Shelter 1:");
        copiedShelter1.makeAllSounds();
    }
}
```

### 결론

- **새로운 인터페이스를 만들 때는 절대 Cloneable을 확장해서는 안되며, 새로운 클래스도 이를 구현해서는 안된다**.
- final 클래스라면 Cloneable을 구현해도 위험이 크지는 않지만 성능 최적화 관점에서 검토한 후 드물게 허용하자.
- 기본 원칙은 "**복제 기능은 생성자와 팩터리를 이용하는 것이 최고**"라는 것이다.
- 배열만은 clone 메서드 방식이 가장 깔끔한, 이 규칙의 합당한 예외이다.

 
