## 요약

### 스트림 파이프라인과 병렬화

```java
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
- `parallel()` 메서드는 파이프라인을 병렬 실행할 수 있는 스트림을 제공한다
- 하지만 주의가 필요하다 위의 코드는 응답 불가 에러를 낸다
- 이는 스트림 라이브러리가 프이프라인을 병렬화하는 방법을 찾아내지 못했기 때문이다
- 데이터 소스가 `Stream.iterate` 이거나 중간 연산이 `limit` 라면 파이프라인 병렬화로는 성능 개선을 기대할 수 없다
- 스트림 파이프라인을 마구잡이로 병렬화하면 안 된다. 성능이 오히려 끔찍하게 나빠질 수도 있다 

### 스트림의 소스가 `ArrayList`, `HashMap`, `HashSet`, `ConcurrentHashMap` 의 인스턴스 이거나 배열, int 범위, long 범위 일때 효과가 좋음
- 이 자료구조들은 모두 데이터를 원하는 크기로 정확하고 손쉽게 나눌 수 있다
- 원소들을 순차적으로 실행할 때 참조 지역성(locality of reference) 이 뛰어나다 (메모리에 연속해서 저장)
- 참조 지역성은 다량의 데이터를 처리하는 벌크 연산을 병렬화할 때 아주 중요한 요소이다
- 기본 타입의 배열이 참조 지역성이 가장 뛰어나다 

### 종단 연산의 동작 방식도 병렬 수행 효율에 영향을 줌
- 종단 연산 중 병렬화에 가장 적합한 것은 축소(reduce) 이다
- `Stream` 의 `reduce`, `min`, `max`, `count`, `sum` 같이 완성된 형태로 제공되는 메서드 중 하나를 선택해 수행한다
- `anyMatch` , `allMatch` , `noneMatch` 처럼 조건에 맞으면 바로 반환되는 메서드도 병렬화에 적합하다
- 반면 가변 축소를 수행하는 `collect` 메서드는 컬렉션들을 합치는 부담이 크기 떄문에 병렬화에 적합하지 않다
- 직접 구현한 `Stream` , `Iterable`, `Collection` 이 병렬화의 이점을 제대로 누리게 하고 싶다면 `spilterator` 메서드를 반드시 재정의하고 결과 스트림의 병렬화 성능을 강도 높게 테스트하라 

### 스트림을 잘못 병렬화해서 발생할 수 있는 잘못된 결과나 오동작을 안전 실패라 한다

- Stream 명세는 `mappers`, `filters` 혹은 프로그래머가 제공한 다른 함수 객체에 관한 엄중한 규약을 정의해놨다
- `Stream`의 `reduce` 연산에 건내지는 `accumulator` 와 `combiner` 함수는 반드시 **결합법칙을 만족**하고, **간섭받지 않고**, **상태를 갖지 않아야** 한다. 

### 스트림 병렬화가 효과를 보는 경우는 많지 않지만 조건이 잘 갖춰지면 `parallel` 메서드 호출 하나로 거의 프로세서 코어 수에 비례하는 성능 향상을 만끽할 수 있다
