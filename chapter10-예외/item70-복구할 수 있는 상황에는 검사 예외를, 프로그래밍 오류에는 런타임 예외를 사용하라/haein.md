## 검사 예외와 비검사 예외

![](https://lh5.googleusercontent.com/WqqNoyFEkZXfmZBBQjgIutY72_BUV6_By_BAe7Ih9u36HfelS3nTWQEYtdRUkQS32Tuhg9P9CUXo-jgvOpkO84vLm2viI4Od0BNustwONdMm7DKZnKC6kyVHyRJbsESLIPV4uBU)

예외와 에러는 `Throwable` 을 구현한 클래스

1. 검사 예외(checked exception) : 컴파일 타임에 발생하는 예외
1. 비검사 예외(unchecked exception) : 검사 예외가 아닌 예외
    - 런타임 예외  
    - 에러 : 코드에 의해서 수습될 수 없는 심각한 오류

## 요약

언제 어떤 예외를 사용해야 하는 지 판단하는 기준 

### 호출하는 쪽에서 복구하리라 여겨지는 상황이라면 검사 예외를 사용하라 
- 호출자가 예외처리하도록 강제함 (try-catch 나 예외 전파)

### 프로그래밍 오류를 나타낼 때는 런타임 예외를 사용하자
- 런타임 예외의  대부분은 전제조건을 만족하지 못했을 때 발생한다(API 명세에 나타난 제약을 못 지킴)
- 복구할 수 있는 상황인지, 프로그래밍 오류인 지 명확하게 확신하기 어렵다면 비검사 예외를 선택하는 편이 낫다 

### 비검사 throwable 은 모두 `RuntimeException` 의 하위 클래스여야한다
- 에러는 보통 JVM이 자원 부족, 불변식 깨짐 등 더 이상 수행을 핧 수 없는 상황을 나타낼 떄 사용한다
- `Error` 클래스를 상속해 하위 클래스를 만드는 일은 자제하자
- `Error` 는 상속하지 말아야 할 뿐 아니라, throw 문으로 직접 던지는 일도 없어야 한다 (`AssertionError` 예외)
- `Exception`, `RuntimeException`, `Error` 를 상속하지 않는 `throwable` 은 절대로 사용하지 말자 

