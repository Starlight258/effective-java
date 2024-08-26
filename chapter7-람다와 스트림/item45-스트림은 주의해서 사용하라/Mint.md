# 45. 스트림은 주의해서 사용하라
## 스트림 API
- 다량의 데이터 처리 작업을 지원하기 위해 java 8에 추가됨
- 1. `스트림` : 데이터 원소의 유한 혹은 무한 시퀀스
- 2. `스트림 파이프라인` : 이 원소들로 수행하는 **연산 단계** 표현
    - 스트림의 원소들은 `컬렉션`, `배열`, `파일`, `패턴 매처`, `난수 생성기` 등이 있다.
    - 스트림 안의 데이터 원소들은 `객체 참조`나 `기본 타입`(`int`, `long`, `double`) 값이다.

### 스트림 파이프라인
```java
List<String> result = words.stream()    // 데이터 소스
.filter(w -> w.length() > 5)        // 중간 연산
.map(String::toUpperCase)           // 중간 연산
.collect(Collectors.toList());      // 종단 연산
```
- `소스 스트림`에서 시작해 하나 이상의 `중간 연산`을 수행하며 `종단 연산`으로 끝난다.
    - 각 `중간 연산`은 **스트림을 변환**한다.
        - 함수를 각 원소에 적용하거나, 원소를 걸러낸다.
        - 연산 후 원소 타입이 달라질 수 있다.
    - `종단 연산`은 마지막 중간 연산이 내놓은 스트림에 **최후의 연산**을 가한다.
        - 원소를 `정렬`해 컬렉션에 담거나, 특정 원소 하나를 `선택`하거나, 모든 원소를 `출력`한다.

#### 스트림 파이프라인은 **지연 평가**(lazy evaluation)된다.
- 평가는 `종단 연산`이 호출될 때 이뤄진다.
- `종단 연산`에 쓰이지 않는 데이터 원소는 계산에 쓰이지 않는다.
    - `지연 평가`를 통해 **무한 스트림**을 다룰 수 있다.
```java
public class InfiniteStreamExample {
    public static void main(String[] args) {
        // 무한 스트림 생성
        Stream<Integer> infiniteStream = Stream.iterate(1, i -> i + 1);

        // 스트림 처리
        infiniteStream
            .filter(n -> n % 2 == 0)  // 짝수만 필터링
            .map(n -> n * n)          // 제곱
            .dropWhile(n -> n <= 100) // 100 이하의 값은 건너뛰기
            .limit(10)                // 처음 10개만 선택
            .forEach(System.out::println); // 종단 연산: 출력
    }
}
```
>무한한 크기의 스트림을 생성하지만, 종단 연산 (`forEach`)이 호출될 때까지 실제 계산은 이루어지지 않는다.

- 종단 연산이 없는 스트림 파이프라인은 아무 일도 하지 않는 명령어인 `no-op`과 같다.

#### 스트림 파이프라인은 순차적으로 실행된다.
- 파이프라인을 병렬(`parallel`)로 실행하려면 파이프라인을 구성하는 스트림 중 하나에서 `parallel` 메서드를 호출하면 된다.
> 효과를 볼 수 있는 상황이 많지 않다.

### 스트림 API는 메서드 연쇄를 지원하는 `플루언트 API`이다.
- 파이프라인 하나를 구성하는 **모든 호출을 연결하여 단 하나의 표현식**으로 완성할 수 있다.
- **파이프라인 여러개를 연결해 하나의 표현식**으로 만들 수도 있다.
    - 예제 1
```java
```java
public class StreamFluentApiExample {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("Hello", "World", "Stream", "API", "Fluent", "Interface");

        // 단일 파이프라인
        List<String> result1 = words.stream()
                .filter(word -> word.length() > 3)
                .map(String::toUpperCase)
                .sorted()
                .collect(Collectors.toList());

        System.out.println(result1);
        // [FLUENT, HELLO, INTERFACE, STREAM, WORLD]

        // 여러 파이프라인
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        List<String> result2 = numbers.stream()
                .filter(n -> n % 2 == 0)  // 짝수 필터링
                .map(n -> n * n)          // 제곱
                .flatMap(n -> words.stream()
                        .filter(word -> word.length() == n)  // 길이가 n인 단어 필터링
                        .map(String::toLowerCase))           // 소문자로 변환
                .distinct()               // 중복 제거
                .sorted()                 // 정렬
                .collect(Collectors.toList());

        System.out.println(result2);
        // []
    }
}
```
- 예제 2
```java
public class ComplexStreamExpressionExample {
    public static void main(String[] args) {
        List<String> words = Arrays.asList("hello", "world", "stream", "expression");
        List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5);

        List<String> result = Stream.concat( // 연결 
	        // 파이프라인 1
            words.stream()
                .filter(w -> w.length() > 4)
                .map(String::toUpperCase),
            // 파이프라인 2
            numbers.stream()
                .filter(n -> n % 2 == 0)
                .map(n -> n * n)
                .map(Object::toString)
        )
        .sorted()
        .collect(Collectors.toList());

        System.out.println("Result: " + result);
        // Result: [16, 4, HELLO, STREAM, WORLD]
    }
}
```

## 스트림을 제대로 사용하자
- 스트림을 제대로 사용하면 프로그램이 짧고 깔끔해진다.
- 스트림을 잘못 사용하면 프로그램을 읽기 어렵고 유지보수도 힘들어진다.

### 예시
- `Anagram`을 계산하여 경계값보다 많은 원소수의 집합들을 출력한다.
- `computeIfAbsent` : 맵 안에 키가 있으면 값을 반환하고, 없으면 건네진 함수 객체를 키에 적용하여 값을 계산한 후 반환한다.
```java
public class IterativeAnagrams {  
    public static void main(String[] args) throws IOException {  
        File dictionary = new File(args[0]);  
        int minGroupSize = Integer.parseInt(args[1]);  
  
        Map<String, Set<String>> groups = new HashMap<>();  
        try (Scanner s = new Scanner(dictionary)) {  
            while (s.hasNext()) {  
                String word = s.next();  
                groups.computeIfAbsent(alphabetize(word),  
                        (unused) -> new TreeSet<>()).add(word);  
            }  
        }  
  
        for (Set<String> group : groups.values())  
            if (group.size() >= minGroupSize)  
                System.out.println(group.size() + ": " + group);  
    }  
  
    private static String alphabetize(String s) {  
        char[] a = s.toCharArray();  
        Arrays.sort(a);  
        return new String(a);  
    }  
}
```

#### 스트림을 과하게 사용한 예시
```java
// 코드 45-2 스트림을 과하게 사용했다. - 따라 하지 말 것! (270-271쪽)  
public class StreamAnagrams {  
    public static void main(String[] args) throws IOException {  
        Path dictionary = Paths.get(args[0]);  
        int minGroupSize = Integer.parseInt(args[1]);  
  
        try (Stream<String> words = Files.lines(dictionary)) {  
            words.collect(  
                    groupingBy(word -> word.chars().sorted()  
                            .collect(StringBuilder::new,  
                                    (sb, c) -> sb.append((char) c),  
                                    StringBuilder::append).toString()))  
                    .values().stream()  
                    .filter(group -> group.size() >= minGroupSize)  
                    .map(group -> group.size() + ": " + group)  
                    .forEach(System.out::println);  
        }  
    }  
}
```
- 코드는 짧지만 읽기는 어렵다.
> 스트림을 과용하면 프로그램이 읽거나 유지보수하기 어렵다.

#### 스트림을 적당히 사용한 코드
```java
// 코드 45-3 스트림을 적절히 활용하면 깔끔하고 명료해진다. (271쪽)  
public class HybridAnagrams {  
    public static void main(String[] args) throws IOException {  
        Path dictionary = Paths.get(args[0]);  
        int minGroupSize = Integer.parseInt(args[1]);  
  
        try (Stream<String> words = Files.lines(dictionary)) {  
            words.collect(groupingBy(word -> alphabetize(word)))  
                    .values().stream()  
                    .filter(group -> group.size() >= minGroupSize)  
                    .forEach(g -> System.out.println(g.size() + ": " + g));  
        }  
    }  
  
    private static String alphabetize(String s) {  
        char[] a = s.toCharArray();  
        Arrays.sort(a);  
        return new String(a);  
    }  
}
```
- 원래 코드보다 짧고 명확하다.

#### 참고) 람다에서는 타입 이름을 자주 생략하므로 매개변수 이름을 잘 지어야한다.
- 스트림 파이프라인의 가독성을 유지시키기 위함이다.
- `alphabetize`와 같은 도우미 메서드를 적절히 활용하는 것은 스트림 파이프라인에서 중요하다.
    - 파이프라인에서는 타입 정보가 명시되지 않거나 임시 변수를 자주 사용하기 때문이다.

#### char 용 스트림을 지원하지 않는다
- `char`은 기본 타입이지만 스트림을 지원하지 않는다.
- `"Hello world!".chars()`가 반환하는 스트림의 원소는 `int` 값이다.
    - **형변환**을 명시적으로 해주어야한다.
```java
"Hello world!".chars().forEach(x->System.out.print((char) x));
```
> char 값들을 처리할 때는 스트림을 삼가자.

### 모든 반복문을 스트림으로 바꾸지 말자
- 스트림으로 바꿀 경우 코드 가독성과 유지 보수 측면에서 손해를 볼 수도 있다.
- 중간 정도의 복잡한 작업은 스트림과 반복문을 적절히 조합하는 것이 최선이다.
> 기존 코드는 스트림을 사용하도록 리팩터링하되, 새 코드가 더 나아보일때만 반영하자.


## 코드 블록 vs 스트림 파이프라인
- 코드 블록 : 되풀이 되는 계산을 반복 코드에서는 `코드 블록`을 사용해 표현한다.
- 스트림 파이프라인: 되풀이 되는 계산을 `함수 객체`로 표현한다.

### 함수 객체로는 할 수 없지만 코드 블록으로 할 수 있는 일
- 코드 블록에서는 `범위 안의 지역변수`를 **읽고 수정**할 수 있다.
    - 람다에서는 `final`이거나 `사실상 final`인 변수만 **읽**을 수 있고, 지역변수를 **수정할 수 없다**.
- 코드 블록에서는 `return`, `break`, `continue`, `검사 예외`를 던질 수 있지만, 람다는 할 수 없다.

### 스트림 파이프라인에 적합한 연산
- 원소들의 시퀀스를 일관되게 변환한다.
- 원소들의 시퀀스를 필터링한다.
- 원소들의 시퀀스를 하나의 연산을 사용해 결합한다 (더하기, 연결하기, 최솟값 구하기)
- 원소들의 시퀀스를 컬렉션에 모은다 (공통 속성을 기준으로 묶는다)
- 원소들의 시퀀스에서 특정 조건을 만족하는 원소를 찾는다

### 스트림으로 처리하기 어려운 연산
#### 한 데이터가 파이프라인의 여러 단계를 통과할 때 각 단계의 값을 동시에 접근할 수 없다.
- 스트림 파이프라인은 일단 한 값을 다른 값에 매핑하면 원래의 값을 잃는 구조이기 때문이다.
```java
// 스트림을 사용해 처음 20개의 메르센 소수를 생성한다. (274쪽)  
public class MersennePrimes {  
    static Stream<BigInteger> primes() {  
        return Stream.iterate(TWO, BigInteger::nextProbablePrime);  
    }  
  
    public static void main(String[] args) {  
        primes().map(p -> TWO.pow(p.intValueExact()).subtract(ONE)) // 2^p - 1 
                .filter(mersenne -> mersenne.isProbablePrime(50))  
                .limit(20)  // 20개만
                .forEach(mp -> System.out.println(mp.bitLength() + ": " + mp));  
    }  
}
```
- p를 접근하려면 중간 연산이 아닌 최종 연산에서 결과를 도출해야한다.

> `primes()` : 스트림을 반환하는 메서드 이름은 원소의 정체를 알려주는 복수 명사로 쓰자.

### 스트림과 반복 중 선택해야하는 경우
- 두 집합의 원소들로 만들 수 있는 가능한 모든 조합 계산

#### 반복 형식
```java
public class Card {  
    public enum Suit { SPADE, HEART, DIAMOND, CLUB }  
    public enum Rank { ACE, DEUCE, THREE, FOUR, FIVE, SIX, SEVEN,  
                       EIGHT, NINE, TEN, JACK, QUEEN, KING }  
  
    private final Suit suit;  
    private final Rank rank;  
  
    @Override public String toString() {  
        return rank + " of " + suit + "S";  
    }  
  
    public Card(Suit suit, Rank rank) {  
        this.suit = suit;  
        this.rank = rank;  
  
    }  
    private static final List<Card> NEW_DECK = newDeck();  
  
    // 코드 45-4 데카르트 곱 계산을 반복 방식으로 구현 (275쪽)  
    private static List<Card> newDeck() {  
        List<Card> result = new ArrayList<>();  
        for (Suit suit : Suit.values())  
            for (Rank rank : Rank.values())  
                result.add(new Card(suit, rank));  
        return result;  
    }  

    public static void main(String[] args) {  
        System.out.println(NEW_DECK);  
    }  
}
```
> 이해하고 유지보수하기 편하다.

#### 스트림 형식
```java
// 코드 45-5 데카르트 곱 계산을 스트림 방식으로 구현 (276쪽)  
private static List<Card> newDeck() {  
    return Stream.of(Suit.values())  
            .flatMap(suit ->  
                    Stream.of(Rank.values())  
                            .map(rank -> new Card(suit, rank)))  
            .collect(toList());  
}
```
- `flatMap` (평탄화 과정) : 스트림의 원소 각각을 하나의 스트림으로 매핑한 다음 그 스트림을 다시 하나의 스트림으로 합치는 것
> 스트림과 함수형 프로그램이에 익숙하다면 스트림 방식이 더 명확하고 쉽다.

> 스트림 방식이 나아 보이고, 동료들도 스트림 코드를 이해할 수 있고 선호한다면 스트림 방식을 사용하자

## 결론
- 스트림을 이용하면 더 멋지게 처리할 수 있는 일도 있고, 반복문을 이용하면 더 알맞은 일도 있다.
    - 이 둘을 `조합`했을때 수많은 작업이 가장 멋지게 해결된다.
- **스트림과 반복 중 어느 쪽이 나은지 확신하기 어렵다면 다 해보고 더 나은 쪽을 택하라.**
