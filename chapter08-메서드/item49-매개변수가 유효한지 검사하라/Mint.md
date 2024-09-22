# 49. 매개변수가 유효한지 검사하라
## 메서드 몸체가 실행되기 전에 매개변수를 확인하자
- 잘못된 값이 넘어왔을 때 즉각적이고 깔끔하게 예외를 던질 수 있다.

### 매개변수 검사를 하지 않을 경우
- 메서드가 수행되는 중간에 `모호한 예외`를 던지며 실패할 수 있다.
- **잘못된 결과를 반환할 수 있다.**
    - 실패 원자성을 어기는 결과(객체가 불완전하거나 일관성 없는 상태)를 낳을 수 있다.

### public과 protected 메서드는 매개변수 값이 잘못되었을 때 던지는 예외를 문서화해야한다.
```java
/**
 * 이 BigInteger를 주어진 모듈러로 나눈 나머지를 계산합니다.
 * 
 * <p>이 메서드는 현재 BigInteger 값을 변경하지 않고 새로운 BigInteger 객체를 반환합니다.</p>
 *
 * @param m 모듈러로 사용할 BigInteger. 반드시 양수여야 합니다.
 * @return 이 BigInteger를 m으로 나눈 나머지를 나타내는 BigInteger
 * @throws ArithmeticException m이 0이거나 음수일 경우
 * @throws NullPointerException m이 null일 경우
 */
public BigInteger mod(BigInteger m) {
	if (m == null) {
		throw new NullPointerException("The modulus must not be null");
	}
	if (m.signum() <= 0) {
		throw new ArithmeticException("The modulus must be positive");
	}
	return this.remainder(m);
}
```

#### requireNonNull
- null 검사를 수동으로 하지 않아도 된다.
- 예외 메세지 지정도 가능하다.
- 값을 사용하는 동시에 null 검사를 수행할 수 있다.
```java
this.strategy = Objects.requireNonNull(strategy, "전략");
```

#### 범위 검사 기능
- java 9에서는 Objects에 범위 검사 기능도 더해졌다.
- `checkFromIndexSize`, `checkFromToIndex`, `checkIndex`
    - `Objects.checkFromIndexSize(int fromIndex, int size, int length)`: 시작 인덱스(`fromIndex`)와 크기(`size`)가 주어진 길이(`length`) 내에서 유효한지 검사
    - `Objects.checkFromToIndex(int fromIndex, int toIndex, int length)` : 시작 인덱스(`fromIndex`)와 끝 인덱스(`toIndex`)가 주어진 길이(`length`) 내에서 유효한지 검사
    - `Objects.checkIndex(int index, int length)`: 단일 인덱스(`index`)가 주어진 길이(`length`) 내에서 유효한지 검사

### public이 아닌 메서드라면 단언문(assert)를 사용해 매개변수 유효성을 검증할 수 있다.
```java
private static void sort(long a[], int offset, int length){
	assert a != null;
	assert offset >= 0 && offset <= a.length;
	assert length >= 0 && length <= a.length - offset;
}
```
- 실패하면 AssertionError를 던진다.
- 런타임에 아무런 효과도, 성능 저하도 없다.
    - Assert를 비활성화된 상태에서 실행되었을 경우
- Assert는 주로 개발 및 테스트 단계에서 사용된다.
    - 코드의 정확성을 검증할 수 있다.
> 프로덕션 환경에서는 일반적으로 assert를 무시한다.

### 나중에 쓰기 위해  저장하는 매개변수는 검사를 수행하자.
- 사용시 에러가 발생하면 디버깅이 힘들다.
- **생성자 매개변수의 유효성 검사는 클래스 불변식을 어기는 객체가 만들어지지 않게 하는데 꼭 필요하다.**
    - 유효성 검사 비용이 너무 높거나 계산과정에서 암묵적으로 검사가 수행된다면 검사를 꼭 하지 않아도 된다.
> 암묵적 유효성 검사에 너무 의존하면 실패 원자성을 해칠 수 있으니 주의하자.

### 유효성 검사에서 잘못된 예외를 던진다면 `예외 번역`을 해주어야한다.
- 예외 번역 : 하위 계층에서 발생한 예외를 상위 계층에 더 적절한 예외로 변환하여 던지는 것


# 결론
- 메서드나 생성자를 작성할 경우 그 매개변수들에 **어떤 제약이 있을지** 생각해야 한다.
    - **그 제약들을 문서화하고 코드 시작 부분에서 명시적으로 검사해야한다.**


