# 56. 공개된 API 요소에는 항상 문서화 주석을 작성하라
## JavaDoc
- 소스코드 파일에서 `문서화 주석`을 추려 **API 문서로 형변환**해준다.

### API를 올바르게 문서화하려면 공개된 모든 클래스, 인터페이스, 메서드 필드 선언에 문서화 주석을 달아야한다.
- 기본 생성자에는 문서화 주석을 달 방법이 없으니 공개 클래스는 절대 기본 생성자를 사용하면 안된다.
- 유지보수까지 고려한다면 공개되지 않은 클래스, 인터페이스, 메서드 필드에도 문서화 주석을 달아야할 것이다.

### 메서드용 문서화 주석에는 해당 메서드와 클라이언트 사이의 규약을 명확하게 기술해야한다.
```java
/**  
 * 이 리스트에서 지정한 위치의 원소를 반환한다.  
 * * <p>이 메서드는 상수 시간에 수행됨을 보장하지 <i>않는다</i>. 구현에 따라  
 * 원소의 위치에 비례해 시간이 걸릴 수도 있다.  
 * * @param  index 반환할 원소의 인덱스; 0 이상이고 리스트 크기보다 작아야 한다.  
 * @return 이 리스트에서 지정한 위치의 원소  
 * @throws IndexOutOfBoundsException index가 범위를 벗어나면,  
 * 즉, ({@code index < 0 || index >= this.size()})이면 발생한다.  
 */
 E get(int index) {  
    return null;  
}
```
- `how`가 아닌 `what`을 기술해야한다.
    - 메서드가 어떻게 동작하는지가 아니라 무엇을 하는지를 기술한다.
- 전제조건과 사후조건을 기술한다.
    - 전제 조건 : 클라이언트가 해당 메서드를 호출하기 위한 조건
        - `@throws` 태그로 비검사 예외를 선언하여 암시적으로 기술한다.
    - 사후 조건 : 메서드가 성공적으로 수행한 후에 만족해야하는 조건
- 부작용을 기술한다.
    - 부작용: 사후 조건으로 명확하게 나타나지는 않지만 시스템의 상태에 어떠한 변화를 가져오는 것을 뜻한다.

#### 태그
- 매개변수 : `@param`
- 반환타입이 void가 아니라면 `@return`
- 모든 예외에 `@throws`
> @param, @return, @throws 태그의 설명에는 마침표를 붙이지 않는다.

- `this` : 호출된 메서드가 자리하는 객체
- `@implSpec` : 자기사용 패턴 설명
    - 프로그래머에게 그 **메서드를 올바르게 재정의하는 방법**을 알린다.
    - **해당 메서드와 하위 클래스 사이의 계약을 설명**하여, 하위 클래스들이 그 메서드를 상속하거나 `super` 키워드를 이용해 호출할 때 어떻게 동작하는지 알린다.
```java
// 자기사용 패턴 등 내부 구현 방식을 명확히 드러내기 위해 @implSpec 사용 (335쪽)
/**  
 * 이 컬렉션이 비었다면 true를 반환한다.  
 * * @implSpec 이 구현은 {@code this.size() == 0}의 결과를 반환한다.  
 * * @return 이 컬렉션이 비었다면 true, 그렇지 않으면 false  
 */
 public boolean isEmpty() {  
    return false;  
}
```

- `{@literal}` : HTML 메타 문자 포함시키기
    - HTML 마크업이나 자바독 태그를 무시하게 해준다.
```java
// 문서화 주석에 HTML이나 자바독 메타문자를 포함시키기 위해 @literal 태그 사용 (336쪽)
/**  
 * {@literal |r| < 1}이면 기하 수열이 수렴한다.  
 */public void fragment() {  
}
```

- `@Index` : 중요한 용어를 색인할 수 있다.
```java
// 자바독 문서에 색인 추가하기 - 자바 9부터 지원 (338쪽)
/**  
 * 이 메서드는 {@index IEEE 754} 표준을 준수한다.  
 */
public void fragment2() {  
}
```

- `@inheritDoc` :  **상위 타입의 문서화 주석 일부를 상속**할 수 있다.

### 각 문서화 주석의 첫번째 문장은 해당 요소의 요약 설명으로 간주된다.
- 요약 설명은 반드시 대상의 기능을 고유하게 기술해야한다.
    - 한 클래스(혹은 인터페이스) 안에서 요약 설명이 똑같은 멤버(또는 생성자)가 둘 이상이면 안된다.
    - 다중정의된 메서드가 있다면 특히 더 조심하자
- `마침표(.)`에 주의해야한다.
    - 첫번째 마침표가 나오는 곳까지만 요약 설명이 된다.
    - 의도치 않은 마침표를 포함한다면, `@literal`로 감싸주는 것이 좋다.
```java
// 문서화 주석 첫 '문장'에 마침표가 있을 때 요약 설명 처리 (337쪽)
/**  
 * 머스타드 대령이나 {@literal Mrs. 피콕} 같은 용의자.  
 */
public enum Suspect {  
    MISS_SCARLETT, PROFESSOR_PLUM, MRS_PEACOCK, MR_GREEN, COLONEL_MUSTARD, MRS_WHITE  
}
```
- `@summary`라는 요약 설명 전용 태그를 사용하면 더 깔끔하다.
```java
/** 
* {@summary 보드게임 Clue의 용의자들을 나타내는 열거형,  머스타드 대령이나 Mrs. 피콕 같은 용의자들을 포함}
*/
public enum Suspect {  
    MISS_SCARLETT, PROFESSOR_PLUM, MRS_PEACOCK, MR_GREEN, COLONEL_MUSTARD, MRS_WHITE  
}
```

### 메서드와 생성자의 요약 설명은 해당 메서드와 생성자의 동작을 설명하는 `주어가 없는 동사구`여야한다.
### 클래스, 인터페이스, 필드의 요약 설명은 대상을 설명하는 `명사절`이어야한다.
```java
/**
 * 은행 계좌를 나타내는 클래스
 */
public class BankAccount {
    
    /**
     * 이 계좌의 현재 잔액
     */
    private double balance;

    /**
     * 지정된 초기 잔액으로 새 계좌를 생성한다.
     * 
     * @param initialBalance 계좌의 초기 잔액
     * @throws IllegalArgumentException 초기 잔액이 음수일 경우
     */
    public BankAccount(double initialBalance) {
        if (initialBalance < 0) {
            throw new IllegalArgumentException("초기 잔액은 0 이상이어야 합니다.");
        }
        this.balance = initialBalance;
    }

    /**
     * 이 계좌에 지정된 금액을 입금한다.
     * 
     * @param amount 입금할 금액
     * @throws IllegalArgumentException 입금액이 0 이하일 경우
     */
    public void deposit(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("입금액은 0보다 커야 합니다.");
        }
        balance += amount;
    }

    /**
     * 이 계좌에서 지정된 금액을 출금한다.
     * 
     * @param amount 출금할 금액
     * @throws IllegalArgumentException 출금액이 0 이하이거나 잔액을 초과할 경우
     */
    public void withdraw(double amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException("출금액은 0보다 커야 합니다.");
        }
        if (amount > balance) {
            throw new IllegalArgumentException("잔액이 부족합니다.");
        }
        balance -= amount;
    }

    /**
     * 이 계좌의 현재 잔액을 반환한다.
     * 
     * @return 현재 잔액
     */
    public double getBalance() {
        return balance;
    }
}
```

### 제네릭 타입이나 제네릭 메서드를 문서화할 때 모든 타입 매개변수에 주석을 달아야 한다.
```java
/**
 * 키-값 쌍을 저장하는 간단한 제네릭 맵 구현.
 *
 * @param <K> 이 맵에서 키로 사용될 타입
 * @param <V> 이 맵에서 값으로 사용될 타입
 */
public class SimpleMap<K, V> {
    
    /**
     * 지정된 키와 값을 이 맵에 추가한다.
     *
     * @param key 맵에 추가할 키
     * @param value 지정된 키에 연결할 값
     * @throws NullPointerException key가 null인 경우
     */
    public void put(K key, V value) {
    }
}
```

### 열거 타입을 문서화할 때는 상수들에도 주석을 달아야한다.
```java
/**  
 * 심포니 오케스트라의 악기 세션.  
 */public enum OrchestraSection {  
    /** 플루트, 클라리넷, 오보 같은 목관악기. */  
    WOODWIND,  
  
    /** 프렌치 호른, 트럼펫 같은 금관악기. */  
    BRASS,  
  
    /** 탐파니, 심벌즈 같은 타악기. */  
    PERCUSSION,  
  
    /** 바이올린, 첼로 같은 현악기. */  
    STRING;  
}
```

### 애너테이션 타입을 문서화할때는 멤버들에도 모두 주석을 달아야한다.
```java
// 애너테이션 타입 문서화 (340쪽)
/**  
 * 이 애너테이션이 달린 메서드는 명시한 예외를 던져야만 성공하는  
 * 테스트 메서드임을 나타낸다.  
 */
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD)  
public @interface ExceptionTest {  
    /**  
     * 이 애너테이션을 단 테스트 메서드가 성공하려면 던져야 하는 예외.  
     * (이 클래스의 하위 타입 예외는 모두 허용된다.)  
     */    
     Class<? extends Throwable> value();  
}
```
- 필드 설명은 명사구로 한다.

> 패키지를 설명하는 문서화 주석은 package-info.java 파일에 작성한다.
> 전체 아키텍처를 설명하는 별도의 설명이 필요할 때도 있다.

### 스레드 안전성과 직렬화 가능성도 API 문서화 설명에 작성해야한다.
- 클래스 혹은 정적 메서드가 스레드 안전하든 그렇지 않든, 스레드 안전 수준을 반드시 API 설명에 포함해야한다.
- 직렬화 형태도 기술해야한다.

### 자바독 문서화가 잘 되었는지 확인하자
- checkstyle같은 플러그인을 사용해 검사할 수 있다.
- html 유효성 검사기로 돌리면 문서화 주석의 오류를 줄일 수 있다.

### 자바독 유틸리티가 생성한 웹페이지를 읽어보자.
- 다른 사람이 사용할 API라면 반드시 모든 API 요소를 검토하라

# 결론
- `문서화 주석`은 API 문서화하는 가장 훌륭하고 효과적인 방법이다.
- `공개 API`라면 빠짐없이 설명을 달아야 한다.
- `표준 규약`을 일관되게 지키자.
- 문서화 주석에 임의의 `HTML 태그`를 사용할 수 있음을 기억하라.
    - 단 `HTML 메타문자`는 특별하게 취급해야한다.

