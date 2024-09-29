# 77. 예외를 무시하지 말라
## 예외 무시하기
- 해당 메서드 호출을 `try 문`으로 감싼 후 `catch 블록`에서 아무 일도 하지 않으면 끝이다.
- 예외는 문제 상황에 잘 대처하기 위해 존재하는데, `catch 블록`을 비워두면 예외가 존재할 이유가 없어진다.
    - 빈 catch 블록으로 못 본 척 지나치면 그 프로그램은 오류를 내재한 채 동작하게 된다.
    - 그러다 어느 순간 문제의 원인과 아무 상관없는 곳에서 갑자기 죽어버릴 수 있다.
```java
try {

} catch (SomeException e){

}
```
### - 예외를 무시하지 않고 바깥으로 전파되게만 놔둬도 최소한 디버깅 정보를 남긴 채 프로그램이 신속히 중단되게 할 수 있다.
```java
try {
    // 코드
} catch (SomeException e) {
    logger.error("예외 발생", e);
    throw e; // 또는 새로운 예외로 감싸서 던질 수도 있음
}
```

### 예외를 무시해야할 경우
- ex)`FileInputStream`을 닫을 때 발생하는 예외
    - 입력 전용 스트림이므로 파일의 상태를 변경하지 않았으니 복구할 것이 없으며, 필요한 정보는 이미 다 읽었으므로 남은 작업을 중단할 이유도 없다.
- 예외를 무시하기로 했다면 catch 블록 안에 **그렇게 결정한 이유를 주석**으로 남기고 예외 변수의 이름도 `ignored`로 바꿔두자.
```java
Future<Integer> f = exec.submit(planarMap::chromaticNumber);
int numColors = 4;
try {
	numColors = f.get(1L, TimeUnit.SECONDS);
} catch (TimeoutException | ExecutionException ignored){
	// 기본값을 사용한다.
}
```
