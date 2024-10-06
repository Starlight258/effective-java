# 83. 지연 초기화는 신중히 사용하라
## 지연 초기화
- 필드의 초기화 시점을 그 값이 처음 필요할 때까지 늦추는 기법
    - 값이 전혀 쓰이지 않으면 초기화도 결코 일어나지 않는다.
- 정적 필드와 인스턴스 필드 모두에 사용할 수 있다.
- 주로 최적화 용도로 쓰이지만, 클래스와 인스턴스 초기화 때 발생하는 **위험한 순환 문제**를 해결하는 효과도 있다.
    - 순환 참조 문제 : 두 개 이상의 클래스나 인스턴스가 서로를 참조하면서 초기화되는 상황

### 필요할 때까지는 지연 초기화를 하지 말라
- **지연 초기화는 양날의 검이다.**
    - 클래스 혹은 인스턴스 생성 시의 초기화 비용은 줄어든다.
    - 지연 초기화하는 필드에 접근하는 비용은 커진다.
        - 지연 초기화에 드는 비용에 따라, 초기화된 각 필드를 얼마나 빈번히 호출하느냐에 따라 지연초기화가 실제로 성능을 느려지게 할 수도 있다.
    - 불필요한 최적화를 피하라.
        - 실제로 성능 문제가 발생하고, 지연 초기화가 해결책이 될 수 있다고 판단될 때만 지연 초기화를 수행하라.

#### 대부분의 상황에서 일반적인 초기화가 지연 초기화보다 낫다.
```java
private final FieldType field = computeFieldValue();
```

#### 지연 초기화가 초기화 순환성을 깨뜨릴 것 같으면 `synchronized`를 단 접근자를 사용하자.
- 순환 참조
```java
class A {
    private B b = new B();
}

class B {
    private A a = new A();
}
```
- `synchronized`를 단 접근자
    - 여러 스레드가 동시에 초기화되지 않은 객체에 접근하는 것을 막는다.
```java
class A {
    private B b;
    
    public synchronized B getB() {
        if (b == null) {
            b = new B();
        }
        return b;
    }
}

class B {
    private A a;
    
    public synchronized A getA() {
        if (a == null) {
            a = new A();
        }
        return a;
    }
}
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

#### 성능 때문에 `정적 필드`를 지연 초기화해야 한다면 `지연 초기화 홀더 클래스` 관용구를 사용하자.
- 내부 정적 클래스를 사용한다.
- 동기화를 하지 않으므로 성능을 걱정하지 않아도 된다.
    - 클래스 초기화는 JVM에 의해 동기화된다.
    - getField() 가 호출되기 전까지 클래스는 초기화되지 않는다. (호출시 JVM에 의해 인스턴스 생성)
```java
// 코드 83-3 정적 필드용 지연 초기화 홀더 클래스 관용구 (443쪽)  
private static class FieldHolder {  
    static final FieldType field = computeFieldValue();  
}  
  
private static FieldType getField() { return FieldHolder.field; }
```

#### 성능 때문에 인스턴스 필드를 지연 초기화해야 한다면 **이중검사 관용구**를 사용하라
- 초기화된 필드에 접근할 때의 동기화 비용을 없애준다.
- 한번은 **동기화 없이 검사**하고, 두번째는 **동기화하여 검사**한다.
    - 두번째 검사에서도 필드가 초기화되지 않았을 때만 필드를 초기화한다.
- 필드가 초기화된 후로는 동기화하지 않으므로 해당 필드는 반드시 `volatile`로 선언해야 한다.
- 초기화 후에는 동기화 오버헤드가 없다.
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

#### 반복해서 초기화해도 상관없는 인스턴스 필드를 지연 초기화할 경우 두번째 검사를 생략할 수 있다.
- 여러 스레드가 동시에 초기화를 수행하는 것을 허용한다.
```java
// 코드 83-5 단일검사 관용구 - 초기화가 중복해서 일어날 수 있다! (445쪽)  
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
- 이중 검사와 단일검사 관용구를 수치 기본 타입 필드에 적용한다면 필드의 값을 null 대신 0과 비교하면 된다.
- **짜릿한 단일검사 관용구** : 모든 스레드가 **필드의 값을 다시 계산**해도 상관없고 필드의 타입이 **long과 double을 제외한 다른 기본 타입**이라면, 단일검사의 필드 선언에서 `volatile` 한정자를 없애도 된다.
    - `volatile` 필드에 대한 읽기/쓰기 연산은 일반 필드보다 비용이 더 크다.
    - long과 double을 제외한 기본 타입(int, boolean, byte 등)의 읽기/쓰기는 원자적이다.
    - 어떤 환경에서는 필드 접근 속도를 높여주지만, 초기화가 스레드당 최대 한 번 더 이뤄질 수 있다.
    - 보통은 거의 쓰지 않는다.

### 지연 초기화가 필요한 경우
- 해당 클래스의 인스턴스 중 그 필드를 사용하는 인스턴스의 비율이 낮은 반면, 그 필들르 초기화하는 비용이 큰 경우
    - 지연 초기화 적용 전 후의 성능을 측정해봄으로써 알 수 있다.

### 멀티스레드 환경에서는 지연 초기화를 하기 까다롭다
- 지연 초기화하는 필드를 둘 이상의 스레드가 공유한다면 어떤 형태로든 반드시 동기화해야 한다.

# 결론
- 대부분의 필드는 지연시키지 말고 **곧바로 초기화**해야 한다.
- 성능 때문에 혹은 위험한 초기화 순환을 막기 위해 꼭 지연 초기화를 써야 한다면 **올바른 지연 초기화 기법**을 사용하자.
    - 인스턴스 필드에는 `이중검사 관용구`를, 정적 필드에는 `지연 초기화 홀더 클래스 관용구`를 사용하자.
    - 반복해 초기화해도 괜찮은 인스턴스 필드에는 `단일검사 관용구`도 고려하자.

