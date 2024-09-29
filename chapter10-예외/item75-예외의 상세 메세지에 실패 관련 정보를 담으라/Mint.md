# 75. 예외의 상세 메세지에 실패 관련 정보를 담으라
### 예외를 잡지 못해 프로그램이 실패하면 자바 시스템은 그 예외의 스택 추적(stack trace) 정보를 자동으로 출력한다.
- 스택 추적은 예외 객체의 `toString` 메서드를 호출해 얻는 문자열이다.
- 대부분 예외 클래스 이름 뒤에 상세 메세지가 붙는 형태이다.
###  예외의 toString 메서드에 실패 원인에 관한 정보를 가능한 많이 담아 반환하는 것이 중요하다.
- 발생한 예외에 관여된 모든 매개변수와 필드의 값을 실패 메세지에 담아야한다.
    - ex) `IndexOutOfBoundsException`이라면 범위의 최솟값과 최댓값, 범위를 벗어났다는 인덱스의 값을 담아야 한다.
- 장황할 필요는 없다.
    - 소스 코드와 함께 살펴보기 때문이다.
- 보안과 관련한 정보는 주의해서 담아야 한다.
    - 문제를 진단하고 해결하는 과정에서 많은 사람이 볼 수 있으므로 상세 메세지에 비밀번호나 암호 키 같은 정보까지 담아서는 안된다.

### 예외의 상세 메세지와 최종 사용자에게 보여줄 오류 메세지를 혼동해서는 안된다
- 최종 사용자에게는 친절한 안내 메세지를 보여줘야 하는 반면, 예외 메세지는 가독성보다는 담긴 내용이 훨씬 중요하다.
    - 예외 메세지의 주 소비층은 문제를 분석하는 프로그래머와 SRE 엔지니어이기 때문이다.
- 예외 생성자에 필요한 정보를 받아 생성하는 방법도 있다.
- 예외는 실패와 관련한 정보를 얻을 수 있는 `접근자 메서드`를 적절히 제공하는 것이 좋다.
    - 검사 예외에서 더 빛을 발하지만, 비검사 예외라도 제공하는 것을 추천한다.
```java
/**
 * 향상된 IndexOutOfBoundsException 클래스
 * 인덱스 범위 초과 상황을 더 자세히 설명하고 관련 정보에 접근할 수 있는 메서드를 제공합니다.
 */
public class IndexOutOfBoundsException extends RuntimeException {
    private final int lowerBound;
    private final int upperBound;
    private final int index;

    /**
     * IndexOutOfBoundsException을 생성합니다.
     *
     * @param lowerBound 인덱스의 최솟값
     * @param upperBound 인덱스의 최댓값 + 1
     * @param index      인덱스의 실젯값
     */
    public IndexOutOfBoundsException(int lowerBound, int upperBound, int index) {
        // 실패를 포착하는 상세 메시지를 생성합니다.
        super(String.format(
                "인덱스 범위 초과: 최솟값: %d, 최댓값: %d, 실제 인덱스: %d",
                lowerBound, upperBound - 1, index));

        // 프로그램에서 이용할 수 있도록 실패 정보를 저장해둡니다.
        this.lowerBound = lowerBound;
        this.upperBound = upperBound;
        this.index = index;
    }

    /**
     * 인덱스의 최솟값을 반환합니다.
     *
     * @return 인덱스의 최솟값
     */
    public int getLowerBound() {
        return lowerBound;
    }

    /**
     * 인덱스의 최댓값을 반환합니다.
     *
     * @return 인덱스의 최댓값
     */
    public int getUpperBound() {
        return upperBound - 1;
    }

    /**
     * 실제 사용된 인덱스 값을 반환합니다.
     *
     * @return 실제 사용된 인덱스 값
     */
    public int getIndex() {
        return index;
    }

    /**
     * 인덱스가 유효한 범위를 벗어난 정도를 반환합니다.
     *
     * @return 유효한 범위를 벗어난 정도. 음수면 최솟값보다 작고, 양수면 최댓값보다 큽니다.
     */
    public int getOffsetFromRange() {
        if (index < lowerBound) {
            return index - lowerBound;
        }
        if (index >= upperBound) {
            return index - (upperBound - 1);
        }
        return 0; // 이 경우는 발생하지 않아야 합니다.
    }
}
```
