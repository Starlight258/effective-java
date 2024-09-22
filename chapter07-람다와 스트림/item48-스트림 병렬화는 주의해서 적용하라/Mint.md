# 48. 스트림 병렬화는 주의해서 적용하라
## 동시성 프로그래밍
- 안전성과 응답 가능 상태를 유지하기 위해 노력해야한다.

### parallel() 사용
```java
// 병렬 스트림을 사용해 처음 20개의 메르센 소수를 생성하는 프로그램 (291쪽 코드 48-1의 병렬화 버전)  
// 주의: 병렬화의 영향으로 프로그램이 종료하지 않는다.  
public class ParallelMersennePrimes {  
    public static void main(String[] args) {  
        primes().map(p -> TWO.pow(p.intValueExact()).subtract(ONE))  
                .parallel() // 스트림 병렬화  
                .filter(mersenne -> mersenne.isProbablePrime(50))  
                .limit(20)  
                .forEach(System.out::println);  
    }  
  
    static Stream<BigInteger> primes() {  
        return Stream.iterate(TWO, BigInteger::nextProbablePrime);  
    }  
}
```
- 위 스트림에 병렬 처리를 위해 `parallel()`을 작성하면, 프로그램이 매우 느려진다.
- 스트림 라이브러리가 이 파이프라인을 병렬화하는 방법을 찾아내지 못했다.
- 데이터 소스가 `Stream.iterate()`이거나 중간 연산으로 `limit`을 사용하면 파이프라인 병렬화로는 성능 개선을 기대할 수 없다.
    - `Stream.iterate()` : 이전 요소를 기반으로 다음 요소를 생성하는 **순차적인 방식**으로 작동, 병렬화 어려움
    - `limit` : 스트림의 크기를 제한, 각 스레드가 얼마나 많은 요소를 처리해야할지 예측 어려움

### 병렬화의 이점을 얻으려면 쉽게 분할할 수 있는 데이터 소스를 사용하는 것이 좋다.
- `ArrayList`, `HashMap`, `HashSet`, `ConcurrentHashMap`의 인스턴스
- `배열`, `int 범위`, `long 범위`
> 나누는 작업은 Spliterator가 담당한다.
> Stream이나 Iterable의 spliterator 메서드로 얻어올 수 있다.

- 위 자료구조들은 원소들을 순차적으로 실행할 때 `참조 지역성`이 뛰어나다.
    - 다량의 데이터를 처리하는 `벌크 연산`을 `병렬화`할때 좋다.
    - 기본 타입의 배열은 `참조 지역성`이 가장 뛰어나다.

### 스트림 파이프라인의 `종단 연산`의 동작 방식도 병렬 수행 효율에 영향을 준다.
- 종단 연산 중 `병렬화`에 가장 적합한 것은 `축소`이다.
    - `축소` : 파이프라인에서 만들어진 모든 원소를 하나로 합치는 작업
    - `reduce()`, `min`, `max`, `count`, `sum`
    - `anyMatch`, `allMatch`, `noneMatch`
- 가변 축소를 수행하는 Stream의 `collect` 메서드는 병렬화에 적합하지 않다.
    - 컬렉션을 함치는 부담이 크기 때문이다.

### 스트림을 잘못 병렬화하면 성능도 나빠지고 결과가 잘못되어 예상치 못한 동작이 발생할 수 있다.
- `안전 실패` : 병렬화된 파이프라인이 사용하는 `mappers`, `filters` 등의 함수가 명세대로 동작하지 않을 때 벌어진다.
    - ex) Stream의 reduce 연산에 건네지는 accumulator와 combiner 함수는 **결합법칙을 만족하고, 간섭받지 않고, 상태를 갖지 않아야한다.**
#### 스트림 성능 향상 추정 방법
- 스트림 안의 원소 수와 원소당 수행되는 코드 줄 수를 곱하여, 이 값이 최소 수십만은 되어야 성능 향상을 맛볼 수 있다.
> 생각보다 스트림 병렬화가 효과를 보는 경우는 많지 않다.

### 조건이 잘 갖춰지면 parallel 호출 하나로 거의 프로세서 코어 수에 비례하는 성능 향상을 볼 수 있다
```java
// 코드 48-3 소수 계산 스트림 파이프라인 - 병렬화 버전 (295쪽)  
static long pi(long n) {  
    return LongStream.rangeClosed(2, n)  
            .parallel() // 병렬화 적용
            .mapToObj(BigInteger::valueOf)  
            .filter(i -> i.isProbablePrime(50))  
            .count();  
}  
  
public static void main(String[] args) {  
    System.out.println(pi(10_000_000));  
}
```

#### 무작위 수들로 이뤄진 스트림을 병렬화하려거든 `SplittableRandom` 인스턴스를 이용하자.
- `ThreadLocalRandom`(혹은 `Random`)보다 `SplittableRandom` 인스턴스를 사용하자
    - `ThreadLocalRandom`은 단일 스레드에서 쓰고자 만들어졌다.
    - `Random`은 모든 연산을 동기화하므로 병렬 처리하면 최악의 성능을 보일 것이다.
```java
SplittableRandom random = new SplittableRandom();

Stream.generate(random::nextInt)
      .parallel()
      .limit(1000000)
      .forEach(/* 처리 로직 */);
```

# 결론
- 계산도 올바로 수행하고 성능도 빨라질 거라는 확신 없이는 `스트림 파이프라인 병렬화`를 시도하지 마라.
    - 스트림을 잘못 병렬화하면 프로그램을 `오동작`하게 하거나 `성능`을 급격히 떨어뜨린다.
    - 병렬화하는 편이 낫다고 생각하더라도, 수정 후의 코드의 `성능 지표`를 유심히 관찰하라.
    - 계산도 정확하고 성능도 좋아졌음이 확실해졌을 때만 병렬화 버전의 코드를 운영 코드에 반영하라.
