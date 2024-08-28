### 요약

### 스트림

- 기본 타입으로는 int, long, double을 지원하며, 객체 참조도 원소가 될 수 있다.
- 즉 Stream, IntStream, LongStream, DoubleStream 존재함

### 파이프라인

- 소스 스트림에서 시작해 어떤 하나의 종단 연산(terminal operation) 으로 끝난다
    - 이전 연산 중 마지막 연산의 결과에 최종 연산을 적용
    - sum, average, max 등과 같이 결과를 집계하거나 아니면 원소들을 콜렉션에 담을 수도 있음
- 이 과정 가운데에 하나 이상의 중간 연산(intermediate operation)이 있을 수 있음
    - 하나의 스트림을 다른 스트림으로 변환(transform)
    - 각 원소를 필터링하거나, 함수를 적용하는 등의 활용
    - filter, map, distinct, sort… 등

### 지연 평가(Lazy Evaluation)

- 스트림에 대한 평가는 종단 연산이 호출될 때 이루어짐
- JVM은 평가가 시작되기 이전에 먼저 파이프라인을 검사하고, 이를 바탕으로 연산에 대한 최적화 계획을 세운다
- 이를 이용하여 연산에 실제로 필요한 데이터만 평가하는 게으른(lazy) 방식의 연산이 수행됨
- 종단 연산에 사용하지 않는 데이터는 실제로 계산되지 않음
- 즉, 종단 연산이 없는 파이프라인에는 아무 일도 일어나지 않음

### 스트림의 적절한 활용 (아나그램 예제)

사전을 보고 원소 수가 문턱 값보다 높은 그룹을 찾는 프로그램 

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

- computeIfAbsent : 맵 안에 키가 있는지 찾은 다음, 있으면 단순히 그 키에 매핑된 값을 반환, 키가 없으면 함수식을 통해 생성된 값을 키에 매핑한 후 그 값을 반환

```java
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

- 스트림을 이용해 사전을 받아와서 그룹을 만들고 필터링하는 모든 과정을 하나의 표현식으로 묶었다
- 스트림을 과용하면 유지보수나 가독성에서 어려움이 있을 수 있음

```java
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

- alphabetize 메소드에서는 스트림을 사용하지 않았다. 그 이유는 char의 스트림은 자바는 지원하지 않고 있기 때문이다
- 스트림에서 char 자료형은 삼가자

### 람다와 코드블럭

- 코드 블록에서는 범위 안의 지역변수를 읽고 수정할 수 있지만, 
람다는 final이거나 사실상 final 변수만 가능하며 지역 변수를 수정할 수 없다.
- 코드 블록에서는 return문이나 break, continue로 반복문을 제어할 수 있지만, 람다는 불가능

### 언제 스트림을 써야 해?

- 원소들의 시퀀스를 일관되게 변환한다.
- 원소들의 시퀀스를 필터링한다.
- 원소들의 시퀀스를 하나의 연산을 사용해 결합한다. (더하기, 연결하기, 최소값 등..)
- 원소들의 시퀀스를 컬렉션에 모은다
- 원소들의 시퀀스에서 특정 조건을 만족하는 원소를 찾는다

```java
public class MersennePrimes {
    static Stream<BigInteger> primes() {
        return Stream.iterate(TWO, BigInteger::nextProbablePrime);
    }

    public static void main(String[] args) {
        primes().map(p -> TWO.pow(p.intValueExact()).subtract(ONE))
                .filter(mersenne -> mersenne.isProbablePrime(50))
                .limit(20)
                .forEach(mp -> System.out.println(mp.bitLength() + ": " + mp));
    }
}
```

- 메르센 소수를 출력하는 프로그램 코드 (소수 p에 대해 2^p -1 이 소수인 수)

```java
private static List<Card> newDeck() {
        List<Card> result = new ArrayList<>();
        for (Suit suit : Suit.values())
            for (Rank rank : Rank.values())
                result.add(new Card(suit, rank));
        return result;
    }

private static List<Card> newDeck() {        
			return Stream.of(Suit.values())
               .flatMap(suit ->
                        Stream.of(Rank.values())
                                .map(rank -> new Card(suit, rank)))
                .collect(toList());
   }
```

- 스트림과 반복 중 어느쪽이 나은지 확신하기 어렵다면 둘 다 해보고 더 나은 쪽을 택하라