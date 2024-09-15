# 63. 문자열 연결은 느리니 주의하라
### 문자열 연결 연산자 (+)
```java
public String statement() {
    String result = "";
    for (String s : strings) {
        result += s;  // 매우 비효율적인 방식
    }
    return result;
}
```
- 여러 문자열을 하나로 합쳐주는 편리한 수단
- 두 문자열을 연결할 경우 양쪽의 내용을 모두 복사해야하므로 n개의 문자열을 이을 경우 n^2
    - 성능 저하가 발생한다.

## 성능을 포기하고 싶지 않다면 `String` 대신 `StringBuilder` 를 사용하자.
```java
public String statement2() {
    StringBuilder result = new StringBuilder();
    for (String s : strings) {
        result.append(s);
    }
    return result.toString();
}
```

# 결론
- 성능에 신경 써야 한다면, 많은 문자열을 연결할 때는 `문자열 연결 연산자 (+)`를 피하자
    - `대신 StringBuilder의 append 메서드를 사용하라`

