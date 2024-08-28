# 요약

---

```java
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
        System.out.println(s.size());
    }
}
```
- 이 코드에서 기대하는 반환값은 26 이지만, 실제론 260이 출력됨
- equals 를 재정의할 때 Object가 아닌 Bigram 을 인자로 받아 오버라이딩이 아닌 오버로딩이 되어버려 
의도한 equals 를 호출하지 않고 10개 객체가 모두 다른 객체로 받아들여짐
- @Override 를 사용하면 컴파일 단에서 이런 오류를 잡을 수 있음
- 구체 클래스에서 추상 메서드를 재정의하는 경우엔 컴파일러가  오류를 잡아주므로 굳이 달지 않아도 됨(달아도 상관 없음)
- 그 외에는 상위 클래스의 메서드를 재정의하는 경우에는 항상 애너테이션을 달자(IDE의 도움도 받을 수 있음)