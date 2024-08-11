# 27. 비검사 경고는 제거하라
- 제네릭을 사용하기 시작하면 수많은 컴**파일러 경고**를 보게 된다.
    - 컴파일러가 알려준대로 대부분의 비검사 경고는 쉽게 제거할 수 있다.
- 컴파일러가 알려준 **타입 매개변수를 명시하지 않고,** java7부터 지원하는 **다이아몬드 연산자**(`<>`)만으로 해결할 수 있다.
    - **컴파일러가 올바른 실제 타입 매개변수를 추론**해준다.
      java 7 이전
```java
List<String> list = new ArrayList<String>();
```

java 7 이후 (다이아몬드 연산자 사용)
```java
List<String> list = new ArrayList<>();
```
> `ArrayList<>` 부분에서 타입 매개변수를 생략했지만 컴파일러가 `List<String>`에서 `String`을 추론하여 적용

## 할 수 있는 한 모든 비검사 경고를 제거하라
- 타입 안전성이 보장된다.
    - 런타임에 ClassCastException이 발생하지 않고, 의도한대로 잘 동작한다.

### 경고를 제거할 수는 없지만 타입 안전하다고 확신할 수 있다면 `@SuppressWarnings("unchecked")`로 경고를 숨기자
- 안전하다고 검증된 비검사 경고를 그대로 두면, **진짜 문제를 알리는 새로운 경고가 나와도 눈치채지 못한다.**

#### `@SuppressWarnings` 어노테이션은 개별 지역변수 선언부터 클래스 전체까지 어떤 선언에도 달 수 있다.
- **가능한 좁은 범위에 적용하자.**
    - ex) 변수 선언, 아주 짧은 메서드, 생성자
- 한 줄이 넘는 메서드나 생성자에 달린 `@SuppressWarnings` 어노테이션을 발견하면 **지역변수 선언 쪽으로 옮기자**.
```java
public <T> T[] toArray(T[] a){
	if (a.length < size) // 더 크기가 작으면 새로운 배열로 복사해서 리턴
		return (T[]) Arrays.copyOf(elements, size, a.getClass());
	System.arraycopy(elements, 0, a, 0, size); // 크기가 크몀 입력 배열로 복사
	if (a.length > size) // 끝을 나타내기 위해 null을 추가
		a[size] = null;
	return a;
}
```
- 경고: elements가 `Object[]` 으로 선언되어있는데, `T[]`로 캐스팅하는 과정에서 경고가 발생한다.
- 메서드 전체에 `@SuppressWarnings`를 다는 것보다는, 반환값을 담을 **지역변수를 선언하고 그 변수에 어노테이션을 달아주자**.

```java
public <T> T[] toArray(T[] a){
	if (a.length < size) // 더 크기가 작으면 새로운 배열로 복사해서 리턴
		// 생성한 배열과 매개변수로 받은 배열의 타입이 모두 T[]로 같으므로 올바른 형변환이다.
		@SuppressWarnings("unchecked")
		T[] result = (T[]) Arrays.copyOf(elements, size, a.getClass());
		return result;
	System.arraycopy(elements, 0, a, 0, size); // 크기가 크몀 입력 배열로 복사
	if (a.length > size) // 끝을 나타내기 위해 null을 추가
		a[size] = null;
	return a;
}
```
- `@SuppressWarnings("unchecked")` 어노테이션을 사용할 때면 **그 경고를 무시해도 안전한 이유를 항상 주석으로 남겨야 한다.**
    - 다른 사람이 그 코드를 이해하고, 잘못 수정하는 것을 막는다.

#### 참고) toArray 사용방법
- 컬렉션(ArrayList, LinkedList 등의) 요소를 배열로 변환한다.
```java
List<String> list = new ArrayList<>();
list.add("A");
list.add("B");

// 충분히 큰 배열 전달
String[] array1 = new String[3];
String[] result1 = list.toArray(array1);
// result1은 {"A", "B", null}

// 작은 배열 전달
String[] array2 = new String[1];
String[] result2 = list.toArray(array2);
// result2는 새로 할당된 {"A", "B"}

// 정확한 크기의 배열 전달
String[] array3 = new String[2];
String[] result3 = list.toArray(array3);
// result3은 {"A", "B"}
```

## 결론
- 비검사 경고는 중요하니 무시하지 말자.
    - 모든 비검사 경고는 런타임에 `ClassCastException`을 일으킬 수 있는 잠재적 가능성을 뜻하니 최선을 다해 제거하라.
- 경고를 없앨 방법을 찾지 못하겠다면, 그 코드가 타입 안전함을 증명하고 가능한 한 범위를 좁혀 `@SuppressWarnings("unchecked")`로 경고를 숨겨라.
    - 그 후 경고를 숨기기로 한 근거를 **주석**으로 남겨라.
