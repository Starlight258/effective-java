# 46. 스트림에서는 부작용 없는 함수를 사용하라
## 스트림
- 스트림은 함수형 프로그래밍에 기초한 패러타임이다.
- `계산`을 일련의 `변환`으로 재구성한다.
    - 각 변환 단계는 이전 단계의 결과를 받아 처리하는 `순수 함수`이다.
> 순수 함수 : 오직 입력만이 결과에 영향을 주는 함수
- 스트림 연산에 건네지는 함수 객체는 `부작용`이 없어야한다.

### 스트림 패러다임을 이해하지 못한 채 API만 사용한 예제
```java
// 코드 46-1 스트림 패러다임을 이해하지 못한 채 API만 사용했다 - 따라 하지 말 것! (277쪽)  
Map<String, Long> freq = new HashMap<>();  
try (Stream<String> words = new Scanner(file).tokens()) {  
    words.forEach(word -> {  
        freq.merge(word.toLowerCase(), 1L, Long::sum);  
    });  
}
```
> merge(키, 초기값, 기존값과 새 값 합치는 함수)

- `forEach` 가 그저 스트림이 수행한 연산 결과를 보여주는 일 이상을 수행한다.
    - 람다가 외부 상태(`freq`)를 변경하여 불변성 원칙을 위배한다.
    - 병렬 처리가 어렵다.
    - `forEach`가 단순히 반복을 위해 사용하고 있다. `collect`나 `reduce`를 사용하면 더 명확하다.
> forEach는 스트림 계산 결과를 보고할때만 사용하고, 계산하는데는 쓰지 말자.

### 스트림을 잘 활용한 코드
```java
// 코드 46-2 스트림을 제대로 활용해 빈도표를 초기화한다. (278쪽)  
Map<String, Long> freq;  
try (Stream<String> words = new Scanner(file).tokens()) {  
    freq = words  
            .collect(groupingBy(String::toLowerCase, counting()));  
}  
  
System.out.println(freq);
```
- `수집기`(collector)를 사용한다.
- 기존 맵 객체를 계속 수정하는 것이 아닌 새로운 맵을 생성하여 할당한다.
- 의도가 더 명확하며(collect) 더 간결하다.

## 수집기(collector)
- 축소 전략을 캡슐화한 블랙 박스
    - 스트림의 원소들을 객체 하나에 취합한다.
- 주로 컬렉션을 생성하므로 `collector`라고 부른다.
- 총 3가지 : `toList()`, `toSet()`, `toCollection(collectionFactory)`

#### 예제
```java
// 코드 46-3 빈도표에서 가장 흔한 단어 10개를 뽑아내는 파이프라인 (279쪽)  
List<String> topTen = freq.keySet().stream()  
        .sorted(comparing(freq::get).reversed())  
        .limit(10)  
        .collect(toList());  
  
System.out.println(topTen);
```

### toMap(keyMapper, valueMapper)
```java
public class OperationExample {
    
    enum Operation {
        PLUS("+") {
            double apply(double x, double y) { return x + y; }
        },
        MINUS("-") {
            double apply(double x, double y) { return x - y; }
        },
        TIMES("*") {
            double apply(double x, double y) { return x * y; }
        },
        DIVIDE("/") {
            double apply(double x, double y) { return x / y; }
        };

        private final String symbol;

        Operation(String symbol) {
            this.symbol = symbol;
        }

        @Override
        public String toString() {
            return symbol;
        }

        abstract double apply(double x, double y);

        private static final Map<String, Operation> stringToEnum = // 여기 부분
            Stream.of(values()).collect(
                Collectors.toMap(Object::toString, e -> e));
        
        public static Operation fromString(String symbol) {
            return stringToEnum.get(symbol);
        }

        public static Map<String, Operation> getStringToEnumMap() {
            return stringToEnum;
        }
    }

    public static void main(String[] args) {
        Operation.getStringToEnumMap().forEach((key, value) -> 
            System.out.println("Key: '" + key + "', Value: " + value.name()));
    }
}
```
- 결과
```java
Key: '+', Value: PLUS
Key: '-', Value: MINUS
Key: '*', Value: TIMES
Key: '/', Value: DIVIDE
```

#### 3번째 인자 : 병합 함수(merge)
- 같은 키를 공유하는 값들은 이 병합 함수를 이용해 기존 값에 합쳐진다.
```java
Collectors.toMap(
    Album::getArtist,    // key mapper
    Album::getSales,     // value mapper
    Integer::sum         // merge function
)
```
> 같은 아티스트의 앨범이 여러 개 있을 때, 판매량을 합산한다.

- 마지막에 쓴 값을 취하는 수집기
```java
toMap(keyMapper, valueMapper, (oldVal, newVal) -> newVal)
```

- 예시
```java
Collectors.toMap(
    Employee::getId,           // key mapper
    employee -> employee,      // value mapper
    (oldValue, newValue) -> newValue  // merge function
)
```

- 각 키와 해당 키의 특정 원소를 연관 짓는 맵을 생성하는 수집기
```java
Map<Artist, Album> topHits = albums.collect(
	toMap(Album::artist, a->a, maxBy(comparing(Album::sales))));
```
- 만약 같은 아티스트의 앨범이 여러 개 있다면?
    - `sales`가 가장 높은 Album을 선택하여 아티스트별로 가장 높은 판매량을 기록한 앨범만 맵에 포함된다.

#### 4번째 인자: 맵 팩터리
```java
Map<String, Integer> nameToAge = people.stream()
    .collect(Collectors.toMap(
        Person::getName,
        Person::getAge,
        (a, b) -> a, // merge function
        TreeMap::new // map factory
    ));
```

### groupingBy
- 입력으로는 `분류 함수`를 받고 출력으로는 원소들을 카테고리별로 모아 놓은 `맵`을 담은 수집기를 반환한다.
    - 각 요소를 어떤 기준으로 `그룹화`할지 정의하는 함수
```java
Collectors.groupingBy(Function<? super T, ? extends K> classifier)
```

#### 두번째 인자 :  `다운스트림 컬렉터`를 사용할 수 있다.
- `다운스트림 컬렉터` : 그룹화 작업 후에 각 그룹에 대해 추가적인 `축소`(reduction) 작업을 수행하는 컬렉터
- 각 그룹에 대해 별도의 처리를 할 수 있다.
```java
List<String> words = Arrays.asList("apple", "banana", "cherry", "date", "elderberry", "fig");

// 다운스트림 컬렉터 없이 그룹화
Map<Integer, List<String>> groupedByLength = words.stream()
    .collect(Collectors.groupingBy(String::length));

System.out.println("Without downstream collector: " + groupedByLength);

// 다운스트림 컬렉터(counting)를 사용한 그룹화
Map<Integer, Long> countByLength = words.stream()
    .collect(Collectors.groupingBy(String::length, Collectors.counting()));

System.out.println("With downstream collector (counting): " + countByLength);
```
출력
```bash
Without downstream collector: {3=[fig], 4=[date], 5=[apple], 6=[banana, cherry], 10=[elderberry]}
With downstream collector (counting): {3=1, 4=1, 5=1, 6=2, 10=1}
```

- `toSet()`이나 `toCollection(collectionFactory)`를 건네는 방법도 있다.

#### 맵 팩터리 지정
```java
Map<Integer, List<Person>> peopleByAge = people.stream()
    .collect(Collectors.groupingBy(
        Person::getAge,
        LinkedHashMap::new, // 맵 팩터리 지정
        Collectors.toList()
    ));
```
> 결과 맵이 `LinkedHashMap`으로 생성된다.

### partitioningBy
- 키가 boolean인 맵 반환
```java
Map<Boolean, List<Person>> partitionedByAge = people.stream()
    .collect(Collectors.partitioningBy(person -> person.getAge() >= 30));
```
- 추가 처리하기
```java
Map<Boolean, List<String>> namesByAgeGroup = people.stream()
    .collect(Collectors.partitioningBy(
        person -> person.getAge() >= 30,
        Collectors.mapping(Person::getName, Collectors.toList())
    ));
```

### minBy, maxBy
- 스트림에서 값이 가장 작은 혹은 가장 큰 원소를 찾아 반환한다.
```java
public class StreamCollectorsExample {
    public static void main(String[] args) {
        List<String> fruits = Arrays.asList("apple", "banana", "cherry", "date", "elderberry");
        
        // minBy 예시
        String shortestFruit = fruits.stream()
                .collect(Collectors.minBy(Comparator.comparing(String::length)))
                .orElse("No fruit found");
        System.out.println("가장 짧은 과일 이름: " + shortestFruit);
        
        // maxBy 예시
        String longestFruit = fruits.stream()
                .collect(Collectors.maxBy(Comparator.comparing(String::length)))
                .orElse("No fruit found");
        System.out.println("가장 긴 과일 이름: " + longestFruit);
        
        // joining 예시 (매개변수 없음)
        String joinedFruits = fruits.stream()
                .collect(Collectors.joining());
        System.out.println("연결된 과일 이름 (구분자 없음): " + joinedFruits);
        
        // joining 예시 (구분자 있음)
        String joinedFruitsWithDelimiter = fruits.stream()
                .collect(Collectors.joining(", "));
        System.out.println("연결된 과일 이름 (구분자 있음): " + joinedFruitsWithDelimiter);
    }
}
```
### joining
- 문자열 등의 `CharSequence 인스턴스`의 스트림에만 적용할 수 있다.
- 매개변수가 없으면 단순히 **원소들을 연결**한다.
- 구분문자를 매개변수로 받으면 **연결 부위에 구분문자를 삽입**한다.
```java
public class StreamCollectorsExample {
    public static void main(String[] args) {
        List<String> fruits = Arrays.asList("apple", "banana", "cherry", "date", "elderberry");
         
        // joining 예시 (매개변수 없음)
        String joinedFruits = fruits.stream()
                .collect(Collectors.joining());
        System.out.println("연결된 과일 이름 (구분자 없음): " + joinedFruits);
        
        // joining 예시 (구분자 있음)
        String joinedFruitsWithDelimiter = fruits.stream()
                .collect(Collectors.joining(", "));
        System.out.println("연결된 과일 이름 (구분자 있음): " + joinedFruitsWithDelimiter);
    }
}
```

# 결론
- 스트림 파이프라인 프로그래밍의 핵심은 `부작용 없는 함수 객체`이다.
    - **모든 함수 객체가 부작용이 없어야한다.**
- `forEach`는 스트림이 수행한 계산 결과를 보고할때만 사용해야한다.
- 스트림을 올바로 사용하려면 `수집기`를 알아둬야한다.
    - `toList`, `toSet`, `toMap`, `groupingBy`, `joining`이 있다.
