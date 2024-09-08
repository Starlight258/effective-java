# 57. 지역변수의 범위를 최소화하라
## 지역 변수의 유효 범위를 최소로 줄이자
- 코드 가독성과 유지보수성이 높아지고 오류 가능성은 낮아진다.

### 지역 변수의 범위를 줄이는 가장 강력한 방법은 **가장 처음 쓰일 때 선언하는 것**이다.
```java
public static void main(String[] args) {
	// 1. 즉시 초기화
	int count = 0;
	String name = "John Doe";

	// 2. 초기화 지연 (나쁜 예)
	int result;
	result = someComplexCalculation();  // 이렇게 하면 안 됨
}
```
- 미리 선언부터 해두면 코드의 가독성이 떨어진다.
- 변수를 실제로 사용하는 시점에는 타입과 초기값이 기억나지 않을 수도 있다.

#### 거의 모든 지역 변수는 선언과 동시에 초기화해야한다.
- 초기화에 필요한 정보가 충분하지 않으면 선언을 미뤄야한다.
- `try-catch`에서 검사 예외를 던질 가능성이 있다면 `try 블록`에서 초기화해야한다.
    - 그렇지 않으면 예외가 블록을 넘어 메서드에까지 전파된다.
- 변수값을 `try 블록` 바깥에서도 사용해야한다면 `try 블록` 앞에서 선언해야한다.
```java
BufferedReader reader = null;
try {
	reader = new BufferedReader(new FileReader("example.txt"));
	String firstLine = reader.readLine();
	System.out.println(firstLine);
} catch (IOException e) {
	System.err.println("파일을 읽는 도중 오류 발생: " + e.getMessage());
} finally {
	if (reader != null) {
		try {
			reader.close();
		} catch (IOException e) {
			System.err.println("파일을 닫는 도중 오류 발생: " + e.getMessage());
		}
	}
}
```

### 반복 변수의 값을 반복문이 종료한 뒤에도 사용할 것이 아니라면 while 문보다 for 문이 낫다.
- 컬렉션이나 배열 순회시 권장 관용구 (`for-each`)
```java
for (Element e: c){
}
```
- 반복자를 사용해야할 경우 `for 문`을 쓰는 것이 좋다.
```java
for (Iterator<Element> i = c.iterator(); i.hasNext(); ){
	Element e = i.next();
}
```

- `for 문`을 사용하면 원소와 반복자의 유효 범위가 반복문 종료와 함께 끝난다.
    - `for 문`을 사용하면 변수 유효 범위가 `for 문` 범위와 일치하여 **똑같은 이름의 변수를 여러 반복문에서 써도 영향을 주지 않는다.**
```java
for (Iterator<Element> i2 = c2.iterator(); i.hasNext(); ){ // 컴파일 오류
	Element e2 = i2.next();
}
```

- `for 문`은 `while 문`보다 짧아서 가독성이 좋다.
- `n = expensiveComputation()`이 루프 초기화 부분에서 한 번만 실행되어 **반복때마다 n을 계산하는 비용을 줄인다**.
```java
for (int i = 0, n = expensiveComputation(); i<n; i++) {
}
```

### 메서드를 작게 유지하고 한 가지 기능에 집중하자.
- 메서드를 기능별로 쪼개면 다른 기능을 수행하는 코드에서 다른 기능의 지역변수에 접근할 수 없다.

