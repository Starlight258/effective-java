# 88. readObject 메서드는 방어적으로 작성하라
### 방어적 복사를 사용하는 불변 클래스
- 가변인 Date 객체를 방어적으로 복사하여 불변을 유지하자.
```java
public final class Period {  
    private final Date start;  
    private final Date end;  
  
    /**  
     * @param start 시작 시각  
     * @param end   종료 시각. 시작 시각보다 뒤여야 한다.  
     * @throws IllegalArgumentException 시작 시각이 종료 시각보다 늦을 때 발생한다.  
     * @throws NullPointerException     start나 end가 null일 때 발생한다.  
     */    
     public Period(Date start, Date end) {  
        this.start = start;  
        this.end = end;  
        if (start.compareTo(end) > 0) {  
            throw new IllegalArgumentException(start + "가 " + end + "보다 늦다.");  
        }  
    }  
  
    public Date start() {  
        return new Date(start.getTime());  
    }  
  
    public Date end() {  
        return new Date(end.getTime());  
    }  
  
    public String toString() {  
        return start + " - " + end;  
    }  
}
```
- `readObject`는 실질적으로 또 다른 `public` 생성자이기 때문에 주의를 기울여야 한다.
    - `readObject` 메서드에서도 인수가 유효한지 검사해야 하고 필요하다면 매개변수를 방어적으로 복사해야 한다.
    - `readObject`는 매개변수를 바이트 스트림으로 받는 생성자이다.
    - 불변식을 깨뜨릴 의도로 임의 생성한 바이트 스트림을 건네면 문제가 생긴다.
```java
public class BogusPeriod {  
    private static final byte[] serializedForm = new byte[] {  // 진짜 Period 인스턴스에서는 만들어질 수 없는 바이트 스트림
        ~~};  
    public static void main(String[] args) {  
        Period p = (Period) deserialize(serializedForm);  
        System.out.println(p);  
  
    }  
    static Object deserialize(byte[] sf) {  
        try {  
            return new ObjectInputStream(new ByteArrayInputStream(sf)).readObject();  
        } catch (IOException | ClassNotFoundException e) {  
            throw new IllegalArgumentException(e);  
        }  
    }  
}
```
> 직렬화할 수 있도록 선언한 것만으로 클래스의 불변식을 깨뜨리는 객체를 만들 수 있다.

#### 유효성 검사
- `Period`의 `readObject` 메서드가 `defaultReadObject`를 호출한 다음 역직렬화한 객체가 유효한지 검사해야 한다.
    - 유효성 검사에 실패하면 `InvalidObjectException`을 던지게 하여 잘못된 역직렬화가 일어나는 것을 막자.
```java
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException {  
    s.defaultReadObject();  
      
    if (start.compareTo(end) > 0) {  
        throw new InvalidObjectException(start + " after " + end);  
    }  
}
```

#### 바이트 스트림 끝에 참조를 추가하면 가변 인스턴스를 만들어낼 수 있다
- 정상 Period 인스턴스에서 시작된 바이트 스트림 끝에 private Date 필드로의 참조를 추가하면 가변 Period 인스턴스를 만들어낼 수 있다.
    - 공격자는 ObjectInputStream에서 Period 인스턴스를 읽은 후 스트림 끝에 추가된 악의적인 객체 참조를 읽어 Period 객체의 내부 정보를 얻을 수 있다.

#### 가변 공격의 예
```java
public class MutablePeriod {
    // Period 인스턴스
    public final Period period;

    // 시작 시각 필드 - 외부에서 접근할 수 있다!
    public final Date start;

    // 종료 시각 필드 - 외부에서 접근할 수 있다!
    public final Date end;

    public MutablePeriod() {
        try {
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream out = new ObjectOutputStream(bos);

            // 유효한 Period 인스턴스를 직렬화한다.
            out.writeObject(new Period(new Date(), new Date()));

            /*
             * 악의적인 "이전 객체 참조", 즉 내부 Date 필드로의 참조를 추가한다.
             * 상세한 내용은 자바 객체 직렬화 명세의 6.4절을 참고하자.
             */
            byte[] ref = { 0x71, 0, 0x7e, 0, 5 }; // 참조 #5
            bos.write(ref); // 시작 시각 필드
            ref[4] = 4; // 참조 #4
            bos.write(ref); // 종료 시각 필드

            // Period 역직렬화 후 Date 참조를 '훔친다'
            ObjectInputStream in = new ObjectInputStream(
                new ByteArrayInputStream(bos.toByteArray()));
            period = (Period) in.readObject();
            start = (Date) in.readObject();
            end = (Date) in.readObject();
        } catch (IOException | ClassNotFoundException e) {
            throw new AssertionError(e);
        }
    }
}
```
- 공격 예시
```java
public static void main(String[] args) {
    MutablePeriod mp = new MutablePeriod();
    Period p = mp.period;
    Date pEnd = mp.end;

    // 시간을 되돌리자!
    pEnd.setYear(78);
    System.out.println(p);

    // 60년대로 돌아가보자.
    pEnd.setYear(69);
    System.out.println(p);
}
```
- `Period` 인스턴스는 불변식을 유지한 채 생성됐지만, 의도적으로 내부의 값을 수정할 수 있었다.
    - 변경할 수 있는 인스턴스를 획득한 공격자는 이 인스턴스가 불변이라고 가정하는 클래스에 넘겨 보안 문제를 일으킬 수 있다.
- 객체를 역직렬화할 때는 클라이언트가 소유해서는 안 되는 **객체 참조를 갖는 필드를 모두 반드시 방어적으로 복사해야 한다.**
    - readObject에서는 불변 클래스 안의 모든 private 가변 요소를 방어적으로 복사해야 한다.
```java
// 방어적 복사와 유효성 검사를 수행하는 readObject 메서드
private void readObject(ObjectInputStream s) {
	s.defaultReadObject(); // 기본 역직렬화 수행

	// 방어적 복사 수행
	start = new Date(start.getTime());
	end = new Date(end.getTime());

	// 유효성 검사
	if (start.compareTo(end) > 0) {
		throw new IllegalArgumentException(start + "가 " + end + "보다 늦다.");
	}
}
```
> final 필드는 방어적 복사가 불가능하니 주의하자.


### 기본 readObject 메서드를 써도 좋을지 판단하는 방법
- `transient` 필드를 제외한 모든 필드의 값을 매개변수로 받아 유효성 검사 없이 필드에 대입하는 public 생성자를 추가해도 괜찮은가?
    - 아니오라면 커스텀 `readObject` 메서드를 만들어 모든 유효성 검사와 방어적 복사를 수행해야 한다.
    - 혹은 직렬화 프록시 패턴을 사용해야 한다.
```java
public class UnsafeSerializableClass implements Serializable {
    private final int id;
    private final Date creationDate;
    private final String name;

    public UnsafeSerializableClass(int id, Date creationDate, String name) {
        this.id = id;
        this.creationDate = new Date(creationDate.getTime());  // 방어적 복사
        this.name = name;

        // 유효성 검사
        if (id < 0) {
            throw new IllegalArgumentException("ID는 0 이상이어야 합니다.");
        }
        if (name == null || name.isEmpty()) {
            throw new IllegalArgumentException("이름은 비어있을 수 없습니다.");
        }
    }

    // 이 생성자는 안전하지 않다.
    // public UnsafeSerializableClass(int id, Date creationDate, String name, boolean unused) {
    //     this.id = id;
    //     this.creationDate = creationDate;  // 방어적 복사 없음
    //     this.name = name;
    //     // 유효성 검사 없음
    // }

    // 대신 커스텀 readObject 메서드를 사용하자.
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();  // 기본 역직렬화 수행

        // 유효성 검사
        if (id < 0) {
            throw new IllegalArgumentException("ID는 0 이상이어야 합니다.");
        }
        if (name == null || name.isEmpty()) {
            throw new IllegalArgumentException("이름은 비어있을 수 없습니다.");
        }

        // 방어적 복사
        creationDate = new Date(creationDate.getTime());
    }
}
```
직렬화 프록시 패턴 예시
```java
import java.io.InvalidObjectException;
import java.io.ObjectInputStream;
import java.io.Serializable;
import java.util.Date;

// 원본 클래스
public class Period implements Serializable {
    private final Date start;
    private final Date end;

    public Period(Date start, Date end) {
        this.start = new Date(start.getTime());
        this.end = new Date(end.getTime());
        if (this.start.compareTo(this.end) > 0)
            throw new IllegalArgumentException(start + "가 " + end + "보다 늦다.");
    }

    public Date start() { return new Date(start.getTime()); }
    public Date end() { return new Date(end.getTime()); }

    // 직렬화 프록시
    private static class SerializationProxy implements Serializable {
        private final Date start;
        private final Date end;

        SerializationProxy(Period p) {
            this.start = p.start;
            this.end = p.end;
        }

        private static final long serialVersionUID = 234098243823485285L; // 아무 long 값

        // 역직렬화 시 Period 객체로 변환
        private Object readResolve() {
            return new Period(start, end);
        }
    }

    // 직렬화 프록시 사용을 명시
    private Object writeReplace() {
        return new SerializationProxy(this);
    }

    // 직렬화 공격 방어
    private void readObject(ObjectInputStream stream) throws InvalidObjectException {
        throw new InvalidObjectException("프록시가 필요합니다.");
    }
}
```
- `SerializationProxy`: `Period`의 핵심 데이터만 포함한다.

#### final이 아닌 직렬화 가능 클래스라면 readObject와 생성자의 공통점이 있다.
- 생성자처럼 `readObject` 메서드도 재정의 가능 메서드를 호출해서는 안된다.
    - 해당 메서드가 재정의되면, 하위 클래스의 상태가 온전히 역직렬화되기 전에 하위 클래스에서 재정의한 메서드가 실행되어 오작동으로 이어진다.

## 결론
- `readObject` 메서드를 작성할 때는 언제나 `public` 생성자를 작성하는 자세로 임해야 한다.
    - `readObject`는 어떤 바이트 스트림이 넘어오더라도 유효한 인스턴스를 만들어내야 한다.
- 커스텀 직렬화를 사용하더라도 모든 문제가 발생할 수 있다.
- **안전한 Object 메서드를 작성하는 지침**
    - `private`이어야 하는 객체 참조 필드는 각 필드가 가리키는 객체를 방어적으로 복사하라.
    - 모든 불변식을 검사하여 어긋나는게 발견되면 `InvalidObjectException`을 던진다. 방어적 복사 후에는 불변식 검사가 뒤따라야 한다.
    - 역직렬화 후 객체 그래프 전체의 유효성을 검사해야 한다면 `ObjectInputValidation` 인터페이스를 사용하라.
    - 직접적이든 간접적이든, 재정의할 수 있는 메서드는 호출하지 말자.
