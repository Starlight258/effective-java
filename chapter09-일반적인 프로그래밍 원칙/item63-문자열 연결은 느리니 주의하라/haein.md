## 요약
### 문자열 연결 연산자는 느리다

- 문자열 객체는 불변이므로 복사가 불가피하
- N개의 문자열을 연결하는 시간은 N^2 에 비례함

### StringBuilder(StringBuffer)  사용하자

- StringBuilder 의 `append` 사용
- StringBuffer 는 StringBuilder 와 유사하지만 멀티스레드 환경에서도 안전하게 동작함
- 주의점  : `equals` 를 구현하지 않았음, `toString` 사용할 것