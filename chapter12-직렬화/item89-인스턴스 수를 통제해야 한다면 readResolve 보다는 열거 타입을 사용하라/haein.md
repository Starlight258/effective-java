## 요약

### 직렬화는 싱글턴을 깨지게 만든다
- 기본 직렬화를 쓰지 않더라도, 명시적인 `readObject` 를 제공하더라도 클래스가 초기화될 때 만들어진 인스턴스와는 완전히 별개인
인스턴스를 반환하게 된다
- `readReslove` 를 적절히 정의하여 싱글턴을 유지할 수 있다
- 역직렬화된 객체를 인수로 이 메서드가 호출되고, 이 메서드가 반환한 객체 참조가 새로 생성된 객체를 대신해 반환된다 

```java
private Object readResolve(){
    return INSTANCE;
}
```
- 역직렬화된 객체를 무시하고 클래스 초기화 때 만들어진 인스턴스를 반환한다
- 새로 생성된 객체는 바로 가비지 컬렉션의 대상이 된다 
- 따라서 직렬화 형태는 모든 인스턴스 필드를 `transient` 로 선언해야 한다 


### `readResolve` 공격 방법 
- `readResolve` 메서드와 인스턴스 필드 하나를 포함한 도둑(stealer) 클래스를 작성한다
- 인스턴스 필드는 도둑이 숨길 직렬화된 싱글턴을 참조하는 역할을 한다 
- 직렬화된 스트림에서 싱글턴의 비휘발성 필드를 이 도둑의 인스턴스로 교체한다 
- 싱글턴은 도둑을 탐조하고 도둑은 싱글턴을 참조하는 순환고리가 만들어진다 
- 도둑의 `readResolve` 가 역직렬화 때 먼저 호출되므로 도둑의 인스턴스 필드에는 역직렬화 도중이며, `readResolve` 가 수행되기 전의 싱글턴의 참조가 담겨 있게 된다 


```java
public class Elvis implements Serializable{
    public static final Elvis INSTANCE = new ELvis();
    private Elvis(){}

    private String[] favoriteSongs = {"Hound Dog', "Heartbreak Hotel};
    
    public void printFavorites(){
        System.out.println(Arrays.toString(favoriteSongs));
    }

    private Object readResolve(){
        return INSTANCE;
    }
}


public class ElvisStealer implements Serializable{
    static Elvis impersonator;
    private Elvis payload;

    private Object readResolve(){
        // resolve 되기 전의 ELvis 인스턴스의 참조를 저장한다.
        impersonator = payload;

        // favoriteSongs 필드에 맞는 타입의 객체를 반환한다.
        return new String[] 
        {"A Fool Such as I"};
    }

    private static final long serialVersionUID = 0;
}
```
- 이 문제는 열거 타입을 사용하여 간단하게 해결할 수 있다

```java
public enum Elvis {
    INSTANCE;

    private String[] favoriteSongs = { "Dog", "Hotel" };

    public void printFavorites() {
        System.out.println(Arrays.toString(favoriteSongs));
    }
}
```
- 선언한 상수 외의 다른 객체가 존재하지 않음을 자바가 보장해준다
- 직렬화 가능 인스턴스 통제 클래스를 작성할 때, 컴파일타임에는 어떤 인스턴스들이 있는지 알 수 없는 상황이라면 `readResolve` 를 사용해야 한다

### `readResolve` 접근성
- `final` 클래스에서라면 `private` 로 설정한다
- `final` 이 아닌 클래스
    1. `private` 로 선언하면 하위 클래스에서 사용할 수 없다
    1. `package-private` 로 선언하면 같은 패키지에 속한 하위 클래스가 사용할 수 있다
    1. `protected` 나 `public` 로 선언하면 이를 재정의하지 않은 모든 하위 클래스에서 사용할 수 있다 
        - `readResolve` 를 재정의하지 않았다면 역직렬화할 때 상위 클래스의 인스턴스를 생성하여 `ClassCastException` 을 일으킬 수 있다