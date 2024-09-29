## ✍️ 개념의 배경

재정의 가능한 메서드 : final 이 아닌 접근제어자가 public, protected 로 설정된 메서드

# 요약

---

### 상속을 고려한 문서화

- **상속용 클래스는 재정의할 수 있는 메서드들을 내부적으로 어떻게 이용하는지 문서로 남겨야 한다.**
    - 재정의할 수 있는 메서드를 호출하는 메서드는 이를 API 문서에 적시해야 함.
        - 어떤 순서로 호출하는 지
        - 호출 결과들이 이어지는 처리에 어떻게 영향을 주는 지
    - 더 넓게 얘기하면, 재정의 가능 메서드를 호출할 수 있는 모든 상황을 문서화해야 한다.
    - 클래스를 안전하게 상속하기 위해, (상속은 캡슐화를 위배함) 내부 구현을 드러내는 것이다.
- Implementation Requirements
    - 메서드의 내부 동작방식을 설명할 때  사용하는 주석.
    - @implSpec 태그를 통해 선택적으로 생성할 수 있음.

java.util.AbstractCollection 의 remove 메서드 예시 ([https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/AbstractCollection.html#remove(java.lang.Object)](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/util/AbstractCollection.html#remove(java.lang.Object)))

> **Implementation Requirements:**
> 
> 
> This implementation iterates over the collection looking for the specified element. If it finds the element, it removes the element from the collection using the iterator's remove method.Note that this implementation throws an `UnsupportedOperationException` if the iterator returned by this collection's iterator method does not implement the `remove` method and this collection contains the specified object.
> 
- Iterator의 메서드를 재정의하면 remove 에 영향을 준다는 것을 설명한다.
- Iterator의 메서드를 통해 얻은 반복자의 동작이 remove 메서드에 영향을 주는 부분을 정확히 설명하고 있다.

---

### 상속을 고려한 설계

- **효율적인 하위 클래스를 어려움 없이 만들 수 있게 하기 위해 클래스의 내부 동작 과정 중간에 끼어들 수 있는 훅(hook)을 잘 선별하여 
protected 메서드 형태로 공개해야 할 수도 있다.**

`java.util.AbstractList`의 `removeRange` 메서드 예시 

(https://docs.oracle.com/javase/8/docs/api/java/util/AbstractList.html#removeRange-int-int-)

> **protected void removeRange(int fromIndex, 
int toIndex)**

Removes from this list all of the elements whose index is between `fromIndex`, inclusive, and `toIndex`, exclusive. Shifts any succeeding elements to the left (reduces their index). This call shortens the list by `(toIndex - fromIndex)` elements. (If `toIndex==fromIndex`, this operation has no effect.)

This method is called by the `clear` operation on this list and its subLists. Overriding this method to take advantage of the internals of the list implementation can *substantially* improve the performance of the `clear` operation on this list and its subLists.
> 
> 
> This implementation gets a list iterator positioned before `fromIndex`, and repeatedly calls `ListIterator.next` followed by `ListIterator.remove` until the entire range has been removed. 
> 
> **Note: if `ListIterator.remove` requires linear time, this implementation requires quadratic time.**
> 
- 이 메서드를 제공하는 이유는 단지 하위 클래스에서 clear 메서드의 성능을 고성능으로 만들기 위함이다.
- 어떤 메서드를 protected 로 하여 노출해야 하는 지는, 실제 하위 클래스를 만들어 시험해 보는 것이 최선의 방법이다.
    - protected 메서드 하나하나가 내부 구현에 해당하므로 그 수는 가능한 적어야 한다.
    - 한편으로 너무 적게 노출해서 상속으로 얻는 이점마저 없애지 않도록 주의해야 한다.
    - 하위 클래스를 여러 개 만들 때까지 전혀 쓰이지 않은 protected 멤버는 사실 `private`이었어야 할 가능성이 크다.

---

### 상속을 위한 클래스를 위한 몇 가지 주의사항

- **상속용 클래스의 생성자는 직접적으로든 간접적으로든 재정의 가능 메소드를 호출해서는 안 된다.**

```java
public class Super {
    public Super() {
        overrideMe();
    }

    public void overrideMe() {
    }
}
```

```java
public final class Sub extends Super {
    
    private final Instant instant;

    Sub() {
        instant = Instant.now();
    }

    @Override public void overrideMe() {
        System.out.println(instant);
    }

    public static void main(String[] args) {
        Sub sub = new Sub();
        sub.overrideMe();
    }
}
```

- 하위 클래스의 객체를 생성할 때, 상위 클래스의 생성자가 먼저 호출됨.
- 하위 클래스에서 재정의한 메서드가 하위 클래스의 생성자보다 먼저 호출됨.
- 따라서 위의 코드는 첫 번째 출력에서  null 을 반환함.

- Cloneable 의 clone  → 객체가 복사되기 전에 재정의된 메서드가 호출되면 안됨(원본도 피해를 입을 수 있음).
- Serializable 의 readObject →  역직렬화 이전에 재정의된 메서드가 호출되면 안됨.

### 상속하지 않는 클래스

- **상속용으로 설계하지 않은 클래스는 상속을 금지한다.**
    - final 키워드를 사용한다.
    - 모든 생성자를 private 로 선언하고, 정적 팩터리 메서드를 구현한다.
    - 표준 인터페이스를 구현한 구체 클래스인 경우 래퍼 클래스 패턴 등을 이용하여 상속의 대안으로 사용할 수 있다.
- 표준 인터페이스를 구현하지 않았는데 상속을 금지하면 사용하기 불편해진다.
    - 이런 경우,  클래스 내부에서는 재정의 가능 메서드를 사용하지않게 만들고 이 사실을 문서로 남기는 것이다.
    - 재정의 가능 메서드의 코드를 private helper 메서드로 옮기고 이 메서드를 호출하도록 하면 이를 구현할 수 있다.

