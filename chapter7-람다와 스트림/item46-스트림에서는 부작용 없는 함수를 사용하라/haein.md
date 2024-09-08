## 요약

- 스트림 API 를 올바르게 활용하기 위해서는 함수평 프로그래밍에 기초한 패러다임도 받아들여야 함
- 스트림 패러다임의 핵심은 **계산을 일련의 변환으로 재구성하는 부분이다.**



```java
        // 코드 46-1 스트림 패러다임을 이해하지 못한 채 API만 사용했다 - 따라 하지 말 것! (277쪽)
       Map<String, Long> freq = new HashMap<>();
        try (Stream<String> words = new Scanner(file).tokens()) {
            words.forEach(word -> {
                freq.merge(word.toLowerCase(), 1L, Long::sum);
            });
        }
```
- 람다가 외부 상태를 수정하고 있음


```java
        Map<String, Long> freq;
        try (Stream<String> words = new Scanner(file).tokens()) {
            freq = words
                    .collect(groupingBy(String::toLowerCase, counting()));
        }

        System.out.println(freq);
```
- forEach 메서드는 스트림 계산 결과를 보고하는 용도로만 사용해야 함

###  java.util.stream.Collectors
- 축소 전략을 캡슐화한 블랙박스 객체라고 이해
- 스트림의 원소들을 객체 하나의 취합 
- toList(), toSet(), toCollection(collectionFactory) 등의 정적 메서드를 제공

```java
        List<String> topTen = freq.keySet().stream()
                .sorted(comparing(freq::get).reversed())
                .limit(10)
                .collect(toList());

        System.out.println(topTen);
```
-comparing() 을 통해 키 추출 함수로 비교자 객체를 만들 수 있음


### toMap() 
- 스트림 원소를 키에 매핑한다 
- 다양한 시그니쳐가 있는데 `toMap(keyMapper, valueMapper)` 키 매핑 함수와 값 매핑 함수를 인자로 받는다
- `toMap(keyMapper, valueMapper, merge)` 는 스트림 원소 다수가 같은 키를 사용하여 충돌이 나는 경우, 병합 함수를 사용해 이를 해결한다 병합 함수 는 `BinaryOperator<T>` 를 구현한 함수여야 함
- `toMap(keyMapper, valueMapper, merge, mapFactory)` 는 네 번째 인수로 맵 팩터리를 받아 원하는 Map 구현체를 정할 수 있음
- 이 메서드들은 모두 `toConcurrentMap` 이라는 동시성 버전을 제공


### groupingBy()
- 인자로 분류 함수를 받고 출력으로는 원소들을 카테고리별로 모아 놓은 맵을 담은 수집기를 반환
- `groupingBy(classifier)` 는 가장 기본 버전으로 카테고리가 키이고 원소들의 리스트가 값이 되는 맵을 생성
- `groupingBy(classifier, downstream)` 은 맵이 리스트 이외에 값을 갖도록 다운스트림을 명시함
- `groupingBy(classifier, mapFactory, downstream)` 은 반환되는 맵 구현체를 직접 정할 수 있음 + 컬렉션의 타입도 지정할 수 있음




### partitioningBy
- `groupingBy`의 사촌격
- 분류 함수에 predicate를 받고 키가 Boolean인 맵을 반환
- 다운스트림 입력 받는 버전도 다중정의되어있음

### 다운스트림 수집기 전용 메서드
- `counting()`
- `summing(), averaging(), summarizing()`
    - 각각 int, long, double 스트림용으로 하나씩 존재
다중 정의된 `reducing()`, `filtering()`, `mapping()`, `flatMapping()`, `collectingAndThen()` 

### minBy, maxBy
- 인수로 받은 비교자를 이용해 스트림에서 값이 가장 작은/큰 원소를 찾아 반환

### joining

- CharSequence 인스턴스 스트림에만 적용 가능
- `joining()`
    - 단순히 원소들을 연결하는 수집기 반환
- `joining(delimiter)`
    - CharSequence 타입의 delimiter를 매개변수로 받아 각 연결 부위에 delimiter 삽입
- `joining(delimiter, prefix, suffix)`
    - 접두 문자, 접미 문자를 매개변수로 받아 문자열의 맨 앞과 뒤에 삽입