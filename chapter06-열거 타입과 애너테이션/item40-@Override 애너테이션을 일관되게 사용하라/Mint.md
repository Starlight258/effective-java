# 40. @Override 애너테이션을 일관되게 사용하라

## 상위 클래스의 메서드를 재정의하려는 모든 메서드에 `@Override` 애너테이션을 달자
### @Override
- 메서드 선언에 사용한다.
- 상위 타입의 메서드를 재정의했음을 뜻한다.

#### 버그를 찾아보자
```java
// 코드 40-1 영어 알파벳 2개로 구성된 문자열(바이그램)을 표현하는 클래스 - 버그를 찾아보자. (246쪽)  
public class Bigram {  
    private final char first;  
    private final char second;  
  
    public Bigram(char first, char second) {  
        this.first  = first;  
        this.second = second;  
    }  
  
    public boolean equals(Bigram b) {  
        return b.first == first && b.second == second;  
    }  
  
    public int hashCode() {  
        return 31 * first + second;  
    }  
  
    public static void main(String[] args) {  
        Set<Bigram> s = new HashSet<>();  
        for (int i = 0; i < 10; i++)  
            for (char ch = 'a'; ch <= 'z'; ch++)  
                s.add(new Bigram(ch, ch));  
        System.out.println(s.size()); // 260  
    }  
}
```
- 버그: equals()를 재정의(overriding)한 것이 아닌, 다중정의(overloading)했다.
    - equals()의 매개변수는 Object 타입이어야한다.
- **`@Override` 를 사용하면 컴파일 오류가 발생하며 잘못된 부분을 명확하게 알려준다.**

#### @Override를 사용하자.
```java
// 버그를 고친 바이그램 클래스 (247쪽)  
public class Bigram2 {  
    private final char first;  
    private final char second;  
  
    public Bigram2(char first, char second) {  
        this.first  = first;  
        this.second = second;  
    }  
  
    @Override public boolean equals(Object o) {  
        if (!(o instanceof Bigram2))  
            return false;  
        Bigram2 b = (Bigram2) o;  
        return b.first == first && b.second == second;  
    }  
  
    public int hashCode() {  
        return 31 * first + second;  
    }  
  
    public static void main(String[] args) {  
        Set<Bigram2> s = new HashSet<>();  
        for (int i = 0; i < 10; i++)  
            for (char ch = 'a'; ch <= 'z'; ch++)  
                s.add(new Bigram2(ch, ch));  
        System.out.println(s.size());  
    }  
}
```

### 구체 클래스에서 상위 클래스의 추상 메서드를 구현할 때는 굳이 `@Override`를 달지 않아도 된다.
- 구체 클래스인데 추상 메서드를 모두 구현하지 않으면 컴파일러가 그 사실을 알려주기 때문이다.

### 인터페이스를 재정의할때도 @Override를 사용하자
- 인터페이스가 디폴트 메서드를 지원하기 시작하면서 @Override를 통해 해당 메서드의 시그니처가 정확한지 확신할 수 있다.


## 결론
- 상위 클래스의 메서드를 재정의하려는 모든 메서드에 `@Override` 애너테이션을 달자.
    - 실수를 했다면, 컴파일러가 바로 알려줄 것이다.
- 구체 클래스에서 상위 클래스의 추상 메서드를 구현할 때는 굳이 `@Override`를 달지 않아도 된다.
