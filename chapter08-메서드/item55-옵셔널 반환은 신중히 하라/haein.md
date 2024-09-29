## Optional<T>

- Java 8부터 적용
- 반환할 값이 비어있는 경우를 표현하고 싶은데 그것이 null 이 아닌 객체로 표현하고 싶은 경우 사용
- 옵셔널은 비어 있을 수 있으며(empty) , 원소를 최대 1개까지 가질 수 있(이 원소는 null 이 아님) 불변 컬렉션이다
- 아무것도 반환하지 않는, 비어있는 경우에 T 대신 Optional<T> 를 반환하도록 구현

> https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/Optional.html
> 
> 
> ```
> API Note:
> Optional is primarily intended for use as a method return type where there is a clear need to represent "no result," and where using null is likely to cause errors. A variable whose type is Optional should never itself be null; it should always point to an Optional instance.
> 
> 메소드가 반환할 결과 값이 '없음'을 명백하게 표현할 필요가 있고,
> null을 반환하면 에러가 발생할 가능성이 높은 상황에서 메소드의 반환 타입으로
> Optional을 사용하자는 것이 Optional을 만든 주된 목적이다.
> Optional 타입의 변수의 값은 절대 null이어서는 안 되며, 항상 Optional 인스턴스를 가리켜야 한다.
> ```
>


## 요약

```java
public static <E extends Comparable<E>> Optional<E> max(Collection<E> c) {
    if (c.isEmpty())
        return Optional.empty();

    E result = null;
    for (E e : c)
        if (result == null || e.compareTo(result) > 0)
            result = Objects.requireNonNull(e);

    return Optional.of(result);
}
```

- 비어있는 Optional  : `Optional.empty()`
- Optional 생성 펙터리 :  `of()`  `ofNullable()`
- Optional 을 반환하는 메서드에서는 null 을 반환하면 안된다 (Optional 에 의도와 어긋남)
- 스트림의 max 함수는 반환타입이 optional 이므로 위의 예제는 이를 통해 구현해도 됨

## Optional 의 메서드

- `orElse()` : 기본 값 할당 - 값이 있어도 orElse 의 인자가 실행됨
- `orElseGet()` :  값이 없는 경우 기본 값 할당 - Supplier를 인자로 받아 값이 없는 경우에만 orElseGet 의 인자가 실행됨
- `orElseThrow()` : 예외 지정
- `get()` : optional 에 값이 없는데 값을 꺼내려고 하는 경우 `NoSuchElementException`  이므로 get 전에 검사 필수
- `filter` :  조건식에 맞지 않으면 비어있는 optional 을 반환함
- `ifPresent` : optional 값이 채워져 있으면 람다식 (consumer) 수행
- `isPresent()` : 옵셔널이 채워져 있으면 true, 비어있으면 false를 반환, 다른 메서드들로 대체 가능한 지 충분히 검토해보고 사용
- `map` : 옵셔널 값이 채워져 있으면 제공된 매핑 함수수행
- `flatmap` : 값이 존재하면 인수로 제공된 함수를 적용한 결과의 Optional 을 반환하고 값이 없으면 비어있는 Optional 을 반환

## Optional 활용

```java

// 기본값을 정해둘 수 있다
public static <E extends Comparable<E>>
Optional<E> max(Collection<E> c) {
    return c.stream().max(Comparator.naturalOrder());
}

String lastWordInLexicon = max(words).orElse("단어 없음...");


// 예외를 던질 수 있다 (예외 팩터리를 사용하여 실제로 발생하지 않는 한 예외 생성 비용이 들지 않는다)
Toy mytoy = max(toys).orElseThrow(TemperTantrumException::new);

// 항상 값이 채워져 있다고 가정한다
Element element = max(elements).get();

```

```java
public class ParentPid {
    public static void main(String[] args) {
        ProcessHandle ph = ProcessHandle.current();

        // isPresent를 적절치 못하게 사용했다.
        Optional<ProcessHandle> parentProcess = ph.parent();
        System.out.println("부모 PID: " + (parentProcess.isPresent() ?
                String.valueOf(parentProcess.get().pid()) : "N/A"));

        // 같은 기능을 Optional의 map를 이용해 개선한 코드
        System.out.println("부모 PID: " +
            ph.parent().map(h -> String.valueOf(h.pid())).orElse("N/A"));
    }
}
```
- Optional 의 특별한 메서드들을 통해 코드를 간결하게 만들 수 있다
- `isPresent` 는 신중히, 마지막에 사용하자. 상당수의 메서드들이 이를 대체할 수 있다
- 자바 9 부터는 Optional 에 Stream() 메서드가 추가되었다 



## Optional 을 사용하면 안되는 경우

- 컬렉션, 스트림, 배열, 옵셔널 같은 **컨테이너 타입**은 옵셔널로 감싸면 안된다
- 객체를 새로 할당하고, 값을 꺼내는 단계가 추가되므로 성능이 중요한 상황에는 Optional  맞지 않을 수 있다
- 컬렉션의 키 값 혹은 컬렉션이나 배열의 원소로 사용해서 좋은 경우는 거의 없음

## Optional 을 사용해도 좋은 경우

- Optional 은 검사 예외(Exception)와 취지가 비슷함
- 결과를 알 수 없으며, 클라이언트가 이를 특별하게 처리해야 하는 경우 Optional<T> 를 반환
- 기본 타입 전용 Optional `OptionalInt` `OptionalDouble` `OptionalLong` 활용할

## Optional 을 필드 값으로 사용해도 될까?

- Optional 은 기본적으로 반환 타입으로 고려되어 설계되었으므로 대부분의 경우 적합하지 않음
- 책에서는 기본 타입인 선택적 인자에 대한 표현으로 Optional 을 사용하면 좋을 것 같다고 제안하긴 함

참고자료

1. java.util.Optional 에 대한 26가지 주의사항 : https://dzone.com/articles/using-optional-correctly-is-not-optional
2. https://dev-coco.tistory.com/178