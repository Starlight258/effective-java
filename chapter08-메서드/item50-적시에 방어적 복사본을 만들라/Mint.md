# 50. 적시에 방어적 복사본을 만들라
## 클라이언트가 불변식을 깨뜨리려고 한다고 가정하고 방어적으로 프로그래밍해야한다
- 악의적인 의도를 가진 사람들이 시스템의 보안을 뚫으려는 시도가 늘고 있다.
- 실수로 클래스를 오작동하게 만들 수도 있다.

### 불변식을 지키지 못한 예시 1
```java
// 코드 50-1 기간을 표현하는 클래스 - 불변식을 지키지 못했다. (302-305쪽)  
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
```
- 공격 코드 예시
```java
// 코드 50-2 Period 인스턴스의 내부를 공격해보자. (303쪽)  
Date start = new Date();  
Date end = new Date();  
Period p = new Period(start, end);  
end.setYear(78);  // p의 내부를 변경했다!  
System.out.println(p);
```
매개변수를 외부에서 변경하여 불변식이 깨졌다.
> Date는 낡은 API이니 더이상 사용하면 안된다.
> 불변인 Instant를 사용하자.

### 생성자에서 받은 가변 매개변수 각각을 방어적으로 복사하자.
```java
// 코드 50-3 수정한 생성자 - 매개변수의 방어적 복사본을 만든다. (304쪽)  
public Period(Date start, Date end) {  
    this.start = new Date(start.getTime());  
    this.end   = new Date(end.getTime());  
  
    if (this.start.compareTo(this.end) > 0)  
        throw new IllegalArgumentException(  
                this.start + "가 " + this.end + "보다 늦다.");  
}
```
- 외부에서 매개변수를 변경해도 Period 인스턴스에 영향을 주지 않는다.
- **방어적 복사본을 만든 후 매개변수의 유효성을 검사하자.**
    - 멀티 스레드 환경에서 매개변수의 유효성을 검사한 후 원본 객체가 수정되어 올바르지 않은 상태의 객체가 복사될 수 있다.
    - TOCTOU 공격 (검사시점/사용시점 공격)
- **방어적 복사에 `clone` 메서드를 사용하지 말자.**
    - 악의를 가진 하위 클래스의 인스턴스를 반환할 수 있다.
    - 매개변수가 확장될 수 있는 타입이라면 방어적 복사본을 만들 때 clone을 사용해서는 안된다.

### 불변식을 지키지 못한 예시 2
```java
// 코드 50-4 Period 인스턴스를 향한 두 번째 공격 (305쪽)  
start = new Date();  
end = new Date();  
p = new Period(start, end);  
p.end().setYear(78);  // p의 내부를 변경했다!  
System.out.println(p);
```
- 접근자 메서드가 내부의 가변 정보를 직접 드러낸다.
- 외부에서 내부의 가변 정보를 수정할 수 있다.

### 가변 필드의 방어적 복사본을 만들자
```java
// 코드 50-5 수정한 접근자 - 필드의 방어적 복사본을 반환한다. (305쪽)  
public Date start() {  
    return new Date(start.getTime());  
}  
  
public Date end() {  
    return new Date(end.getTime());  
}
```
- 외부에서 불변식을 절대 깨뜨릴 수 없다.
    - 모든 필드가 객체 안에 완벽하게 캡슐화되었다.
- 생성자와 달리 `접근자` 메서드에서는 방어적 복사에 `clone`을 사용해도 된다.
    - Date 객체는 java.util.Date가 확실하기 때문이다.
    - 하지만 clone 재정의는 주의해야하므로 인스턴스 복사시 일반적으로 `생성자`나 `정적 팩터리`를 쓰는게 좋다.

#### 내부에서 사용하는 배열을 클라이언트에 반환할때는 항상 방어적 복사를 사용해야한다.
- 길이가 1이상인 배열은 무조건 가변이다.
- 방어적 복사를 수행하거나 불변 뷰를 반환해야한다.

### 되도록 불변 객체들을 조합해 객체를 구성해야 방어적 복사를 할 일이 줄어든다.
- Date 대신 불변인 Instant를 사용하라

### 다른 패키지에서 사용한다고 해서 매개변수를 항상 방어적으로 복사해 저장해야하는 것은 아니다
- 통제권을 이전하는 메서드를 호출하는 클라이언트는 해당 객체를 더이상 직접 수정하는 일이 없음을 약속하면 된다. (`문서화`)
- **해당 클래스와 클라이언트가 상호 신뢰**할 수 있을  때, 혹은 **불변식이 깨지더라도 그 영향이 오직 호출한 클라이언트로 국한**될 때로 한정해야한다.
    - ex) Wrapper 클래스 - 불변 뷰 반환후 수정하려고 시도하면 에러가 나고 클라이언트에게만 영향이 간다.


# 결론
- 클래스가 클라이언트로부터 받는 혹은 **클라이언트로 반환하는 구성요소가 가변이라면 그 요소는 반드시 방어적으로 복사**해야한다.
- 복사 비용이 너무 크거나 클라이언트가 그 요소를 잘못 수정할 일이 없음을 신뢰한다면 **해당 구성요소를 수정했을 때의 책임이 클라이언트에 있음을 문서에 명시**하자.

