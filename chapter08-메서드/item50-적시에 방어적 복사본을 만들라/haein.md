## 요약

자바는 안전한 언어이지만 다른 클래스로부터의 침범을 아무런 노력 없이 다 막을 수 있는 것은 아니다 

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
    public Period(Date start, Date end) {
        if (start.compareTo(end) > 0)
            throw new IllegalArgumentException(
                    start + "가 " + end + "보다 늦다.");
        this.start = start;
        this.end   = end;
    }

    public Date start() {
        return start;
    }
    public Date end() {
        return end;
    }

    public String toString() {
        return start + " - " + end;
    }
}
```
- 이 클래스는 불변처럼 보이고, 시작 시간이 중료 시간보다 늦을 수 있다는 불변식이 무리 없이 지켜질 것 같다
- 하지만 `Date` 가 가변이라는 사실을 이용하여 어렵지 않게 그 불변식을 깨드릴 수 있다

```java
        Date start = new Date();
        Date end = new Date();
        Period p = new Period(start, end);
        end.setYear(78);  // p의 내부를 변경했다!
        System.out.println(p);
```
- 다행히 자바 8 이후로는 Date 대신 불변인 `Instant`, `LocalDateTime`, `ZoneDateTime` 등을 이용하면 된다
- 하지만 가변인 낡은 값 타입을 사용하는 API 와 내부 구현이 많이 남아 있으므로 이를 대처하는 방법을 알아야 한다

### 방어적 복사
- 생성자에서 받은 가변 매개변수를 방어적으로 복사해야 한다 
- 그런 다음 `Period` 인스턴스 안에서는 원본이 아닌 복사본을 사용한다 
- 매개변수의 유효성을 검사하기 전에 방어적 복사본을 만들고 이 복사본으로 유효성을 검사하자
- 멀티스레딩 환경이라면 유효성 검사 뒤 복사본을 만드는 찰나에 다른 스레드가 원본 객체를 수정할 위험이 있다
(TOCTOU 공격)

```java
    public Period(Date start, Date end) {
        this.start = new Date(start.getTime());
        this.end   = new Date(end.getTime());

        if (this.start.compareTo(this.end) > 0)
            throw new IllegalArgumentException(
                    this.start + "가 " + this.end + "보다 늦다.");
```
- 매개변수가 제3자에 의해 확장될 수 있는 타입이라면 방어적 복사본을 만들 때 clone 을 이용해서는 안 된다
- 이 예시에서 Date 가 그렇다 clone 이 악의를 가진 하위 클래스의 인스턴스를 반환할 수도 있다
- `Period` 의 가변 정보를 드러내지 않기 위해 접근자가 가변 필드의 방어적 복사본을 반환하도록 수정하면 완벽한 불변이 될 것이다 
(이 경우 접근자에서는 clone을 사용해도 된다 하지만 생성자나 정적 팩터리가 더 좋다)

### 방어적 복사에는 성능 저하가 따르고 또 항상 쓸수 있는 것은 아니다
- 호출자가 컴포넌트 내부를 수정하지 않으리라고 확신하면 이를 생략할 수 있다
- 다른 패키지에서 사용한다고 해서 넘겨받은 가변 매개변수를 항상 방어적으로 저장해야 하는 것은 아니다 
(때로는 그 행위가 객체의 통제권을 명백히 이전함을 뜻하기도 한다)
- 통제권을 넘겨받기로 한 메서드나 생성자를 가진 클래스들은 악의적인 공격에 취약하므로 클래스와 그 클라이언트가 상호 신뢰할 수 있을 때,
혹은 불변식이 깨지더라도 그 영향이 오직 호출한 클라이언트로 국한될 때로 한정해야 한다 (래퍼 클래스)