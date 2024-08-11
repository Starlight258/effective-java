## ✍️ 개념의 배경

톱레벨 클래스 (https://docs.oracle.com/javase/specs/jls/se8/html/jls-8.html)

- A top level class is a class that is not a nested class.
- A nested class is any class whose declaration occurs within the body of another class or interface.
- 톱 레벨 클래스는 중접 클래스가 아닌 클래스이다.
- 중첩 클래스는 다른 클래스나 인터페이스에 선언된 클래스이다.

# 요약

---

- 톱 레벨 클래스가 하나의 소스 파일에 여러개 있으면 문제가 생길 수 있다
- 우리의 소스코드가 다음과 같다고 하자.

```java
public class Main {
    public static void main(String[] args) {
        System.out.println(Utensil.NAME + Dessert.NAME);
    }
}
```

```java
class Utensil {
    static final String NAME = "pan";
}

class Dessert {
    static final String NAME = "cake";
}
```
Utensil.java

```java
class Utensil {
    static final String NAME = "pot";
}

class Dessert {
    static final String NAME = "pie";
}
```
Dessert.java

이때, 소스파일이 컴파일러에 전달되는 순서에 따라 다른 결과가 발생한다.

1. javac Main.java Dessert.java : 컴파일 오류 
2. javac Main.java Utensil.java  : “pancake출력”
3. javac Dessert.java Main.java : “potfie 출력”

### 해결책

- 톱 레벨 클래스들을 여러 소스 파일로 분리한다
- 하나의 파일에 굳이 담고 싶다면 정적 멤버 클래스를 고려하라

```java
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
