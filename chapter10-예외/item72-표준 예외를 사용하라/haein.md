## 요약

### 표준 예외 재사용
- API 가 다른 사람이 익히고 사용하기 쉬워진다
- 프로그램이 읽기 쉽다
- 예외 클래스 수가 적을수록 메모리 사용량도 줄고 클래스를 적재하는 시간도 적게 걸린다 
- `Exception` , `RuntimeException`, `Throwable`, `Error` 는 직접 재사용하지 말자 

### 많이 쓰는 표준 예외
- **IllegalArgumentException - 호출자가 인수로 부적절한 값을 넘길 때 던지는 예외**
- **IllegalStateException - 대상 객체의 상태가 호출된 메서드를 수행하기에 적합하지 않을 때**
- **NullPointerException - null 값을 허용하지 않는 메서드에 null 을 건네는 경우 (null 참조할 때)**
- **IndexOutOfBoundsException - 시퀀스의 허용 범위를 넘는 값을 건넬 때**
- **ConcurrentModificationException - 단일 스레드에서 사용하려고 설계한 객체를 여러 스레드가 동시에 수정하려 할 때**
- **UnsupportedOperationException - 클라이언트가 요청한 동작을 대상 객체가 지원하지 않을 때**


### 예외 재사용 시 주의점
- 예외의 이름뿐 아니라 예외가 던져지는 맥락도 부합할 때만 재사용한다
- 예외는 직렬화할 수 있다는 사실을 기억하자 - 커스텀 예외를 사용하지 말아야 할 이유


### 표준 예외는 상호 베타적이지 않아서 선택하기 어려울 수 있음
- 카드 덱의 카드를 인자로 받은 수만큼 뽑는 메서드가 있을 때
    - `IllegalArgumentException` : 인수 값이 정상이었다면 성공했을 경우 (너무 많은 카드를 뽑음)

    - `IllegalStateException` : 인수 값에 상관없이 실패하는 경우  (덱에 남은 카드가 너무 적음)