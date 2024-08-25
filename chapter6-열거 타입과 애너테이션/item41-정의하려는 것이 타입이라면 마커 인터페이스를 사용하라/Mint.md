# 41. 정의하려는 것이 타입이라면 마커 인터페이스를 사용하라
### 마커 인터페이스
- 아무 메서드도 담고 있지 않고, 단지 자신을 구현하려는 클래스가 **특정 속성을 가짐을 표시해주는 인터페이스**
- `Serializable` : 자신을 구현한 클래스의 인스턴스는 `ObjectOutputStream`을 통해 쓸 수 있다고 알려준다.
    - 인터페이스 구현시 `java가 직렬화 기능`을 제공한다.
```java
public class Person implements Serializable {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    @Override
    public String toString() {
        return "Person{name='" + name + "', age=" + age + "}";
    }
}

public class SerializationDemo {
    public static void main(String[] args) {
        Person person = new Person("Alice", 30);

        // 직렬화
        try (ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("person.ser"))) {
            oos.writeObject(person);
            System.out.println("Person object serialized");
        } catch (IOException e) {
            e.printStackTrace();
        }

        // 역직렬화
        try (ObjectInputStream ois = new ObjectInputStream(new FileInputStream("person.ser"))) {
            Person deserializedPerson = (Person) ois.readObject();
            System.out.println("Deserialized person: " + deserializedPerson);
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
}
```

### 마커 애너테이션
- 멤버를 포함하지 않은 애너테이션
- 클래스, 메서드, 필드 등에 **메타데이터를 추가**하는 데 사용된다.
- `@Override`, `@Deprecated`

```java
// 마커 애너테이션 정의
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface Printable {
    // 멤버 없음
}


@Printable
public class Document {
    private String content;

    public Document(String content) {
        this.content = content;
    }

    public String getContent() {
        return content;
    }
}
```

## 마커 인터페이스는 마커 애너테이션보다 나은 점
### 1. 마커 인터페이스는 이를 구현한 클래스의 인스턴스들을 구분하는 타입으로 쓸 수 있으나, 마커 애너테이션은 그렇지 않다.
- 마커 인터페이스는 타입이므로 컴파일타임에 오류를 잡을 수 있다.
- 마커 애너테이션은 런타임에 오류를 잡을 수 있다.
### 2. 마커 인터페이스는 적용 대상을 더 정밀하게 지정할 수 있다.
- **마킹하고 싶은 클래스에서만 마커 인터페이스를 구현(확장)하면 된다.**
    - 특정 클래스나 그 하위 클래스에만 마킹을 적용하면 된다.
    - 객체의 특정 부분을 불변식으로 규정함을 나타낼 수 있다.
    - 해당 타입의 인스턴스는 다른 클래스의 특정 메서드가 처리할 수 있다는 사실을 명시할 수 있다. (Serializable)

- 마커 인터페이스는 `ElementType.TYPE` 을 선언하면 모든 타입(클래스, 인터페이스, 열거 타입, 애너테이션)에 달 수 있다.
    - 자세하게 지정할 수 없다.

## 마커 애너테이션이 마커 인터페이스보다 나은 점
- 마커 애너테이션은 거대한 애너테이션 시스템의 지원을 받는다.
    - 애너테이션을 적극 활용하는 프레임워크에서는 마커 애너테이션을 쓰는 쪽이 유리하다.

## 마커 애너테이션 vs 마커 인터페이스
- 클래스나 인터페이스 외의 프로그램 요소(모듈, 패키지, 필드, 지역변수)등에 마킹해야할때 애너테이션을 쓸 수 밖에 없다.
    - 클래스와 인터페이스만이 마커 인터페이스를 구현하거나 확장할 수 있기 때문이다.
- 마킹이 될 객체를 매개변수로 받는 메서드를 작성해야 할 일이 있을까?
    - "그렇다"면 마커 인터페이스를 써야 한다.
        - 컴파일 타임에 오류를 잡아낼 수 있다.
    - "아니다"면 마커 애너테이션을 쓰는 것이 좋다.
-  애너테이션을 활발하게 사용하는 프레임워크라면 마커 애너테이션을 쓰는 것이 좋다.

## 결론
- **새로 추가하는 메서드 없이 타입 정의가 목적**이라면 `마커 인터페이스`를 사용하자.
- **클래스나 인터페이스 외의 프로그램 요소에 마킹**한다면 `마커 애너테이션`을 사용하자.
- **애너테이션을 적극 활용하는 프레임워크**의 일부로 마커를 편입하고 싶다면 `마커 애너테이션`을 사용하자.
> 적용 대상이 ElementType.TYPE 인 마커 애너테이션을 작성하고 있다면, 마커 인터페이스가 낫지는 않을지 생각해보자.



