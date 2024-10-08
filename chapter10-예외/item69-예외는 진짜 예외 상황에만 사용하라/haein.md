## 요약

```java
try {
	int i = 0;
    while(true)
    	range[i++].climb();
} catch (ArrayIndexOutOfBoundsException e) {
}
```
- 무슨 일을 하는 코드인지 모르겠음 (직관적이지 않다)
- 배열을 순회하는 코드인데 잘못된 추론을 근거로 성능을 높여보려 한 것이다
- JVM 은 배열에 접근할 때마다 경계를 넘지 않는지 검사하는데, 일반적인 반복문도 경계에 도달하면 종료한다
- 중복을 생략하기 위해 이런 코드를 도입한 것인데 이는 세 가지 면에서 잘못됨
    1. 예외는 예외 상황에 쓸 용도로 설계되었으므로 JVM 구현자 입장에서는 명확한 검사만큼 빠르게 만들어야 할 동기가 약하다
    1. 코드를 try-catch 블록 안에 넣으면 JVM 이 적용할 수 있는 최적화가 제한된다
    1. 배열을 순회하는 표준 관용구는 앞서 지정한 중복 검사를 수행하지 않는다 JVM 이 알아서 최적화해 없애준다 


### 예외를 사용한 반복문?
- 코드를 헷갈리게 하고 성능 떨어트림
- 예외가 버그를 숨겨 디버깅을 어렵게 할 수도 있음 
- **예외는 그 이름이 말해주듯 오직 예외 상황에서만 써야 하고 절대로 일상적인 제어 흐름용으로 쓰여선 안 된다**
- 표준적이고 쉽게 이해되는 관용구를 사용하고, 성능 개선을 목적으로 과하게 머리를 쓴 기법은 자제할 

### 예외와 API
- 잘 설계된 API 는 클라이언트가 정상적인 제어 흐름에서 예외를 사용할 일이 없게 해야 한다
- 특정 상태에서만 호출하는 상태 의존적 메서드 + 상태 검사 메서드를 같이 제공 (`Iterator` 는 `next` 와 `hasNext` 가 각각
상태 의존적 메서드와 상태 검사 메서드)

```java
for (Iterator<Foo> i = collections.iterator(); i.hasNext(); ) {
	Foo foo = i.next();
}

// 상태 검사 메서드 덕분에 for 관용구를 사용할 수 있다
// for-each 문도 사실 내부적으로 hasNext() 사용한다
```

- 상태 검사 메서드 대신 올바르지 않은 상태일 때 빈 옵셔널 혹은 null 같은 특수한 값을 반환하는 방법도 있다
- 이를 선택하는 몇 가지 지침이 있다
    1. 외부 동기화 없이 여러 스레드가 동시에 접근할 수 있거나 외부 요인으로 상태가 변할 수 있다면 사용한다
    1. 성능이 중요한 상황에서 상태 검사 메서드가 상태 의존적 메서드의 작업 일부를 중복 수행한다면 사용한다
    1. 다른 모든 경우엔 상태 검사 메서드 방식이 조금 더 낫다 (가독성, 오류 발견이 쉬움)