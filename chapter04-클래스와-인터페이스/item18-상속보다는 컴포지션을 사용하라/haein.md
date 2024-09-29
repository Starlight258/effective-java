# 요약

---

### 상속은 캡슐화를 깨뜨린다.

- 상위 클래스가 어떻게 구현되느냐에 따라 하위 클래스 동작에 이상이 생길 수 있음
- 따라서, 상위 클래스 설계자는 확장을 충분히 고려하고 문서화도 제대로 해둬야 함
- **캡슐화를 깨뜨리는 상속 예시)** 
HashSet + 추가된 원소 개수를 알 수 있는 기능을 가진 `InstrumentedHashSet`

```java
package effectivejava.chapter4.item18;
import java.util.*;

// 코드 18-1 잘못된 예 - 상속을 잘못 사용했다! (114쪽)
public class InstrumentedHashSet<E> extends HashSet<E> {
    // 추가된 원소의 수
    private int addCount = 0;

    public InstrumentedHashSet() {
    }

    public InstrumentedHashSet(int initCap, float loadFactor) {
        super(initCap, loadFactor);
    }

    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }

    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }

    public int getAddCount() {
        return addCount;
    }

    public static void main(String[] args) {
        InstrumentedHashSet<String> s = new InstrumentedHashSet<>();
        s.addAll(List.of("틱", "탁탁", "펑"));
        System.out.println(s.getAddCount());
    }
}
```
    
- `HashSet.addAll()`이 `HashSet.add()`를 이용해 구현되어있으므로, 
    `addAll()` 호출 시 addCount가 두 배로 증가한다.

**상속 시 발생할 수 있는 문제**

- 하위 클래스에서 특정 메서드 재정의 시 항상 자기 사용 여부를 확인해야 한다.
    - **자기 사용:** 특정 메서드 안에서 또 다른 자신에 포함된 메서드를 호출하는 것
    - 상위 클래스 변경 영향이 하위 클래스에도 전파된다.
- 메서드 재정의 시 메서드를 수정하지 않고, 동작을 처음부터 구현할 수 있으나, 오류를 내거나 성능을 떨어뜨릴 수 있으며, 구현이 불가능할 수 있다.
    - private 필드를 써야 하는 메서드라면 구현이 불가능하다.
- 상위 클래스 변경 시 변경 사항을 확인하여 변경이 필요한 경우, 하위 클래스도 같이 변경되어야 한다.
- 예시) 보안 때문에 컬렉션에 추가된 모든 원소들이 특정 조건을 만족해야 하는 경우
    - 컬렉션을 상속하고 원소를 추가하는 모든 메서드를 재정의하여 특정 조건 유효성을 검사할 수 있음
    - 컬렉션에서 새로운 원소 추가 메서드가 만들어지는 경우, 허용되지 않은 원소를 추가할 수 있게 됨
    - 자바의 사례) HashTable, Vector
- 새로운 메서드를 추가하는 방법은 재정의하는 방법보다 안전하지만, 상위 클래스에 추가된 메서드와 시그니처가 같은 경우가 생길 수 있다.
    - 시그니처가 같고 반환 타입이 다르면 클래스 컴파일조차 되지 않음
    - 반환 타입마저 같다면 메서드를 재정의한 것이 됨
    - 상위 클래스 메서드가 요구하는 규약을 만족하지 못하여 해당 메서드를 사용하는 다른 메서드가 생길 경우, 오류가 발생할 수 있음

### 상속의 대안: 컴포지션(composition)

**컴포지션:** 클래스를 상속하지 않고, 해당 클래스를 필드로 가지는 새로운 클래스 구성요소로 사용하는 것

**구현 방식**

```java
public class InstrumentedSet<E> extends ForwardingSet<E> {
    private int addCount = 0;

    public InstrumentedSet(Set<E> s) {
        super(s);
    }

    @Override public boolean add(E e) {
        addCount++;
        return super.add(e);
    }
    @Override public boolean addAll(Collection<? extends E> c) {
        addCount += c.size();
        return super.addAll(c);
    }
    public int getAddCount() {
        return addCount;
    }

    public static void main(String[] args) {
        InstrumentedSet<String> s = new InstrumentedSet<>(new HashSet<>());
        s.addAll(List.of("틱", "탁탁", "펑"));
        System.out.println(s.getAddCount());
    }
}


public class ForwardingSet<E> implements Set<E> {
    private final Set<E> s;
    public ForwardingSet(Set<E> s) { this.s = s; }

    public void clear()               { s.clear();            }
    public boolean contains(Object o) { return s.contains(o); }
    public boolean isEmpty()          { return s.isEmpty();   }
    public int size()                 { return s.size();      }
    public Iterator<E> iterator()     { return s.iterator();  }
    public boolean add(E e)           { return s.add(e);      }
    public boolean remove(Object o)   { return s.remove(o);   }
    public boolean containsAll(Collection<?> c)
                                   { return s.containsAll(c); }
    public boolean addAll(Collection<? extends E> c)
                                   { return s.addAll(c);      }
    public boolean removeAll(Collection<?> c)
                                   { return s.removeAll(c);   }
    public boolean retainAll(Collection<?> c)
                                   { return s.retainAll(c);   }
    public Object[] toArray()          { return s.toArray();  }
    public <T> T[] toArray(T[] a)      { return s.toArray(a); }
    @Override public boolean equals(Object o)
                                       { return s.equals(o);  }
    @Override public int hashCode()    { return s.hashCode(); }
    @Override public String toString() { return s.toString(); }
}
```

- 새로운 클래스를 만들고, private 필드로 기존 클래스 인스턴스를 참조
- forwarding 방식으로 메서드(forwarding method)를 구현
    - **forwarding:** 기존 클래스의 메서드를 새 클래스 인스턴스 메서드에서 호출하여 결과를 반환하는 방식
    - `add()`와 `addAll()` 구현이 상속을 사용한 `InstrumentedHashSet`과 똑같지만, 잘 동작한다.
    - Set 인스턴스를 감싸고 있다는 면에서 `InstrumentedHashSet`와 같은 클래스를 래퍼 클래스라고 부름
    - Set에 계측 기능을 덧씌운다는 면에서 데코레이터 패턴을 적용했다라고 말할 수 있음

**장점**

- 새로운 클래스를 만들었으므로, 기존 클래스의 내부 구현 방식에서 벗어난다.
- 기존 클래스에 새로운 메서드가 추가되더라도 전혀 영향 받지 않는다.
- 상속 방식은 구체 클래스 각각을 따로 확장해야 하며, 지원하고 싶은 상위 클래스 생성자에 대응하는 생성자를 별도로 정의해줘야 하지만, 컴포지션은 한 번 구현만 해두면 기존 생성자들과도 함께  사용할 수 있고, 어떠한 Set 구현체도 계측할 수 있다.

**단점**

- 콜백 프레임워크와는 어울리지 않는다.
    - **self 문제**가 발생할 수 있음
        - 콜백 프레임워크는 자기 자신의 참조를 다른 객체에 넘겨 다음 호출 때 사용하는데,
        내부 객체는 자신을 감싸고 있는 래퍼의 존재를 모르므로 래퍼가 아닌 자신의 참조를 넘겨 콜백 때는 래퍼가 아닌 내부 객체를 호출하게 된다.

**상속 사용 시 고려할 사항**

- 상속은 하위 클래스가 상위 클래스의 ‘진짜’ 하위 타입인 상황에서만 쓰여야 한다.
    - B is-a A인 경우에만, B가 A를 상속해야 함
        - 그렇지 않다면, **A는 B의 필수 구성요소가 아니라 구현하는 방법 중 하나인 것**
- 상위 클래스가 확장을 고려해 설계되었는지
- 확장하려는 클래스의 API에 결함이 없는지
    - 결함이 있다면, 우리가 정의한 API까지 전파돼도 괜찮은지

**상속을 잘못 사용한 사례**

자바 라이브러리의 `Stack`

- `Stack`은 벡터가 아니므로, `Vector`를 확장하면 안됐음

`java.util.Properties`

- `Properties`도 해시 테이블이 아니므로, `HashTable`을 확장하면 안됐음
    - `Properties`의 인스턴스 p의 `p.getProperty(key)`와 `p.get(key)`는 결과가 다를 수 있음
        - 전자는 `Properties`의 기본 동작이나, 후자는 `HashTable`에게 물려받은 메서드
    - Properties는 키와 값으로 문자열만을 허용하도록 설계하려 하였으나, HashTable의 메서드를 직접 호출하면 불변식을 깨버릴 수 있음
        - 이후 바로잡으려 하였으나 이미 사용자들이 문자열 이외 타입을 사용하고 있어 해결할 수 없었음

**참고**

- 컴포지션과 조합은 넓은 의미로 위임(delegation)이라고 부름
    - 엄밀히 말하면, 래퍼 객체가 내부 객체에 자기 자신의 참조를 넘기는 경우만 해당
- 전달 메서드가 성능에 주는 영향이나, 래퍼 객체가 메모리 사용량에 주는 영향을 걱정할 수 있지만, 실전에서는 둘다 별다른 영향이 없다고 밝혀짐




## ⭐️ **번외: 추가 조각 지식**

### Vector를 상속한 Stack 관련 문제점

https://uknowblog.tistory.com/342

- Vector는 원하는 위치에 원소를 삽입할 수 있는 add() 메서드가 존재
- Stack은 push, pop만을 지원해야 하나, Vector.add()를 사용하여 원하는 위치에 원소를 삽입할 수 있음

```java
@Test
    void push와_pop연산만_존재하는_stack에_임의원소를_삽입할수있다(){
        //given
        Stack<String> stack = new Stack<>();
        stack.push("first");
        stack.push("second");
        stack.push("third");
        //when
        stack.add(1, "fourth");
        //then
        System.out.println(stack.pop());
        System.out.println(stack.pop());
        System.out.println(stack.pop());
        System.out.println(stack.pop());
        /**
         * third
         * second
         * fourth
         * first
         */
    }
```

