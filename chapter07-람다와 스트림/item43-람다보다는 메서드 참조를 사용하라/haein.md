## 요약

`메서드 참조는 함수 객체를 람다보다도 더 간결하게 만들 수 있다`
- 참조하는 메서드 이름을 통해 기능을 잘 드러내는 이름을 지어줄 수 있음
- 문서화도 가능 
- 하지만 어떤 경우에는 람다가 더 간결할 수 있음(메서드와 람다가 같은 클래스인 경우)

### 메서드 참조의 유형

| 메서드 참조 유형 | 예시 | 같은 기능을 하는 람다 |
|------------------|------|------------------------|
| 정적 | Integer::parseInt | str -> Integer.parseInt(str) |
| 한정적 인스턴스 | Instant.now()::isAfter | t -> Instant.now().isAfter(t) |
| 비한정적 인스턴스 | String::toLowerCase | str -> str.toLowerCase() |
| 클래스 생성자 | TreeMap<K,V>::new | () -> new TreeMap<K,V>() |
| 배열 생성자 | int[]::new | len -> new int[len] |


- **한정적 인스턴스 메서드 참조:** 수신 객체(참조 대상 인스턴스)를 특정하는 참조
    - 정적 참조와 마찬가지로, 함수 객체가 받는 인수와 참조되는 메서드가 받는 인수가 동일
    - 수신 객체의 메서드를 사용할 때 사용됨
- **비한정적 인스턴스 메서드 참조:** 수신 객체를 특정하지 않는 참조
    - 함수 객체를 적용하는 시점에 수신 객체를 알려줌
        - 메서드를 호출할 때 객체를 명시적으로 전달하지 않고, 해당 메서드가 속한 객체를 자동으로 참조하는 기능
        - 이를 위해 수신 객체 전달용 매개변수가 매개변수 목록의 첫 번째로 추가되며, 이후에 참조되는 메서드 선언에 정의된 매개변수들이 추가됨
    - 주로 스트림 파이프라인에서 매핑과 필터 함수에 사용됨
    
- **생성자 참조는 팩터리 객체로 사용**됨


### 람다가 안되는데 메서드 참조가 가능한 예시

```java
interface G1{
    <E extends Exception> Object m() throws E;
}

interface G2{
    <E extends Exception> String m() throws Exception;
}

interface G extends G1, G2{}
```

G를 함수 타입으로 표현하면 다음과 같다

```java
<F extends Exception> () -> String throws F
```