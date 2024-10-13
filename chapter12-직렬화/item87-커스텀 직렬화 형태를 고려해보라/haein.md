##  요약

### 기본 직렬화의 문제
- 다음 릴리스 때 수정하려고 한 현재의 구현에 영원히 발이 묶이게 된다(`BigInteger`)
- 먼저 고민해보고 괜찮다고 판단될 때만 기본 직렬화 형태를 사용해라

### 객체의 물리적 표현과 논리적 내용이 같다면 기본 직렬화 형태라도 무방하다
- 기본 직렬화 형태는 그 객체를 루트로 하는 객체 그래프의 물리적 형태를 나름 효율적으로 인코딩한다
    - 객체가 포함한 데이터들과 그 객체에서부터 시작해 접근할 수 있는 모든 객체를 담아낸다
    - 객체들이 연결된 위상(topology) 까지 기술한다 
    - 이상적인 직렬화 형태는 물리적인 모습과 독립된 논리적인 모습만을 표현해야 한다 
```java
public class Name implements Serializable {
    /**
     * 성. null이 아니어야 함.
     * @serial
     */
    private final Stirng lastName;

    /**
     * 이름. null이 아니어야 함.
     * @serial
     */
    private final String firstName;

    /**
     * 중간이름. 중간이름이 없다면 null.
     * @serial
     */
    private final String middleName;

    ... // 나머지 코드는 생략
}
```
- 성명은 논리적으로 이름, 성, 중간이름이라는 3개의 문자열로 구성되며, 코드의 인스턴스 필드들은 이 논리적인 구성요소를 정확히 반영했다
- 기본 직렬화 형태가 적합해도 불변식 보장과 보안을 위해 `readObject` 메서드를 제공해야 할 때가 많다 
- `Name` 의 `private` 필드도 직렬화 형태에 포함되므로 문서화 주석이 달려 있음에 주목하자 

```java
public final class StringList implements Serializable {
    private int size = 0;
    private Entry head = null;

    private static class Entry implements Serializable {
        String data;
        Entry next;
        Entry previous;
    }

    ... // 나머지 코드는 생략
}
```
- 문자열 리스트를 구현한 클래스는 논리적으로 일련의 문자열을 표현한다
- 물리적으로는 문자열들을 이중 연결 리스트로 표현했다
    - 기본 직렬화 형태를 사용하면 각 노드의 양방향 연결 정보를 포함해 모든 Entry 를 철두철미하게 기록한다
    (논리적인 표현과 직렬화 형태가 담는 데이터의 차이가 큼)

### 객체의 물리적 표현과 논리적 표현의 차이가 클 때 기본 직렬화 형태를 사용하면 크게 네 가지 면에서 문제가 생긴다
1. 공개 API가 현재의 내부 표현 방식에 종속적이게 된다
1. 너무 많은 공간을 차지할 수 있다
1. 시간이 많이 걸린다
1. 스택 오버플로우를 발생시킨다


### StringList 의 합리적인 직렬화 형태

```java
public final class StringList implements Serializable {
    private transient int size = 0;
    private transient Entry head = null;

    // 이번에는 직렬화 하지 않는다.
    private static class Entry {
        String data;
        Entry next;
        Entry previous;
    }

    // 지정한 문자열을 리스트에 추가한다.
    public final void add(String s) { ... }

    /**
     * StringList 인스턴스를 직렬화한다.
     */
    private void writeObject(ObjectOutputStream stream)
            throws IOException {
        stream.defaultWriteObject(); // 반드시!
        stream.writeInt(size);

        // 모든 원소를 순서대로 기록한다.
        for (Entry e = head; e != null; e = e.next) {
            s.writeObject(e.data);
        }
    }

    private void readObject(ObjectInputStream stream)
            throws IOException, ClassNotFoundException {
        stream.defaultReadObject(); // 반드시!!
        int numElements = stream.readInt();

        for (int i = 0; i < numElements; i++) {
            add((String) stream.readObject());
        }
    }
    ... // 나머지 코드는 생략
}
```
- 합리적인 직렬화 형태는 단순히 리스트가 포함한 문자열의 개수를 적은 다음, 그 뒤로 문자열들을 나열하는 수준이면 될 것이다
- `transient` 키워드가 붙은 필드는 직렬화 형태에 포함되지 않는다
- 커스텀 직렬화 형태 (`writeObject`, `readObject` 재정의) 를 만들어 직렬화 형태를 처리하자
- 버전 간 호환을 위해 `defaultWriteObject`와 `defaultReadObject` 메서드를 호출

### `transient` 키워드를 사용한 필드
- 기본 직렬화 여부에 관계없이 `defaultWriteObject` 메서드를 호출하면 `transient`로 선언하지 않은 모든 필드는 직렬화된다
- 논리적 상태와 무관한 필드라고 판단될 때만 `transient` 한정자를 생략해야 한다
- 기본 직렬화를 사용한다면 역직렬화할 때 `transient` 필드는 기본값으로 초기화된다
- 기본값을 변경해야 하는 경우에는 `readObject` 메서드에서 `defaultReadObject` 메서드를 호출한 다음 원하는 값으로 복원하자
- 아니면 그 값을 처음 사용할 때 초기화해도 된다


### 기본 직렬화 여부와 상관없이 객체의 전체 상태를 읽는 메서드에 적용해야 하는 동기화 메커니즘을 직렬화에도 적용해야 한다

```java
private synchronized void writeObject(ObjectOutputStream stream)
        throws IOException {
    stream.defaultWriteObject();
}
```
- `writeObject` 내부에서 동기화하고 싶다면 다른 부분에서 사용하는 락 순서를 똑같이 따라야 한다

### 직렬화 가능 클래스 모두에 직렬 버전 UID 를 명시적으로 부여하자
- 직렬 버전 UID가 일으키는 잠재적 호환성 문제가 사라진다
