# 47. 반환 타입으로는 스트림보다 컬렉션이 낫다
## 원소 시퀀스를 `스트림`으로 반환할 경우
- 스트림은 반복을 지원하지 않는다.
    - 스트림과 반복을 알맞게 조합해야 좋은 코드가 나온다.
### `Stream<E>` <-> `Iterable<E>` 어댑터
```java
// 스트림 <-> 반복자 어댑터 (285-286쪽)  
public class Adapters {  
    // 코드 47-3 Stream<E>를 Iterable<E>로 중개해주는 어댑터 (285쪽)  
    public static <E> Iterable<E> iterableOf(Stream<E> stream) {  
        return stream::iterator;  
    }  
  
    // 코드 47-4 Iterable<E>를 Stream<E>로 중개해주는 어댑터 (286쪽)  
    public static <E> Stream<E> streamOf(Iterable<E> iterable) {  
        return StreamSupport.stream(iterable.spliterator(), false);  
    }  
}
```

## 원소 시퀀스를 `컬렉션`으로 반환할 경우
- `Collection` 인터페이스는 `Iterable`의 하위 타입이고 stream 메서드(`stream()`)도 제공한다.
    - 반복과 스트림을 동시에 지원한다.
> 원소 시퀀스를 반환하는 공개 API 반환 타입에는 Collection이나 그 하위 타입을 쓰는 것이 최선이다.
- 단지 컬렉션을 반환한다는 이유로 덩치 큰 시퀀스를 메모리에 올려서는 안된다.
```java
// 좋지 않은 방법 (모든 라인을 메모리에 로드)
List<String> allLines = Files.readAllLines(path);

// 더 나은 방법 (필요할 때마다 라인을 읽음)
Stream<String> lines = Files.lines(path);
```

## `전용 컬렉션`을 반환하는 방법
- 반환할 시퀀스가 크지만 표현을 간결하게 할 수 있다면 전용 컬렉션을 구현하여 반환하자.
- 예시 : 멱집합
    - 멱집합을 표준 컬렉션 `구현체에` 저장하는 것은 위험하다( 2^n개 원소)
    - `AbstractList`를 이용하여 전용 컬렉션을 구현하자.
    - 각 원소의 인덱스를 **비트 벡터**로 사용하자.
```java
import java.util.*;  
  
public class PowerSet {  
    // 코드 47-5 입력 집합의 멱집합을 전용 컬렉션에 담아 반환한다. (287쪽)  
    public static final <E> Collection<Set<E>> of(Set<E> s) {  
        List<E> src = new ArrayList<>(s);  
        if (src.size() > 30)  
            throw new IllegalArgumentException(  
                "집합에 원소가 너무 많습니다(최대 30개).: " + s);  
        return new AbstractList<Set<E>>() {  
            @Override public int size() {  
                // 멱집합의 크기는 2를 원래 집합의 원소 수만큼 거듭제곱 것과 같다.  
                return 1 << src.size();  
            }  
  
            @Override public boolean contains(Object o) {  
                return o instanceof Set && src.containsAll((Set)o);  
            }  
  
            @Override public Set<E> get(int index) {  
                Set<E> result = new HashSet<>();  
                for (int i = 0; index != 0; i++, index >>= 1)  
                    if ((index & 1) == 1)  
                        result.add(src.get(i));  
                return result;  
            }  
        };  
    }  
  
    public static void main(String[] args) {  
        Set s = new HashSet(Arrays.asList(args));  
        System.out.println(PowerSet.of(s));  
    }  
}
```

- 전용 컬렉션 구현시 `contains` 와 `size`를 구현하면 된다.
    - 위 두 함수를 구현하는 것이 불가능하면 `컬렉션`보다는 `스트림`이나 `Iterable`을 반환하는 편이 낫다.
- 입력 리스트의 모든 부분리스트를 스트림으로 구현해보자.
    - 어떤 리스트의 부분 리스트는 리스트의 `prefix`의 `suffix`에 빈 리스트 하나만 추가하면 된다.
```java
// 코드 47-7 입력 리스트의 모든 부분리스트를 스트림으로 반환한다(빈 리스트는 제외). (289쪽)  
// 289쪽의 명확한 반복 코드의 변형이다.  
public static <E> Stream<List<E>> of(List<E> list) {  
    return IntStream.range(0, list.size())  
            .mapToObj(start ->  
                    IntStream.rangeClosed(start + 1, list.size())  
                            .mapToObj(end -> list.subList(start, end)))  
            .flatMap(x -> x);  
}
```


# 결론
- 원소 시퀀스를 반환하는 메서드를 작성할 때는 `스트림`과 `반복`으로 처리하길 원하는 사용자 모두를 만족시키도록 노력하자.
    - `컬렉션`을 반환할 수 있다면 그렇게 하라.
- 원소 개수가 적다면 `ArrayList` 같은 `표준 컬렉션`에 담아 반환하라.
- 그렇지 않으면 `전용 컬렉션`을 구현할지 고민할라.
- 컬렉션을 반환하는 것이 불가능하면 `스트림`과 `Iterable` 중 더 자연스러운 것을 반환하라.

