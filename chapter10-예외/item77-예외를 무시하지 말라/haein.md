## 요약


### API 설계자의 예외 명시를 무시하지 말고 적절한 조치를 취해야 한다

```java
    try {
    ...
    } catch(someException E) {
    }
```
- 예외를 무시하기는 아주 쉽다 `catch` 블록에서 아무 일도 하지 않으면 끝이다


### 예외를 무시해야 하는 경우

- `FileInputStream`을 닫을 때는 입력 전용 스트림이므로 파일의 상태를 변경하지 않았으니 복구 할 일이 없으며 필요한 정보는 이미 다 읽었다는 뜻이니 남은 작업을 중단할 유도 없다  
- 예외를 무시하기로 했다면 catch 블록 안에 그렇게 결정한 이유를 주석으로 남기고 예외 변수의 이름도 ignored로 바꿔놓도록 하자

```java
Future<Integer> f = exec.submit(planarMap::chromaticNumber);
int numColors = 4; // 기본값, 어떤 지도라도 이 값이면 충분하다.
try{
    numColors = f.get(1L, TimeUnit.SECONDS);
}catch(TimeoutException | ExecutionException ignored){
    //기본값을 사용한다(색상 수를 최소화하면 좋지만, 필수는 아니다).
}
```

