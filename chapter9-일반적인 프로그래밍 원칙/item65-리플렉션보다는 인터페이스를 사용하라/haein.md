## 자바 리플렉션(Reflection) - java.lang.relfect

- 자바 런타임에 동작하여 클래스의 타입, 생성자, 메서드에 접근하게 해주는 API
- JVM static area 에 로드된 클래스 정보를 통해, 컴파일 시점에 타입 정보를 모르더라도 클래스에 접근하여 동적 로딩이 가능하게 함

```java
Class<?> myClass = Class.forname("mypackage.myclass"); // Class 객체 생성

Constructor<?> constructor = myClass.getDeclaredConstructor(); // 생성자 가져오기
 
constructor.newInstance(); // 생성자를 통해 새로운 인스턴스 생성하기

Field[] fields = myClass.getDeclaredFields(); // 필드 가져오기 

Annotation[] annotations = myClass.getAnnotations(); // 어노테이션 정보 가져오기 , @Retetnion(Runtime) 인 것에 한정함

Method[] methods = myClass.getDeclaredMethods(); // 메소드 가져오기 

method.invoke(obj, params) // 특정 메소드 실행하기 

```

조회를 원하는 타입의 Class 객체를 만들고 생성자, 필드, 메서드등에 접근할 수 있다

## 요약


### 그럼에도 불구하고.. 리플렉션의 단점

- 컴파일 검사의 이점을 누릴 수 없음 (타입 검사 예외 검사) + 런타임에 발생할 수 있는 문제에 대한 꼼꼼한 예외처리가 필요함
- 코드가 장황해짐
- 성능 문제

리플렉션은 아주 제한된 형태로만 사용해야 그 이점만을 누릴 수 있음!

```java
public class ReflectiveInstantiation {

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

- 컴파일 타임에 클래스 정보를 이용할 순 없으나, 상위 클래스나 인터페이스를 참조할 수 있는 경우의 예제
- 타입을 명령줄 인수로 받기 때문에 원소들의 정렬 유무를 런타임 이후에 알 수 있음(`Treeset`, `Hashset` 등)
- 제네릭 집합의 테스터나, 성능 비교 프로그램으로 활용
- 위 코드에서 볼 수 있는 단점
    - 런타임 중에 6가지나 되는 예외를 던질 수 있음 - `ReflectiveOperationException` 를 이용해 줄일 수는 있음
    - 리플렉션을 통해 인스턴스를 생성하려고 25줄이나 사용함
    

### 리플렉션을 사용하는 경우
- 리플렉션은 런타임에 존재하지 않을 수도 있는 다른 클래스, 메서드, 필드와의 의존성을 관리할 때 적합하다
- 버전이 여러 개 존재하는 외부 패키지를 다룰 때 유용하다
- 가장 오래된 버전만을 지원하도록 컴파일한 후, 이후 버전의 클래스와 메서드 등은 리플렉션으로 접근



> 결론은 리플렉션은 인스턴스 생성에만 쓰고 인터페이스나 상위클래스로 참조하여 사용하자 