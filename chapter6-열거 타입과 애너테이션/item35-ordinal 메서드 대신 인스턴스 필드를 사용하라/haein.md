# 요약
---

## Enum.ordinal()

`Enum.ordinal()` 메서드는 열거 타입 상수가 정의된 순서를 반환한다.

```java
public enum Ensemble {
    SOLO, DUET, TRIO, QUARTET, QUINTET, SEXTET, SEPTET, OCTET;

    public int numberOfMusicians() { return ordinal() + 1; }
}
```


- 상수 선언 순서를 바꾸면 이상하게 동작
- 사용 중인 정수와 값이 같은 상수를 추가할 수 없음
- 값을 비워둘 수 없음 (더미값을 사용해야 함)

대부분 프로그래머는 이 메서드를 쓸 일이 없다. 이 메서드는 EnumSet과 EnumMap 같이 열거 타입 기반의 범용 자료구조에 쓸 목적으로 설계되었다 (Enum의 API 문서)

열거 타입 상수와 연결된 정보는 인스턴스 필드에 저장

```java
public enum Ensemble {
    SOLO(1), DUET(2), TRIO(3), QUARTET(4), QUINTET(5),
    SEXTET(6), SEPTET(7), OCTET(8), DOUBLE_QUARTET(8),
    NONET(9), DECTET(10), TRIPLE_QUARTET(12);

    private final int numberOfMusicians;
    Ensemble(int size) { this.numberOfMusicians = size; }
    public int numberOfMusicians() { return numberOfMusicians; }
}
```