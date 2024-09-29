
## 요약

### 박싱된 기본 타입
- 기본 타입에 대응하는 참조 타입을 의미한다
- 오토박싱과 오토언박싱이 있지만 기본 타입과 박싱된 기본 타입에는 분명한 차이가 있으니 주의해서 사용해야 한다

### 차이점
- 기본 타입은 값만 가지고 있지만 박싱된 기본 타입은 식별성 속성이 있다.
- 박싱된 기본 타입의 두 인스턴스는 값이 같아도 서로 다르다고 식별된다.
-  기본 타입의 값은 언제나 유효하나 박싱된 기본타입은 null을 가질 수 있다.
- 기본타입이 시간과 메모리에서 효율적이다.


### 
```java
       Comparator<Integer> naturalOrder =
               (i, j) -> (i < j) ? -1 : (i == j ? 0 : 1);


        // 코드 61-2 문제를 수정한 비교자 (359쪽)
        Comparator<Integer> naturalOrder = (iBoxed, jBoxed) -> {
            int i = iBoxed, j = jBoxed; // 오토박싱
            return i < j ? -1 : (i == j ? 0 : 1);
        };
```
- `naturalOrder.compare(new Integer(42), new Integer(42))`를 하게 되면, 1을 출력한다
- `i == j` 에서 두 객체 참조의 식별성을 검사하기 때문에 false 가 되어 1을 반환한다
- 이처럼 박싱된 기본 타입에 == 연산자를 쓰면 오류가 발생
- 기본 타입의 비교자를 원한다면 `Comparator.naturalOrder()` 사용하자
- 직접 해결은 기본 타입의 지역 변수를 두어 저장할 수 있다 


```java
public class Unbelievable {
    static Integer i;

    public static void main(String[] args) {
        if (i == 42)
            System.out.println("믿을 수 없군!");
    }
}
```
- 이 코드는 `NullPointException` 을 던진다 (믿을 수 없군 을 프린트하지는 않는다)
- i 의 초깃값이 null 이기 때문이다
- 기본 타입과 박싱된 기본 타입을 혼용한 연산에서는 박싱된 기본 타입의 박싱이 풀린다 그리고 i는 null 참조이므로
이를 언박싱하면 에러가 발생한다 
- i 를 int 로 선언해야 한다