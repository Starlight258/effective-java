## 요약

### 스트림은 반복을 지원하지 않는다
- Stream 은 Iterable 인터페이스를 구현하지 않으므로 for-each 문에서 사용할 수 없다
- 하지만 Iterable 인터페이스가 정의한 추상 메서드를 전부 포함하고, 인터페이스대로 동작한다

```java
for (ProcessHandle ph : ProcessHandle.allProcesses()::iterator) {
    // do something
}
```
- Stram iterator 메서드에 참조를 건냄 -> 컴파일 에러


```java
for (ProcessHandle ph : (Iterable<ProcessHandle>) ProcessHandle.allProcesses()::iterator) {
    // do something
}
```
- Iterable 로 형변환 
- 난잡한 코드가 됨

```java
public static <E> Iterable<E> iterableOf(Stream<E> stream) {
    return stream::iterator;
}
```
- 어뎁터 사용 iterableOf() 로 명시적으로 Iterable 로 변환

```java
public static <E> Stream<E> streamOf(Iterable<E> iterable) {
    return StreamSupport.stream(iterable.spliterator(), false);
}
```
- 객체 시퀸스를 반환하는 메서드가 오직 stream 파이프라인에서만 쓰인다면 Stream을 반환


### Collection 인터페이스는 반복과 스트림을 동시에 지원한다
- 원소 시퀀스를 반환하는 타입에는 Collection이나 그 하위 타입을 사용하는게 일반적으로 최선이다
- 하지만 단지 컬렉션을 반환한다는 이유로 덩치 큰 시퀸스를 메모리에 올려서는 안 된다 

```java
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
- 멱집합이란, 한 집합의 모든 부분집합을 원소로 하는 집합이다.
- 원소가 n개인 집합의 멱집합의 크기는 2^n 이다.

```java
public class SubLists {
    // 코드 47-6 입력 리스트의 모든 부분리스트를 스트림으로 반환한다. (288-289쪽)
    public static <E> Stream<List<E>> of(List<E> list) {
        return Stream.concat(Stream.of(Collections.emptyList()),
                prefixes(list).flatMap(SubLists::suffixes));
    }

    private static <E> Stream<List<E>> prefixes(List<E> list) {
        return IntStream.rangeClosed(1, list.size())
                .mapToObj(end -> list.subList(0, end));
    }

    private static <E> Stream<List<E>> suffixes(List<E> list) {
        return IntStream.range(0, list.size())
                .mapToObj(start -> list.subList(start, list.size()));
    }

//    // 코드 47-7 입력 리스트의 모든 부분리스트를 스트림으로 반환한다(빈 리스트는 제외). (289쪽)
//    // 289쪽의 명확한 반복 코드의 변형이다.
//    public static <E> Stream<List<E>> of(List<E> list) {
//        return IntStream.range(0, list.size())
//                .mapToObj(start ->
//                        IntStream.rangeClosed(start + 1, list.size())
//                                .mapToObj(end -> list.subList(start, end)))
//                .flatMap(x -> x);
//    }

    public static void main(String[] args) {
        List<String> list = Arrays.asList(args);
        SubLists.of(list).forEach(System.out::println);
    }
}
```
