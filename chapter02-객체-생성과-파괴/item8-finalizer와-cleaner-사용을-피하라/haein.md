## ✍️ 개념의 배경

자바에는 객체 소멸자인 `finalizer`와 `cleaner`가 있다.

finalizer: Object의 finalize()를 의미

- 예측할 수 없고, 상황에 따라 위험할 수 있어 일반적으로 불필요
- 자바9에서 deprecated API로 지정

cleaner: api

- finalizer보다는 덜하지만 여전히 예측할 수 없고 느리고 일반적으로 불필요

# 요약

---

## finalizer와 cleaner를 사용하면 안되는 이유

> **finalizer, cleaner가 즉시 수행된다는 보장이 없다.**
> 
- 따라서 제때 실행되어야 하는 작업을 할 수 없음
    - ex) 파일 닫기: 시스템이 동시에 열 수 있는 파일 개수에 한계가 있으므로 오류가 날 수 있음
- 실행 시점이 가비지 컬렉터 알고리즘에 의존함
- finalizer 스레드의 실행 우선순위가 낮을 때, 회수해야 하는 객체의 크기가 크고 많은 경우 OOM이 발생할 수 있음
    - cleaner는 수행할 스레드를 제어할 수 있어 조금 낫다.

> **finalizer, cleaner가 수행된다는 보장이 없다.**
> 
- 따라서 상태를 영구적으로 수정하는 작업(lock 회수 등)에서 절대 사용하면 안됨

> **finalizer 동작 중 발생한 예외는 무시되며, 처리할 작업이 남았어도 종료되므로 객체가 훼손된 상태가 될 수 있다.**
> 
- 보통의 경우, 예외가 스레드를 중단시키지만 예외가 무시되므로 예외를 통해 무슨 일이 발생했는지 확인할 수 없다.
- cleaner는 스레드를 통제할 수 있으므로 괜찮다.

> **finalizer, cleaner 사용 시 심각한 성능 문제 발생할 수 있다.**
> 
- 가비지 컬렉터의 효율을 떨어뜨림
- cleaner의 안전망 방식을 사용하는 경우 빨라지긴 하나, 그래도 느림

> **finalizer 공격을 발생시킬 수 있다.**
> 
- **finalizer 공격:** final 클래스가 아닌 생성자나 직렬화 과정에서 예외 발생 시 악의적인 하위 클래스의 finalizer가 수행될 수 있는 공격
- 방어하려면 아무 일도 하지 않는 `finalize` 메서드를 final로 선언하면 된다.

## finalizer, cleaner 대안

> AutoClosable을 구현하고 `close()`를 호출한다.
> 
- `close() 시`에서 객체가 더 이상 유효하지 않다고 필드에 기록하고, 다른 메서드가 해당 객체를 호출하면 `IllegalStateException`으로 프로그래머에게 알리는 것이 좋다.
- `try-with-resources`를 사용하자

## 사용해도 괜찮은 경우

> **자원의 close()를 호출하지 않는 것에 대비한 안전망**


- 이 때 state가 Room을 참조한다면 순환 참조가 생겨 Room 인스턴스가 절대 회수되지 않는다.
- `System.exit`가 호출되더라도 `cleaner`의 동작은 보장되지 않는다.

> **네이티브 피어와 연결된 객체**
> 
- 네이티브 피어: 일반 자바 객체가 네이티브 메서드를 통해 기능을 위임한 네이티브 객체
    - 네이티브 피어는 자바 객체가 아니므로 GC로 메모리를 관리할 수 없다.

## 개념 관련 경험


## 이해되지 않았던 부분

### Finalizer Attack

> 역직렬화시 readResolve 메서드가 실행되고 얘가 새로운 인스턴스를 반환해. 만약 누군가 A 클래스의 하위 클래스인 B를 구현하고 A 객체를 필드로 가지고 있다고 할게. 그리고 명시적으로 구현한 readResolve 가 RuntimeException 을 던지도록 하고 finalize 를 오버로딩해서 악의적인 로직을 담고 A객체 필드에 자기자신을 할당해서 직렬화해서 누군가한테 줘.
그러면 역직렬화 과정에서 RuntimeException 이 발생할거야. 그리고 정상적인 경우라면 역직렬화 과정에서 객체는 생성되다 말았기 때문에 gc 수행 시 finalize 가 수행되고 메모리는 수거되어야 하지만 이 객체의 finalize 가 수행되면서 악의적인 코드가 수행되고 심지어 필드에 자기자신을 할당했기 때문에 수거도 안돼. 결국 이 객체는 악의적인 로직을 내포한채로 수거도안되고 계속 살아있는거야.
> 

https://github.com/Java-Bom/ReadingRecord/issues/7

## ⭐️ **번외: 추가 조각 지식**

### 소멸자란?

> The [Object](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/Object.html) class provides the [*finalize()*](https://www.baeldung.com/java-finalize) method. Before the garbage collector removes an object from memory, it’ll call the *finalize()* method. The method can run zero or one time. However, it cannot run twice for the same object.

Object 클래스는 finalize() 메서드를 제공합니다. **가비지 콜렉터가 메모리에서 객체를 제거하기 전에 finalize() 메서드를 호출**합니다. 이 메서드는 0번 또는 한 번 실행될 수 있습니다. 그러나 동일한 객체에 대해 두 번 실행할 수는 없습니다.
> 

https://www.baeldung.com/java-destructor
