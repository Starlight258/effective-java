# 69. 예외는 진짜 예외 상황에만 사용하라
### 예외를 일상적인 제어 흐름용으로 쓰여선 안된다.
```java
try {
	int i = 0;
	while (true)
		range[i++].climb();
} catch (ArrayIndexOutOfBoundsException e){

}
```
- 배열의 끝에 도착하면 종료하는 코드이다.
- 이해하기 어렵고 복잡하다.

#### 잘못된 점
1. 예외는 예외 상황에 사용되는 용도로 설계되었으므로 JVM 구현자 입장에서 최적화에 별로 신경쓰지 않는다.
2. try-catch 블록 안에 코드를 넣으면 JVM이 적용할 수 있는 최적화가 제한된다.
3. 배열을 순회하는 표준 관용구는 중복 검사를 수행하지 않는다. JVM이 알아서 최적화해 없애준다.
4. 반복문 안에 버그가 발생할 경우 엉뚱한 예외를 정상적인 상황으로 오해하여 넘어간다.

#### 개선
```java
for (Mountain m:range){
	m.climb();
}
```
- 곧바로 이해할 수 있다.

### 잘 설계된 API라면 클라이언트가 정상적인 제어 흐름에서 예외를 사용할 일이 없게 해야 한다.
- 특정 상태에서만 호출 가능할 경우 상태 검사 메서드를 제공해야 한다.
    - ex ) Iterator의 hasNext
- 또는 올바르지 않은 상태일 때 빈 Optional 혹은 특정 값을 사용한다.

#### 상태 검사 메서드, 옵셔널, 특정 값 중 하나를 선택하는 지침
1.  외부 동기화 없이 여러 스레드가 동시에 접근할 수 있거나 상태가 변할 수 있다면 옵셔널이나 특정 값을 사용한다.
    - 상태 검사 메서드와 실제 작업 사이에 객체의 상태가 변할 수 있어 일관성 유지가 어렵다.
2. 성능이 중요한 상황에서 상태 검사 메서드가 상태 의존성 메서드의 작업을 일부 중복 사용한다면 옵셔널이나 특정 값을 선택한다.
    - 중복 연산을 피해 성능을 향상시킬 수 있다.
3. 다른 모든 경우에는 상태 검사 메서드 방식이 더 낫다.

## 결론
- 예외는 예외 상황에서 쓸 의도로 설계되었다.
- 정상적인 제어 흐름에서 사용해서는 안되며, 이를 프로그래머에게 강요하는 api를 만들어서도 안된다.

