## 요약

### 공개된 모든 클래스, 인터페이스, 메서드, 필드 선언에 문서화 주석을 달아야 함
- 직렬화할 수 있는 클래스라면 직렬화 형태에 관하여도 서술 
- 기본 생성자에는 문서화 주석을 달 방법이 없으니 공개 클래스는 절대 기본 생성자를 사용하면 안된다


### 메서드용 문서화 주석에는 해당 메서드와 클라이언트 사이의 규약을 명료하게 기술해야 한다
- 메서드가 무엇을 하는지, how가 아닌 **what**을 기술
- 메서드를 호출하기 위한 전제조건(precondition)을 나열해야 함
    - 일반적으로 전제조건은 `@throw` 태그로 비검사 예외를 선언하여 암시적으로 기술
    - `@param` 태그를 이용해 그 조건에 영향받는 매개변수에 기술
- 메서드가 성공적으로 수행된 후에 만족해야 하는 사후조건(postcondition)도 모두 나열
- 부작용도 문서화해야 함
    
    (부작용이란, 사후조건으로 명확히 나타나지는 않지만 시스템의 상태에 어떠한 변화를 가져오는 것을 뜻함)
    
- 메서드의 계약(contract)을 완벽히 기술하려면, 모든 매개변수에 `@param` 태그를, 반환 타입이 void 가 아니라면 `@return` 태그를, 발생할 가능성이 있는 모든 예외에 `@throw` 태그를 달아야 함
- 다만, @return 태그의 설명이 메서드 설명과 같을 때 코딩 표준에서 허락한다면 @return 태그는 생략해도 좋음)


### javadoc 태그

`@param` : 매개변수 설명 명사구
`@return` : 반환 타입 설명 명사구
`@throw` : if 로 시작해 해당 예외를 던지는 조건 설명

 관례상 `@param` , `@return`, `@throw` 태그의 설명에는 마침표를 붙이지 않는다

 `{@code}`  
- 태그로 감싼 내용을 코드용 폰트로 랜더링
- 주석 내에 HTML 요소나 다른 자바독 태그를 무시한다
- 주석에 여러 줄로 된 코드 예시를 넣으려면 `{@code}` 를 pre 태그로 감싸준다
- @ 기호에는 무조건 탈출문자를 붙여아 하니 주석 안에서 애너테이션을 사용하는 경우 주의 

`@implSpec`
- 해당 메서드와 하위 클래스 사이의 계약을 설명한다
- 하위 클래스들이 그 메서드를 상속하거나 super 키워드를 이용해 호출할 때 그 메서드가 어떻게 동작하는지 명확히 인지하고 사용하도록 도와줌


`{@literal}`
- 주석 내에 HTML 요소나 다른 자바독 태그를 무시한다.
- `{@code}`와 비슷하지만 코드 폰트로 렌더링하지 않는다.


요약 설명
- 각 문서화 주석의 첫 번째 문장은 해당 요소의 요약 설명으로 간주된다
- 요약 설명은 대상의 기능을 고유하게 기술해야 한다 
- 한 클래스 안에서 요약 설명이 똑같은 멤버(혹은 생성자)가 둘 이상이면 안된다 (다중정의 시 주의)
- 요약 설명은 첫 번째 마침표가 나오는 부분까지만 인식한다 (@literal) 의 도움을 받자 
- 자바 10 부터는 @summary 태그를 사용해 요약 설명을 제공할 수 있다
- 매서드와 생성자의 요약 설명은 해당 메서드와 생성자의 동작을 설명하는 주어가 없는 동사구여야 한다
    - ***ArrayList(int initialCapcity)** : Construct an empty list with the specified initial capacity.*
    - ***Collection.size()** : Returns the number of elements in this collection.*
- 클래스, 인터페이스, 필드의 요약 설명은 대상을 설명하는 명사절이어야 한다 
    - ***Instant** : An instantaneous point on the time-line.*
    - ***Math.PI** : The double value that is closer than any other to pi, the ratio of the circumference of a circle to its diameter.*

`{@index}`
- 자바 9부터는 자바독이 생성한 HTML 문서에 검색(색인) 기능이 추가.


### 제네릭
- 제네릭 타입이나 제네릭 메서드를 문서화할 때는 모든 타입 매개변수에 주석을 달아야 한다.

```
/**
 * 키와 값을 매핑하는 객체, 맵은 키를 중복해서 가질 수 없다
 * 즉, 키 하나가 가리킬 수 있는 값은 최대 1개다.
 *
 * @param <K> 이 맵이 관리하는 키의 타입
 * @param <V> 매핑된 값의 타입
 */
public interface Map<K, V> { ... }
```

### 열거 타입
- 열거 타입을 문서화할 때는 상수들에도 주석을 달아야 한다.
- 열거 타입 자체와 그 열거 타입의 public 메서드도 물론이다

```java
/**
 * An instrument section of a symphony orchestra.
 */
public enum OrchestraSection {
    /** Woodwinds, such as flute, clarinet, and oboe. */
    WOODWIND,

    /** Brass instruments, such as french horn and trumpet. */
    BRASS,

    /** Percussion instruments, such as timpani and cymbals. */
    PERCUSSION,

    /** Stringed instruments, such as violin and cello. */
    STRING;
}
```


### 애너테이션 
- 애너테이션 타입을 문서화할 때는 멤버들에도 모두 주석을 달아야 한다
- 에너테이션 타입 자체도 물론이고 필드 설명은 명사구로 한다 
- 타입의 요약 설명은 프로그램 요소에 이 애너테이션을 단다는 것이 어떤 의미인지를 설명하는 동사구로 한다 

```java
/**
 * Indicates that the annotated method is a test method that
 * must throw the designated exception to pass.
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTest {
    /**
     * The exception that the annotated test method must throw
     * in order to pass. (The test is permitted to throw any
     * subtype of the type described by this class object.)
     */
    Class<? extends Throwable> value();
}
```

### 패키지 
- 패키지 문서화 주석은 package-info.java 파일에 작성
- 모듈도 비슷한데, 모듈 관련 설명은 module-info.java 파일에 작성

### 스레드 안전성, 직렬화 가능성
- 스레드 안전 수준을 반드시 API 설명에 포함해야 함
- 직렬화할 수 있는 클래스라면 직렬화 형태도 API 설명에 기술

### 메서드 주석의 상속
- 자바독은 문서화 주석을 상속시킬 수 있다
- 인터페이스, 상위 클래스를 참고해 비어있는 API 요소에 주석을 달아줌(인터페이스를 먼저 찾는다)
- `@{inheritDoc}` 태그를 사용해 상위 타입의 문서화 주석 일부를 상속할 수 있다  

### 주의사항
- 여러 클래스가 상호작용하는 복잡한 API 라면 문서화 주석 외에도 전체 아키텍쳐를 설명해야 하는 경우가 있다
- 이런 경우 관련 클래스나 패키지의 문서화 주석에서 그 문서의 링크를 제공해주면 좋다
- 자바독 문서 검사
    - 자바 명령줄 -Xdoclint
    - IDE 플러그인 , HTML 유효성 검사기 