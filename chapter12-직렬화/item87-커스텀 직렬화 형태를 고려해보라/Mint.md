# 87.  커스텀 직렬화 형태를 고려해보라
## 기본 직렬화 형태
- 먼저 고민해보고 괜찮다고 판단될 때만 기본 직렬화 형태를 사용하라
    - 직접 설계하더라도 기본 직렬화 형태와 거의 같은 결과가 나올 경우에만 기본 형태를 써야 한다.
- 기본 직렬화 형태는 그 객체를 루트로 하는 객체 그래프의 물리적 모습을 인코딩한다.
    - 객체가 포함한 데이터들과 그 객체에서부터 시작해 접근할 수 있는 모든 객체를 담아내며, 이 객체들이 연결된 위상(topology)까지 기술한다.
- 이상적인 직렬화 형태라면 물리적인 모습과 독립된 **논리적인 모습만을 표현**해야 한다.
    - 객체의 물리적 표현과 논리적 내용이 같다면 기본 직렬화 형태라도 무방하다.
> 참고)
> 물리적 표현: 객체가 메모리에 어떻게 저장되는지
> 논리적 표현: 객체가 개념적으로 어떤 데이터를 표현하는지

### 기본 직렬화 형태에 적합한 후보
```java
public class Name implements Serializable {  
    private static final long serialVersionUID = 1L;  
    /**  
     * The first name of the person. Must be non-null.         
     * @serial  
     */  
    private final String firstName;  
    /**  
     * The last name of the person. Must be non-null.          
     * @serial  
     */  
    private final String lastName;  
    /**  
     * The middle name of the person, or null if there is none.          
     * @serial  
     */  
    private final String middleName;
```
- `private` 필드이더라도 문서화 주석이 달려있는 이유는, 이 필드들은 결국 클래스의 직렬화 형태에 포함되는 공개 API이기 때문이다.

#### 기본 직렬화 형태가 적합하다고 결정했더라도, 불변식 보장과 보안을 위해 `readObject` 메서드를 제공해야 할 때가 많다.
- 객체가 역직렬화될 때, 생성자를 거치지 않고 직접 객체의 상태가 복원된다.
    - 이 과정에서 클래스의 불변식(invariant)이 깨질 수 있다.
- `readObject`
    - 역직렬화 과정을 커스터마이즈할 수 있다.
    - 객체의 상태를 검증하고 필요한 경우 조정할 수 있다.
```java
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {
    s.defaultReadObject();

    // 불변식 검사
    if (start.compareTo(end) > 0)
        throw new InvalidObjectException(start + " after " + end);

    // 방어적 복사
    start = new Date(start.getTime());
    end = new Date(end.getTime());
}
```

### 직렬화 형태에 적합하지 않은 예
```java
// 코드 87-3 합리적인 커스텀 직렬화 형태를 갖춘 StringList (462-463쪽)  
public final class StringList implements Serializable {  
    private int size   = 0;  
    private Entry head = null;  
  
    private static class Entry implements Serializable {  
        String data;  
        Entry  next;  
        Entry  previous;  
    }  
}
```
- 위 클래스에 기본 직렬화 형태를 사용하면 각 노드의 양방향 연결 정보를 포함해 모든 엔트리를 기록한다.

#### 객체의 물리적 표현과 논리적 표현의 차이가 클 때, 기본 직렬화 형태를 사용하면 문제가 생긴다.
- 1. **공개 API가 현재의 내부 표현 방식에 영구히 묶인다.**
    - 다음 릴리스에서 내부 표현 방식을 바꾸더라도 기존 코드를 제거할 수 없다.
- 2. **너무 많은 공간을 차지할 수 있다.**
    - 연결 리스트의 모든 엔트리와 연결 정보까지 기록할 필요가 없다.
- 3. **시간이 너무 많이 걸릴 수 있다.**
    - 직렬화 로직은 객체 그래프의 위상정보가 없으므로 그래프로 직접 순회해볼 수 밖에 없다.
    - 간단히 다음 참조를 따라 가보는 정도로 충분하다.
- 4. **스택 오버플로를 일으킬 수 있다.**
    - 기본 직렬화 과정은 객체 그래프를 재귀 순회하는데, 이 작업은 스택 오버플로를 일으킬 수 있다.

### 합리적인 직렬화 형태를 만드는 방법
- 물리적인 상세 표현은 배제한 채 논리적인 구성만 담는다.
- writeObject와 readObject가 직렬화 형태를 처리한다.
- transient 한정자는 해당 인스턴스 필드가 기본 직렬화 형태에 포함되지 않는다는 표시이다.
```java
// 코드 87-3 합리적인 커스텀 직렬화 형태를 갖춘 StringList (462-463쪽)  
public final class StringList implements Serializable {  
    private transient int size   = 0;  
    private transient Entry head = null;  
  
    // 이제는 직렬화되지 않는다.  
    private static class Entry {  
        String data;  
        Entry  next;  
        Entry  previous;  
    }  
  
    // 지정한 문자열을 이 리스트에 추가한다.  
    public final void add(String s) {  }  
  
    /**  
     * 이 {@code StringList} 인스턴스를 직렬화한다.  
     *     * @serialData 이 리스트의 크기(포함된 문자열의 개수)를 기록한 후  
     * ({@code int}), 이어서 모든 원소를(각각은 {@code String})  
     * 순서대로 기록한다.  
     */    
     private void writeObject(ObjectOutputStream s)  
            throws IOException {  
        s.defaultWriteObject();  
        s.writeInt(size);  
  
        // 모든 원소를 올바른 순서로 기록한다.  
        for (Entry e = head; e != null; e = e.next)  
            s.writeObject(e.data);  
    }  
  
    private void readObject(ObjectInputStream s)  
            throws IOException, ClassNotFoundException {  
        s.defaultReadObject();  
        int numElements = s.readInt();  
  
        // 모든 원소를 읽어 이 리스트에 삽입한다.  
        for (int i = 0; i < numElements; i++)  
            add((String) s.readObject());  
    }  
  
    // 나머지 코드는 생략  
}
```
- 개선된 코드는 기본 직렬화에 비해 절반 정도의 공간을 차지하며 두 배 정도 빠르게 수행되고 스택오버플로우 에러가 발생하지 않는다.
- 모든 필드가 `transient`라도 `writeObject`와 `readObject`는 각각 가장 먼저 `defaultWirteObject`와 `defaultReadObject`를 호출한다.
    - 클래스 인스턴스 필드 모두가 transient면 호출하지 않아도 된다고 생각할 수 있지만, 향후 릴리스에서 인스턴스 필드가 추가될 경우 호환을 위해서이다.
    - defaultWriteObject와 defaultReadObject: 기본 직렬화 메커니즘을 사용하여 non-transient 필드들을 직렬화/역직렬화한다.
- 해당 객체의 논리적 상태와 무관한 필드라고 확신할 때만 `transient` 한정자를 생략해야 한다.

#### 기본 직렬화를 사용한다면 transient 필드들은 역직렬화될 때 기본값으로 초기화된다
- 객체 참조 필드는 null, 숫자 기본 타입 필드는 0으로, boolean 필드는 false로 초기화된다.
- 기본값을 그대로 사용해서는 안된다면 readObject 메서드에서 defaultReadObject를 호출한다음, 해당 필드를 원하는 값으로 복원하자.
```java
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class SimpleCache implements Serializable {
    private Map<String, String> cacheMap;
    private transient long lastAccessTime;  // 직렬화하지 않을 필드

    public SimpleCache() {
        cacheMap = new HashMap<>();
        lastAccessTime = System.currentTimeMillis();
    }

    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        // 기본 역직렬화 수행
        in.defaultReadObject();

        // lastAccessTime 필드 초기화
        // 기본값(0)을 사용하지 않고 현재 시간으로 설정
        lastAccessTime = System.currentTimeMillis();
    }
}
```

#### 객체의 전체 상태를 읽는 메서드에 적용해야 하는 동기화 메커니즘을 직렬화에도 적용해야 한다
- 모든 메서드를 `synchronized`로 선언하여 스레드 안전하게 만든 객체에 기본 직렬화를 사용하려면 `writeObject`도 다음 코드처럼 `synchronized`로 선언해야 한다.
```java
private synchronized void writeObject(ObjectOutputStream s) throws IOException {
	s.defaultWriteObject();
}
```
- 만약 writeObject 메서드 안에서 동기화하고 싶다면 클래스의 다른 부분에서 사용하는 락 순서를 똑같이 따라야 한다.
    - 그렇지 않으면 자원 순서 교착상태에 빠질 수 있다.

#### 어떤 직렬화 형태를 택하든 직렬화 가능 클래스 모두에 직렬 버전 UID를 명시적으로 부여하자
```java
private static final long serialVersionUID = <무작위 long 값>;
```
- `직렬 버전 UID`가 일으키는 잠재적인 호환성 문제가 사라진다.
- 성능도 조금 빨라지는데, 직렬 버전 UID를 명시하지 않으면 런타임에 이 값을 생성하느라 복잡한 연산을 수행하기 때문이다.
- `직렬 버전 UID`가 꼭 고유할 필요는 없다.
    - 만약 직렬 버전 UID가 없는 기존 클래스를 구버전으로 직렬화된 인스턴스와 호환성을 유지한 채 수정하고 싶다면, 구버전에서 사용한 자동 생성 값을 그대로 사용해야 한다.
- 기존 버전 클래스와의 호환성을 끊고 싶다면 단순히 직렬 버전 UID의 값을 바꿔주면 된다.
    - 이렇게 하면 기존 버전의 직렬화된 인스턴스를 역직렬화할 때 `InvalidClassException`이 던져진다.
    - 구버전으로 직렬화된 인스턴스들과의 호환성을 끊으려는 경우를 제외하고는 직렬 버전 UID를 절대 수정하지 말자.

# 결론
- 클래스를 직렬화하기로 했다면 어떤 직렬화 형태를 사용할지 심사숙고해야 한다.
    - 직렬화 형태에 포함된 필드도 마음대로 제거할 수 없다. (영원히 지원해야 한다.)
    - 잘못된 직렬화 형태를 선택하면 해당 클래스의 복잡성과 성능에 영구히 부정적인 영향을 남긴다.
- 자바의 기본 직렬화 형태는 객체를 직렬화한 결과가 **해당 객체의 논리적 표현에 부합**할 때만 사용하고, 그렇지 않으면 객체를 적절히 설명하는 **커스텀 직렬화 형태**를 고안하라.
