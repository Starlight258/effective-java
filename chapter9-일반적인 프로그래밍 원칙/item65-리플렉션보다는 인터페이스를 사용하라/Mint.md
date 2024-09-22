# 65. 리플렉션보다는 인터페이스를 사용하라
## 리플렉션 기능
- 프로그램에서 임의의 클래스에 접근할 수 있다.
- Class 객체가 주어지면 그 클래스의 생성자, 메서드, 필드에 해당하는 인스턴스를 가져올 수 있다.
    - 인스턴스들로는 그 클래스의 멤버 이름, 필드 타입, 메서드 시그니처 등을 가져올 수 있다.
    - 인스턴스를 이용해 각각에 연결된 실제 생성자, 메서드, 필드를 조작할 수 있다. (생성/호출/접근)
- 컴파일 당시에 존재하지 않던 클래스도 이용할 수 있다.

### 리플렉션 단점
- **컴파일타임 타입 검사가 주는 이점을 하나도 누릴 수 없다.**
    - 존재하지 않거나 접근할 수 없는 메서드를 호출하면 `런타임 오류`가 발생한다.
- **리플렉션을 이용하면 코드가 지저분하고 장황해진다.**
- **성능이 떨어진다.**
    - 리플렉션을 통한 메서드 호출은 일반 메서드 호출보다 훨씬 느리다.

## 리플렉션은 아주 제한된 형태로만 사용하자
- 컴파일 타임에 이용할 수 없는 클래스를 사용해야하는 경우
    - **리플렉션은 인스턴스 생성**에만 쓰고, 이렇게 만든 인스턴스는 **인터페이스나 상위 클래스로 참조**해 사용하자.
- 리플렉션을 활용한 인스턴스화를 통해 `규약을 검사`하거나 `성능 분석 도구`로 사용할 수 있다.
    - 아래 코드는 `Set 구현체`를 조작해보며 `Set 규약`을 잘 지키는지 검사할 수 있다.
    - `제네릭 집합 성능 분석 도구`로 활용할 수 있다.

```java
// 리플렉션으로 활용한 인스턴스화 데모  
public class ReflectiveInstantiation {  
    // 코드 65-1 리플렉션으로 생성하고 인터페이스로 참조해 활용한다. (372-373쪽)  
    public static void main(String[] args) {  
        // 클래스 이름을 Class 객체로 변환  
        Class<? extends Set<String>> cl = null;  
        try {  
            cl = (Class<? extends Set<String>>)  // 비검사 형변환!  
                    Class.forName(args[0]);  
        } catch (ClassNotFoundException e) {  
            fatalError("클래스를 찾을 수 없습니다.");  
        }  
  
        // 생성자를 얻는다.  
        Constructor<? extends Set<String>> cons = null;  
        try {  
            cons = cl.getDeclaredConstructor();  
        } catch (NoSuchMethodException e) {  
            fatalError("매개변수 없는 생성자를 찾을 수 없습니다.");  
        }  
  
        // 집합의 인스턴스를 만든다.  
        Set<String> s = null;  
        try {  
            s = cons.newInstance();  
        } catch (IllegalAccessException e) {  
            fatalError("생성자에 접근할 수 없습니다.");  
        } catch (InstantiationException e) {  
            fatalError("클래스를 인스턴스화할 수 없습니다.");  
        } catch (InvocationTargetException e) {  
            fatalError("생성자가 예외를 던졌습니다: " + e.getCause());  
        } catch (ClassCastException e) {  
            fatalError("Set을 구현하지 않은 클래스입니다.");  
        }  
  
        // 생성한 집합을 사용한다.  
        s.addAll(Arrays.asList(args).subList(1, args.length));  
        System.out.println(s);  
    }  
  
    private static void fatalError(String msg) {  
        System.err.println(msg);  
        System.exit(1);  
    }  
}
```
> 예외 5가지를 잡는데, 리플렉션 없이 생성했다면 컴파일 타임에 잡을 수 있는 예외들이다.
> ReflectiveOperationException을 잡도록 하여 코드 길이를 줄일 수 있다.

## 결론
- 리플렉션은 `복잡한 특수 시스템`을 개발할 때 필요하지만, 단점도 많다.
    - **컴파일 타임에 알 수 없는 클래스를 사용하는 프로그램**을 작성한다면 리플렉션을 사용해야한다.
    - 하지만 리플렉션은 되도록 **객체 생성**에만 사용하자.
    - 생성한 객체를 이용할 때는 **적절한 인터페이스나 컴파일타임에 알 수 없는 상위 클래스로 형변환해 사용**해야 한다.
