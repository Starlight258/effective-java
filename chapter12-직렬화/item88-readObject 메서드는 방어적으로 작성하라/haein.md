## 요약

### 직렬화와 불변식

```java
public final class Period {
    private final Date start;
    private final Date end;

    /**
     * @param  start 시작 시각
     * @param  end 종료 시각. 시작 시각보다 뒤여야 한다.
     * @throws IllegalArgumentException 시작 시각이 종료 시각보다 늦을 때 발생한다.
     * @throws NullPointerException start나 end가 null이면 발생한다.
     */

    // 코드 50-3 수정한 생성자 - 매개변수의 방어적 복사본을 만든다. (304쪽)
    public Period(Date start, Date end) {
        this.start = new Date(start.getTime());
        this.end   = new Date(end.getTime());

        if (this.start.compareTo(this.end) > 0)
            throw new IllegalArgumentException(
                    this.start + "가 " + this.end + "보다 늦다.");
    }

    // 코드 50-5 수정한 접근자 - 필드의 방어적 복사본을 반환한다. (305쪽)
    public Date start() {
        return new Date(start.getTime());
    }

    public Date end() {
        return new Date(end.getTime());
    }

    public String toString() {
        return start + " - " + end;
    }

    // 나머지 코드 생략
}
```
- `readObject` 메서드는 실질적으로 또 다른 `public` 생성자이기 때문에 다른 생성자와 똑같은 수준으로 주의를 기울여야 한다
- `readObject` 는 매개변수로 바이트 스트림을 받는 생성자라고 생각하자
    - 불변식을 깨드릴 의도로 임의 생성한 바이트 스트림을 건네면 문제가 생긴다
    - 정상적인 생성자로는 만들어낼 수 없는 객체를 생성해낼 수 있다
    - 따라서 `readObject` 메서드가 `defaultReadObject` 호출 후 역직렬화된 객체가 유효한지 검사해야 한다
    (`InvalidObjectException` 을 던져 잘못된 역직렬화가 일어나는 것을 막을 수 있다)

```java
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException{
    s.defaultReadObject();

    // 불변식을 만족하는지 검사한다.
    if (start.compareTo(end) > 0){
        throw new InvalidObjectException(start + "가" + end + "보다 늦다.");
    }
}
```
- 허용되지 않는 `Period` 인스턴스를 생성하는 일을 막을 수 있다
- 하지만 정상 인스턴스에서 시작된 바이트 스트림 끝에 `private` 인 Date 필드로의 참조를 추가하면 가변 인스턴스를 만들어낼 수 있다

```java
public class MutablePeriod{
    public final Period period;

    public final Date start;

    public final Date end;

    public MutablePeriod(){
        try{
            ByteArrayOutputStream bos =
                new ByteArrayOutputStream();
            ObjectOutputStream out =
                new ObjectOutputStream(bos);

            // 유효한 Period 인스턴스를 직렬화한다.
            out.writeObject(new Period(new Date(, new Date())));

            /*
             * 악의적인 `이전 객체 참조`, 즉 내부 Date 필드로의 참조를 추가한다.
             * 상세 내용은 자바 객체 직렬화 명세의 6.4 절을 참고하자.
             */
            byte[] ref = {0x71, 0, 0x7e, 0, 5}; // 참고 #5
            bos.write(ref); // 시작(start) 필드
            ref[4] = 4; // 팜조 # 4
            bos.write(ref); // 종료(end) 필드

            // Period 역직렬화 후 참조를 '훔친다'.
            ObjectInputStream in = new ObjectInputStream(
                new ByteArrayInputStream(bos.toByteArray());
            period = (Period) in.readObject();
            start = (Date) in.readObject();
            end = (Date) in.readObject();
            )catch (IOException | ClassNotFoundException e){

            }
        }
    }
}
```
- `Period` 인스턴스 자체는 불변식을 유지한 채 생성됐으나, 이후 참조를 통해 내부의 값을 수정할 수 있다
- 객체를 역직렬화할 때는 클라이언트가 소유해서는 안 되는 객체 참조를 갖는 필드를 모두 반드시 방어적으로 복사해야 한다 

```java
private void readObject(ObjectInputStream s) throws IOException, ClassNotFoundException{
    s.defaultReadObject();

    // 가변 요소들을 방어적으로 복사한다
    start = new Date(start.getTime());
    end = new Date(end.getTime());

    // 불변식을 만족하는지 검사한다.
    if (start.compareTo(end) > 0){
        throw new InvalidObjectException(start + "가" + end + "보다 늦다.");
    }
}
```
- 방어적 복사를 유효성 검사보다 앞서 수행한다
- `Date` 의 `clone` 은 사용하지 않았다 
- `readObject` 를 사용하려면 `final` 키워드를 제거해야 한다 

### 기본 readObject() 를 써도 좋을 지 판단하는 방법
- `transient` 필드를 제외한 모든 필드의 값을 매개변수로 받아 유효성 감사 없이 필드에 대입하는 `public` 생성자를 추가해도 괜찮은가?
    - 그렇지 않다면 커스텀 직렬화를 사용하여 모든 유효성 검사와 방어적 복사를 수행해야 한다
    - 직렬화 프록시 패턴을 사용하는 방법도 있다 
- `final` 이 아닌 직렬화 가능 클래스는 `readObjct` 에서 재정의 가능 메서드를 호출해서는 안 된다