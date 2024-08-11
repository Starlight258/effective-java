# 25. 톱레벨 클래스는 한 파일에 하나만 담으라
- **소스 파일 하나에 톱레벨 클래스를 여러 개 선언**해도 된다.
    - 하지만 아무런 이득이 없을 뿐더러, **심각한 위험**을 감수해야 한다.
    - **한 클래스를 여러 가지로 정의**할 수 있으며, **어느 소스 파일을 먼저 컴파일하느냐에 따라 어떤 파일의 클래스를 사용할지 달라진다**.
- 예시
```java
// (150쪽)  
public class Main {  
    public static void main(String[] args) {  
        System.out.println(Utensil.NAME + Dessert.NAME);  
    }  
}
```
`Utensil.java`
```java
  
// 코드 25-1 두 클래스가 한 파일(Utensil.java)에 정의되었다. - 따라 하지 말 것! (150쪽)  
class Utensil {  
    static final String NAME = "pan";  
}  
  
class Dessert {  
    static final String NAME = "cake";  
}
```
`Dessert.java`
```java
// 코드 25-2 두 클래스가 한 파일(Dessert.java)에 정의되었다. - 따라 하지 말 것! (151쪽)  
class Utensil {  
    static final String NAME = "pot";  
}  
  
class Dessert {  
    static final String NAME = "pie";  
}
```

- `javac Main.java Dessert.java`
```
컴파일 오류
에러명 : Utensil과 Dessert 클래스 중복 정의
```
`Main`.java -> `Utensil` 참조 -> `Dessert` 에서 클래스 중복 정의 에러

- `javac Main.java`
```
pancake
```
`Main`-> `Utensil` 참조
- `javac Main.java Utensil.java`
```
pancake
```
`Main`->`Utensil` 참조

> 컴파일러에 어느 소스 파일을 먼저 건네느냐에 따라 동작이 달라진다.

### 해결 방법 : 톱레벨 클래스를 서로 다른 소스 파일로 분리하자
- Utensil과 Dessert를 서로 다른 소스 파일로 분리하면 된다.
- 다른 클래스에 딸린 부차적인 클래스라면 정적 멤버 클래스를 이용해도 좋다.
    - 읽기 좋고, private으로 선언하면 접근 범위도 최소로 관리할 수 있다.
```java
// 코드 25-3 톱레벨 클래스들을 정적 멤버 클래스로 바꿔본 모습 (151-152쪽)  
public class Test {  
    public static void main(String[] args) {  
        System.out.println(Utensil.NAME + Dessert.NAME);  
    }  
  
    private static class Utensil {  
        static final String NAME = "pan";  
    }  
  
    private static class Dessert {  
        static final String NAME = "cake";  
    }  
}
```

## 결론
- **소스 파일 하나에는 반드시 톱레벨 클래스(혹은 톱레벨 인터페이스)를 하나만 담자.**
    - 컴파일러가 한 클래스에 여러 개의 정의를 만들게 하지 말자.
    - 소스 파일의 컴파일 순서에 따라 바이너리 파일이나 프로그램의 동작이 달라지는 일이 없도록 방지하자.
