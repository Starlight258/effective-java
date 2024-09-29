# 35. ordinal 메서드 대신 인스턴스 필드를 사용하라.
## `ordinal()` - 비추천
```java
// 인스턴스 필드에 정수 데이터를 저장하는 열거 타입 (222쪽)  
public enum Ensemble {  
    SOLO, DUET, TRIO, QUARTET, QUINTET,  
    SEXTET, SEPTE, OCTET, DOUBLE_QUARTET;  
  
    public int numberOfMusicians() { return ordinaal() + 1; }  
}
```
- 대부분의 열거 타입 상수는 하나의 정수값에 대응된다.
- 모든 열거 타입은 해당 상수가 그 **열거 타입에서 몇번째 위치인지를 반환**하는 `ordinal` 메서드를 제공한다.

### ordinal 단점
- **동작은 하지만 유지보수하기가 어렵다.**
    - 상수 선언 순서를 바꾸면 오동작한다.
    - 이미 사용중인 정수와 값이 같은 상수는 추가할 수 없다.
    - 값을 중간에 비워두려면 쓰이지 않는 더미 상수를 추가해야한다.

## 열거 타입 상수에 연결된 값은 `ordinal()`로 얻지 말고, **인스턴스 필드에 저장**하자.  🌟
```java
// 인스턴스 필드에 정수 데이터를 저장하는 열거 타입 (222쪽)  
public enum Ensemble {  
    SOLO(1), DUET(2), TRIO(3), QUARTET(4), QUINTET(5),  
    SEXTET(6), SEPTET(7), OCTET(8), DOUBLE_QUARTET(8),  
    NONET(9), DECTET(10), TRIPLE_QUARTET(12);  
  
    private final int numberOfMusicians;  
    Ensemble(int size) { this.numberOfMusicians = size; }  
    public int numberOfMusicians() { return numberOfMusicians; }  
}
```
- ordinal의 단점이 해결된다.

### ordinal 사용 시점
- 대부분 프로그래머는 이 메서드를 쓸 일이 없다.
- `EnumSet` 이나 `EnumMap` 같이 **열거 타입 기반의 범용 자료구조에 쓸 목적으로 설계**되었다.

## 결론
- `ordinal()`은 열거 타입 기반의 범용 자료구조에서 쓰는 것이 아니라면, 사용하지 말자.

