# 19. 상속을 고려해 설계하고 문서화하라. 그러지 않았다면 상속을 금지하라
## 상속을 고려한 설계화 문서화
- 상속용 클래스는 재정의할 수 있는 메서드들을 내부적으로 어떻게 이용하는지(자기사용) 문서로 남겨야 한다.
    - 호출되는 메서드가 **재정의 가능 메서드라면 호출하는 메서드의 API에 명시**해야 한다.
    - 어떤 **순서**로 호출하는지, 각각의 **호출 결과가 이어지는 처리에 어떤 영향을 주는지** 담아야 한다.
    - 재정의 가능 메서드를 호출할 수 있는 모든 상황을 문서로 남겨야 한다.

### 클래스를 안전하게 상속할 수 있도록 하려면 내부 구현 방식을 설명해야 한다.
- "좋은 API 문서란 어떻게가 아닌 무엇을 하는지를 설명해야 한다"와 대치된다.
- JavaDoc의 @implSpec 태그를 붙여주면 메서드의 내부 동작 방식을 설명하는 곳을 생성해준다.
### 클래스의 내부 동작 과정에 끼어들 수 있는 hook을 선별하여 protected로 공개하자.
- AbstactList의 removeRange 메서드는 protected로 공개되었다.
    - clear() 연산시 호출된다.
    - 이 메서드를 재정의하면 리스트와 부분 리스트의 clear 연산 성능을 크게 개선할 수 있어 공개하였다.
- 상속용 클래스 설계시 어떤 메서드를 protected로 노출해야할까?
    - **protected 메서드는 하나하나가 내부 구현에 해당하므로 그 수는 가능한 적어야 한다**.
    - 너무 적게 노출해서 상속으로 얻는 이점을 없애지 않아야 한다.
- **상속용 클래스를 시험하는 방법은 직접 하위 클래스를 만들어보는 것이 유일하다.**
    - 하위 클래스를 여러개 만들때까지 전혀 쓰이지 않는 protected 멤버는 사실 private이어야 할 가능성이 크다.
    - 검증에는 하위 클래스 3개 정도가 적당한다.
    - 상속용으로 설계한 클래스는 배포 전에 반드시 하위 클래스를 만들어 검증해야 한다.

### 상속용 클래스의 생성자는 재정의 가능 메서드를 호출해서는 안된다.
- 상위 클래스의 생성자가 하위 클래스의 생성자보다 먼저 실행되므로 **하위 클래스에서 재정의한 메서드가 하위 클래스의 생성자보다 먼저 호출된다**.
- 예시
```java
// 재정의 가능 메서드를 호출하는 생성자 - 따라 하지 말 것! (115쪽)  
public class Super {  
    // 잘못된 예 - 생성자가 재정의 가능 메서드를 호출한다.  
    public Super() {  
        overrideMe(); 
    }  
  
    public void overrideMe() {  
    }  
}
```

```java
// 생성자에서 호출하는 메서드를 재정의했을 때의 문제를 보여준다. (126쪽)  
public final class Sub extends Super {  
    // 초기화되지 않은 final 필드. 생성자에서 초기화한다.  
    private final Instant instant;  
  
    Sub() {  
        instant = Instant.now();  
    }  
  
    // 재정의 가능 메서드. 상위 클래스의 생성자가 호출한다.  
    @Override public void overrideMe() {  
        System.out.println(instant);  
    }  
  
    public static void main(String[] args) {  
        Sub sub = new Sub();  
        sub.overrideMe();  
    }  
}
```
- 하위 클래스 생성시 하위 클래스의 생성자는 상위 클래스의 생성자부터 호출한다.
- 상위 클래스의 생성자는 하위 클래스 생성자가 초기화되기 전에 하위 클래스가 오버라이드한 overrideMe 메서드를 호출한다.
- 첫번째는 null을 출력한다.
> private, final, static 메서드는 재정의가 불가능하니 생성자에서 안심하고 호출해도 된다.

## 상속 금지
### Cloneable과 Serializable 인터페이스 둘 중 하나라도 구현한 클래스를 상속하지 말자.
- clone과 readObject 메서드는 생성자와 비슷한 효과를 낸다.
    - 제약도 생성자와 비슷하다.
    - 즉, clone과 readObject 모두 직접적이든, 간접적이든 **재정의 가능한 메서드를 호출해서는 안된다.**
    - **readObject** : 하위 클래스의 상태가 미처 역직렬화되기 전에 재정의한 메서드부터 호출하게 된다.
    - **clone** : 하위 클래스의 clone 메서드가 복제본의 상태를 수정하기 전에 재정의한 메서드를 호출하게 된다.
        - 원본 객체까지도 피해를 줄 수 있다. 수정이 완전히 되지 않은 경우 복사본이 원본 객체를 참조하고 있기 때문이다.
- 만약 **Serializable을 구현한 상속용 클래스가 readResolve나 writeReplace를 갖는다면 private이 아닌 protected로 선언해야 한다.**
    - 상속해서 하위 클래스에서 커스텀할 수 있도록 하자.
    - readResolve : 역직렬화 과정에서 생성된 객체를 다른 객체로 대체
    - writeReplace : 직렬화 과정에서 실제 객체 대신 다른 객체를 대체하여 직렬화

> 클래스를 상속용으로 설계하렴면 엄청난 노력이 들고, 그 클래스에 안기는 제약도 상당하다.

### 상속용으로 설계하지 않은 클래스는 상속을 금지하자.
- 상속을 금지하는 방법
    1. **클래스를 final**로 선언
    2. **모든 생성자를 private이나 package-private으로 선언**하고 **public 정적 팩터리를 만드는 방법**
- 만약 구체 클래스를 상속해야한다면, 재정의 가능 메서드를 호출하는 자기사용 코드를 완벽하게 제거하라

#### 클래스의 동작을 유지하면서 재정의 가능 메서드를 사용하는 코드를 제거하는 방법
1. 재정의 가능 메서드들의 본문 코드를 private 도우미 메서드로 옮긴다.
2. 다른 메서드에서 이 도우미 메서드를 호출하도록 수정한다.
```java
public class Parent {
    public void doSomething() {
        // 전처리
        System.out.println("Preparing to do something");
        
        // private 도우미 메서드 호출
        doSomethingHelper();
        
        // 후처리
        System.out.println("Finished doing something");
    }

    // private 도우미 메서드
    private void doSomethingHelper() {
        System.out.println("Doing something in Parent");
    }

    // 다른 메서드에서도 도우미 메서드를 직접 호출
    public void anotherMethod() {
        System.out.println("Another method is calling the helper");
        doSomethingHelper();
    }
}
// 상속 예씨
public class Child extends Parent {
    @Override
    public void doSomething() {
        System.out.println("Child is doing something completely different");
    }
}

public class AnotherChild extends Parent {
    @Override
    public void doSomething() {
        System.out.println("AnotherChild is preparing to do something");
        
        super.doSomething();  // 부모의 전체 로직 실행
        
        System.out.println("AnotherChild finished and is doing extra work");
    }
}
```
- 핵심 로직을 private으로 두면,
    - **하위 클래스는 해당 메서드를 직접 오버라이드(재정의)할 수 없다.**
    - 핵심 로직이 보호되고 캡슐화된다.
    - 클래스 안에서 재사용이 가능하다.

## 결론
- 상속용 클래스를 설계하는 것은 엄청난 노력이 들고 제약도 상당하다.
    - **클래스 내부에서 스스로를 어떻게 사용하는지 모두 문서로 남겨야 한다.**
    - **일단 문서화한 것은 클래스가 쓰이는 한 반드시 지켜야 한다.**
- 효율 좋은 하위 클래스를 만들 수 있도록 **일부 메서드를 protected로 제공**해야할 수도 있다.
- **클래스를 확장할 명확한 이유가 없다면 상속을 금지하는 것이 낫다.**
    - 상속을 금지하려면 **클래스를 final로 선언**하거나 **생성자 모두를 외부에서 접근할 수 없도록** 만들면 된다.
