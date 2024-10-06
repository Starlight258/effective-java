## 지연 초기화
- 필드 초기화 시점을 그 값이 처음 필요할 때까지 늦추는 기법
- 값이 전혀 쓰이지 않으면 초기화도 일어나지 않는다
- 정적 필드와 인스턴스 필드 모두에 사용할 수 있다
- 최적화 용도로 주로 쓰이지만, 클래스와 인스턴스 초기화 때 발생하는 위험한 순환 문제를 해결하는 효과도 있다

## 요약

### 대부분의 상황에서 일반적인 초기화가 지연 초기화보다 낫다
- 지연 초기화는 양날의 검이다
    - 생성 시 초기화 비용은 줄지만 지연 초기화하는 필드에 접근하는 비용은 커진다
    - 인스턴스가 어떤 필드를 사용하는 비율이 낮은 것 대비 필드를 초기화하는 비용이 커야 지연 초기화가 역할을 해줄 것이다
    - 멀티스레드 환경에서는 어떤 형태로든 필드를 동기화해야한다 



```java
    // 코드 83-1 인스턴스 필드를 초기화하는 일반적인 방법 (443쪽)
    private final FieldType field1 = computeFieldValue();
```

```java
    // 코드 83-2 인스턴스 필드의 지연 초기화 - synchronized 접근자 방식 (443쪽)
    private FieldType field2;
    private synchronized FieldType getField2() {
        if (field2 == null)
            field2 = computeFieldValue();
        return field2;
    }
```
- 지연 초기화가 초기화 순환성을 깨드릴 것 같으면 `synchronized` 키워드를 사용

### 성능 때문에 정적 필드를 지연 초기화해야 한다면 지연 초기화 홀더 클래스 관용구를 사용하자

```java
    // 코드 83-3 정적 필드용 지연 초기화 홀더 클래스 관용구 (443쪽)
    private static class FieldHolder {
        static final FieldType field = computeFieldValue();
    }

    private static FieldType getField() { return FieldHolder.field; }
```
- 클래스는 클래스가 처음 쓰일 때 해당 클래스를 초기화하는 것을 이용한다
- `getField` 가 처음 호출될 때 클래스 초기화가 일어난다
- 동기화가 전혀 일어나지 않으니 성능이 느려질 이유가 없다 


### 성능 때문에 인스턴스 필드를 지연 초기화해야 한다면 이중검사 관용구를 사용해라

```java
    // 코드 83-4 인스턴스 필드 지연 초기화용 이중검사 관용구 (444쪽)
    private volatile FieldType field4;

    private FieldType getField4() {
        FieldType result = field4;
        if (result != null)    // 첫 번째 검사 (락 사용 안 함)
            return result;

        synchronized(this) {
            if (field4 == null) // 두 번째 검사 (락 사용)
                field4 = computeFieldValue();
            return field4;
        }
    }
```
- 이 코드에서 `result` 변수는 필드가 이미 초기화된 상황에서는 그 필드를 딱 한번만 읽도록 보장한다 
- 반복해서 초기화해도 상관없는 인스턴스 필드를 지연 초기화해야하는 상황에는 이 관용구의 변종으로
두 번째 검사를 생략할 수 있다

```java
    private volatile FieldType field5;

    private FieldType getField5() {
        FieldType result = field5;
        if (result == null)
            field5 = result = computeFieldValue();
        return result;
    }

    private static FieldType computeFieldValue() {
        return new FieldType();
    }
```

- 모든 스레드가 필드의 값을 다시 계산해도 상관없고 필드의 타입이 `long` 과 `double` 을 제외한 다른 기본 타입이라면 단일검사의 필드 선언에서 `volatile` 키워드를 없애도 된다 (짜릿한 단일검사)