# 26. raw type은 사용하지 말라
## 제네릭 타입
- **제네릭 클래스**와 **제네릭 인터페이스**를 말함
	- 제네릭 클래스는 클래스 선언에 **타입 매개변수**가 사용된 것
	- 제네릭 인터페이스는 클래스 선언에 **타입 매개변수**가 사용된 것
- 각각의 제네릭 타입은 **매개변수화 타입을 정의**한다.
	- ex) `List<String>` 은 원소의 타입이 `String`인 리스트를 뜻하는 매개변수화 타입이다.
	- String이 정규 타입 매개변수 E에 해당하는 실제 타입 매개변수이다.
- 제네릭 타입을 하나 정의하면 그에 딸린 **raw type**도 함께 정의된다.
	- `List<E>`의 `raw type`은 `List`이다.
	- **raw type**은 **타입 선언에서 제네릭 타입 정보가 전부 지워진 것처럼 동작**한다.
	- 제네릭이 도입되기 전 코드와 호환되도록 하기 위해서 존재한다.


### 제네릭 등장 전 raw type
```java
private final Collection stamps = ... // Stamp 인스턴스만 취급한다.

stamps.add(new Coin(...));

// 조회
for (Interator i = stamps.iterator(); i.hasNext();) {
	Stamp stamp = (Stamp) i.next(); // ClassCastException 발생
	stamp.cancel();
}
```
컴파일러는 선언된 컬렉션이 어떤 타입인지 저장하지 않으므로 Stamp만 허용된 Collecton에 Coin을 넣어도 컴파일 에러가 나지 않는다.
실행 후 **런타임 에러** `ClassCastException`가 발생한다.
> 오류는 가능한 한 발생 즉시, 이상적으로 컴파일 때 발견하는 것이 좋다.

### 제네릭 활용
```java
private final Collection<Stamp> stamps = ...;
```
**제네릭**을 활용하면 **타입 정보가 타입 선언 자체에 녹아든다.**
컴파일러는 컬렉션에 `Stamp`의 인스턴스만 넣어야 함을 인지하게 된다.
`Coin` 타입의 인스턴스를 컬렉션에 넣으려고 하면 **컴파일 오류**가 발생한다.

## raw type을 사용하지 말자
> raw type을 사용하면 제네릭의 안전성과 표현력을 모두 잃게 된다.

### raw type을 남겨둔 이유는 호환성 때문이다.
- 제네릭 없이 작성된 과거의 코드를 그대로 사용하기 위해서이다.
```java
// Java 5 이전의 코드
List oldList = new ArrayList();
oldList.add("string");
oldList.add(1);

// Java 5 이후의 제네릭 코드
List<String> newList = new ArrayList<>();
newList.add("string");
// newList.add(1); // 컴파일 오류

// 로 타입을 사용하여 이전 코드와 새 코드를 혼용
List rawList = newList; // 경고는 발생하지만 가능
rawList.add(1); // 런타임에 문제 발생 가능
```
> raw type을 사용하면 컴파일러에서 경고를 발생시킨다.
> raw type 사용시 타입 안전성이 보장되지 않아 런타임 에러가 발생할 수 있으므로 사용하지 않는 것이 좋다.

#### 제네릭 구현시 **소거 방식**을 사용하여 raw type가 제네릭 타입이 런타임에 동일하게 취급된다.
- 소거 방식 : 컴파일 시 **제네릭 타입 정보를 제거**하는 과정
	- 제네릭 타입을 컴파일 할 때 타입 매개변수를 제거하고, 필요한 곳에 타입 캐스팅을 삽입한다.
	- 이를 통해 raw type인 기존 코드와 제네릭 타입의 호환성이 확보된다.

### `List<Object>`처럼 임의 객체를 허용하는 매개변수화 타입은 괜찮다.
#### `List` vs `List<Object>`
- `List` : raw type
	- List는 `List<T>`의 상위 타입으로 취급된다.
	- **공변**성을 보인다.
- `List<Object>` : Object의 하위 클래스, 즉 **모든 타입을 허용한다는 사실을 컴파일러에게 알린다.** (컴파일 에러 잡기 가능)
	- 제네릭 타입은 기본적으로 **불공변**이다.
		- 즉 `List<String>`을 `List<Object>`에 대입할 수 없다.

#### raw type을 사용하면 타입 안전성을 잃게 된다.
> 타입 안전성 : 프로그램에서 모든 연산이 적절한 타입의 값에 대해서만 수행되도록 보장하는 특성 (컴파일 시점 검사)
```java
List rawList = new ArrayList<String>();
rawList.add(new Integer(42));  // 컴파일은 되지만, 런타임 오류 가능
```
- `raw type`은 특정 타입(`ex) List<String>`)으로 결정될 수 있지만, 타입 매개변수를 사용하지 않아 컴파일 시점에 에러를 잡을 수 없다.
- 컴파일러가 타입 검사를 하지 않아 **런타임 에러**가 날 수 있다.

#### 제네릭은 타입 안전성을 지킬 수 있다.
```java
List<Object> objectList = new ArrayList<String>();  // 컴파일 오류
```
컴파일러는 타입 매개변수를 통해 **컴파일 시점에 타입 에러**를 잡을 수 있다.
> `List<String>`은 `List<Object>`의 하위 타입이 아니므로 대입할 수 없다. (불공변성)
(제네릭인 `List<Object>`는 같은 타입만 대입이 가능하다.)

### 참고) 공변성과 불공변성
#### 공변성 (Covariance)
   - 만약 A가 B의 하위 타입이면, `T<A>`는 `T<B>`의 **하위 타입**이다.
   - 타입 계층 구조가 보존된다.
   - 배열은 공변성을 가진다.

   ```java
String[] strings = {"a", "b", "c"};
Object[] objects = strings;  // 허용됨 (공변성)
   ```
런타임 에러 가능
   ```java
objects[0] = 1;  // 런타임 ArrayStoreException
   ```
   
#### 불공변성 (Invariance):
   - A가 B의 하위 타입이어도`, T<A>`와 `T<B>` 사이에는 **상속 관계가 없다.**
   - 타입 계층 구조가 보존되지 않는다.
   - 제네릭은 기본적으로 불공변성을 가진다.
   ```java
   List<String> strings = new ArrayList<>();
   List<Object> objects = strings;  // 컴파일 오류 (불공변성)
   ```

#### 반공변성 (Contravariance)
   - 만약 A가 B의 하위 타입이면, `T<B>`는 `T<A>`의 하위 타입이다.
   - Java에서는 와일드카드를 사용하여 부분적으로 구현할 수 있다.

   ```java
   List<? super String> list = new ArrayList<Object>();  // 허용됨
   ```


#### 와일드카드를 통해 유연성 제공
- 공변성 구현: `? extends`
```java
List<? extends Number> numbers = new ArrayList<Integer>();
Number n = numbers.get(0);  // 읽기 가능
// numbers.add(new Integer(1));  // 컴파일 오류: 쓰기 불가능
 ```
A가 B의 하위 타입일 때, `List<A>`가 `List<B>`의 하위 타입이 되는 관계
`? extends T`는 T와 T의 모든 하위 타입을 허용한다.
읽기만 가능하다.

- 반공변성 구현: `? super`
```java
List<? super Integer> integers = new ArrayList<Number>();
integers.add(new Integer(1));  // 쓰기 가능
Object obj = integers.get(0);  // 읽기는 Object 타입으로만 가능
 ```
A가 B의 상위 타입일 때, `List<A>`가 `List<B>`의 하위 타입이 되는 관계
-  쓰기(추가)는 가능하지만, 읽기는 제한적이다.

#### 공변성과 불공변성의 장단점
- 공변성: 유연성이 높지만, 타입 안전성이 낮을 수 있다.
- 불공변성: 타입 안전성이 높지만, 유연성이 낮다.

#### Java에서 제네릭을 불공변성으로 설계한 이유
1. 타입 안전성 보장
2. 런타임 오류 방지
3. 컴파일 시점에 더 많은 오류 탐지
> 기본적으로 제네릭에 불공변성을 제거하여 타입 안정성을 높이고, 필요한 경우 와일드 카드를 통해 유연성을 제공한다.

### raw type 대신 비한정적 와일드카드 타입(`?`)을 사용할 수 있다.
- `raw type`을 사용한 메서드
```java
static int numElementsInCommon(Set s1, Set s2){
	int result = 0;
	for (Object o1: s1)
		if (s2.contains(o1))
			result++;
	return result;
}
```

raw type을 사용하였으므로 **런타임 에러**가 발생할 수 있어 안전하지 않다.
아무 타입의 원소나 넣을 수 있어 타입 불변식을 훼손하기 쉽다.

- `비한정적 와일드 카드 타입`
제네릭 타입을 쓰고 싶지만 **실제 타입 매개변수가 무엇인지 신경쓰고 싶지 않을 때** 사용
ex ) `Set<?>`
```java
public static boolean sameSize(List<?> list1, List<?> list2) {
    return list1.size() == list2.size();
}

List<Integer> nums = Arrays.asList(1, 2, 3);
List<String> words = Arrays.asList("apple", "banana", "cherry");
System.out.println(sameSize(nums, words)); // true
```
- 제약 사항
	- **`Collection<?>`에는 `null` 외에는 어떤 원소도 넣을 수 없다. (읽기만 가능)**
		- 다른 원소를 넣으려고 하면 컴파일 에러가 난다.
	- 컬렉션 에서 꺼낼 수 있는 객체의 타입도 알 수 없다.
>  **컴파일러는 구체적인 타입 정보를 잊어버린다. 알 수 없는 타입으로 취급한다.**

> 위 제약사항을 받아들일 수 없다면 제네릭이나 한정적 와일드 카드 타입(? extends )를 사용하면 된다.

## raw type 사용해야하는 경우
### class 리터럴에는 raw 타입을 써야 한다.
- java 명세는 class 리터럴에 매개변수화 타입을 사용하지 못하게 했다.
	- 배열과 기본 타입은 허용한다.
- `List.class`, `String[].class`, `int.class`는 허용한다.
- `List<String>.class`나 `List<?>.class`는 허용하지 않는다.

### instanceof 연산자는 raw type이나 비한정적 와일드카드 타입에만 적용할 수 있다.
- 런타임에는 제네릭 타입 정보가 지워지고 `raw type`으로 변환된다.
- `instanceof` 연산자는 **객체의 타입을 런타임에 확인**하는 연산자이다.
	- 제네릭 타입 정보가 런타임에 소거되므로 특정 제네릭 타입인지 확인할 수 없다.
```java
List<String> stringList = new ArrayList<>();

// 컴파일 오류
if (stringList instanceof List<String>) {} 

// 가능하지만 경고
if (stringList instanceof List) {}

// 가능 (비한정적 와일드카드)
if (stringList instanceof List<?>) {}
```
raw type와 비한정적 와일드카드는 동일하게 동작하므로 차라리 raw type을 쓰는 것이 깔끔하다.
```java
if (o instanceof Set) { // 로 타입
	Set<?> s = (Set<?>) o; // 와일드카드 타입
}
```
> o의 타입이 Set임을 확인한 다음, 와일드카드 타입으로 형변환해야 한다.
> (검사 형변환이므로 컴파일러 경고가 뜨지 않는다.)


## 결론
- **raw type을 사용하면 런타임에 예외가 발생**할 수 있으므로 사용하면 안된다.
	- raw type은 제네릭이 도입하기 이전 코드와의 **호환성을 위해 제공**될 뿐이다.
- `Set<Object>`는 **어떤 타입의 객체도 저장할 수 있는 매개변수화 타입**이다.
- `Set<?>`는 **모종의 타입 객체만 저장할 수 있는 와일드카드 타입**이다.
- raw type인 `Set`는 제네릭 타입 시스템에 속하지는 않는다.
- `Set<Object>`와 `Set<?>`는 안전하지만, raw type인 `Set`은 안전하지 않다.
