# 72. 표준 예외를 사용하라
## 표준 예외를 사용하면 얻는게 많다.
- API가 다른 사람이 익히고 사용하기 쉬워진다.
    - 낯선 예외를 사용하지 않게 되어 읽기 쉽다.
- 예외 클래스 수가 적을수록 메모리 사용량도 줄고 클래스를 적재하는 시간도 적게 걸린다.

#### IllegalArgumentException
- 호출자가 인수로 부적절한 값을 넘길 때 던진다.

#### IllegalStateException
- 대상 객체의 상태가 호출한 메서드를 수행하기에 적합하지 않을 때 던진다.

> 인수값이 무엇이었든 어차피 실패했을 거라면 IllgalStateException을, 그렇지 않으면 IllegalArgumentException을 던지자.

- 잘못된 인수나 상태의 일부는 `IllegalArgumentException`과 `IllegalStateException` 대신 따로 구분해 사용한다.

#### NullPointerException
- null 값을 허용하지 않은 메서드에 null을 건넬때 던진다.

#### IndexOutOfBoundsException
- 어떤 시퀀스의 허용 범위를 넘는 값을 건넬 때 던진다.

#### ConcurrentModificationException
- 단일 스레드에서 사용하려고 설계한 객체를 여러 스레드가 동시에 수정하려 할 때 던진다.

#### UnsupportedOperationException
- 클라이언트가 요청한 동작을 대상 객체가 지원하지 않을 때 던진다.

### Exception, RuntimeException, Throwable, Error는 직접 재사용하지말자.
- 다른 예외의 상위 클래스이므로 안정적으로 테스트할 수 없다.
    - 여러 성격의 예외들을 포괄하는 클래스이기 때문이다.

### 상황에 부합한다면 항상 표준 예외를 재사용하자
- 예외의 `이름` 뿐 아니라 예외가 던져지는 `맥락`도 부합할때 재사용한다.
- 단, 예외는 직렬화할 수 있다는 사실을 기억하자.
    - Java에서 모든 예외 클래스는 `Throwable`을 상속하며, `Throwable`은 `Serializable` 인터페이스를 구현한다.
    - 직렬화에는 많은 부담이 따른다.
