# 61. 박싱된 기본 타입보다는 기본 타입을 사용하라
## java의 데이터 타입
- `기본 타입` : `int`, `double`, `boolean`, ...
- `참조 타입` : `Integer`, `Double`, `Boolean`, ...
    - 각각의 기본 타입에는 대응하는 참조 타입이 하나씩 있다.
    - `박싱된 기본 타입`이라고 한다.

### 오토박싱과 오토언박싱
- `오토박싱`: 기본 타입의 값을 해당하는 래퍼 클래스의 객체로 자동 변환
    - ex) int → Integer, double → Double, boolean → Boolean
- `오토언박싱`: 래퍼 클래스의 객체를 해당하는 기본 타입의 값으로 자동 변환
    - ex) Integer → int, Double → double, Boolean → boolean
- 오토박싱과 오토언박싱 덕분에 두 타입을 크게 구분하지 않고 사용할 수 있다.
```java
Integer num = 100; // 오토박싱: int → Integer
int value = num;   // 오토언박싱: Integer → int

List<Integer> numbers = new ArrayList<>();
numbers.add(5);    // 오토박싱: int → Integer
int five = numbers.get(0); // 오토언박싱: Integer → int
```

### 기본 타입 vs 박싱된 기본 타입
- `기본 타입`은 값만 가지고 있으나, `박싱된 기본 타입`은 값에 더해 **식별성**(identity) 속성을 가진다.
    - 박싱된 기본 타입의 **두 인스턴스는 값이 같아도 서로 다르다고 식별**될 수 있다.
- `기본 타입`의 값은 언제나 유효하나, `박싱된 기본 타입`은 유효하지 않은 값, 즉 `null`을 가질 수 있다.
- `기본 타입`이 `박싱된 기본 타입`보다 **시간과 메모리 사용면에서 더 효율적이다.**

## 박싱된 기본 타입은 주의해서 사용해아한다.
#### 잘못 구현된 비교자
```java
Comparator<Integer> naturalOrder =  
        (i, j) -> (i < j) ? -1 : (i == j ? 0 : 1);
```
- `naturalOrder.compare(new Integer(42), new Integer(42));` 는 0이 아닌 1을 출력한다.
    - `i==j`에서 두 객체 참조의 `식별성 검사`할 때 값은 같아도 서로 다른 인스턴스이므로 `false`를 반환하기 때문이다.
> 박싱된 기본 타입에 == 연산자를 사용하면 오류가 발생한다.

#### 비교는 기본 타입 변수로 수행
```java
// 코드 61-2 문제를 수정한 비교자 (359쪽)  
 Comparator<Integer> naturalOrder = (iBoxed, jBoxed) -> {  
     int i = iBoxed, j = jBoxed; // 오토박싱  
     return i < j ? -1 : (i == j ? 0 : 1);  
 };  
  
 int result = naturalOrder.compare(new Integer(42), new Integer(42));  
 System.out.println(result);
```
- 기본 타입으로 비교하면 식별성 검사가 이뤄지지 않는다.
- 기본 타입 비교시 `Comparator.naturalOrder()`를 사용하자.
    - String, Integer, Double 등 Comparable을 구현한 클래스에 사용 가능하다.
- 비교자를 직접 만들면 `비교자 생성 메서드`나 기본 타입을 받는 `정적 compare 메서드`를 사용해야 한다.

### 기본 타입과 박싱된 기본 타입 혼용 연산에서는 박싱된 기본 타입이 오토언박싱된다.
#### NullPointerException 발생 코드
```java
// 코드 61-3 기이하게 동작하는 프로그램 - 결과를 맞혀보자! (360쪽)  
public class Unbelievable {  
    static Integer i;  
  
    public static void main(String[] args) {  
        if (i == 42)  
            System.out.println("믿을 수 없군!");  
    }  
}
```
- Integer의 초기값은 null이므로 null 참조를 언박싱하면 `NullPointerException`이 발생한다.

#### 박싱과 언박싱이 반복해서 일어나 성능이 느린 코드
```java
public static void main(String[] args) {  
		Long sum = 0L;
		for (long i = 0;i<=Integer.MAX_VALUE;i++){
			sum += i;
		}
        System.out.println(sum);    
    } 
```
- 성능 문제가 발생한다.
    - `sum`(Long)을 언박싱하여 기본 타입 `long`으로 변환 후 `i`(long)와 더하기 연산 수행
    - 결과를 다시 `Long` 객체로 박싱하여 새로 생성된 `Long` 객체를 `sum`에 할당

#### long으로 변수 선언하여 해결
```java
public static void main(String[] args) {  
    long sum = 0L;  // Long 대신 long 사용
    for (long i = 0; i <= Integer.MAX_VALUE; i++) {
        sum += i;
    }
    System.out.println(sum);    
}
```
> 가능하면 기본 타입을 사용하자

## 박싱된 기본 타입을 사용해야하는 경우
- `컬렉션의 원소, 키, 값`으로 사용한다,
    - 컬렉션은 기본 타입을 담을 수 없기 때문이다.
```java
List<Integer> numbers = new ArrayList<>();  
Map<String, Double> scores = new HashMap<>(); 
```
- `매개변수화 타입`이나 `매개변수화 메서드의 타입 매개변수`에도 사용한다.
```java
public class Box<T> {  
    private T value;
}

public <T> void printArray(T[] array) { 
}
```
- `리플렉션`을 통해 메서드를 호출할 때도 박싱된 기본 타입을 사용해야 한다.
```java
Method method = MyClass.class.getMethod("myMethod", Integer.class);  
method.invoke(obj, Integer.valueOf(42));  
```

# 결론
- `기본 타입`과 `박싱된 기본 타입` 중 가능하면 `기본 타입`을 사용하자.
    - `기본 타입`은 간단하고 빠르다.
- `박싱된 기본 타입`을 사용한다면 주의를 기울이자.
    - 오토박싱이 번거로움은 줄여주지만 위험성이 존재한다.
    - 두 박싱된 기본 타입을 = = 으로 비교한다면 식별자 비교가 일어난다
- 같은 연산에서 `기본 타입`과 `박싱된 기본 타입`을 혼용하면 언박싱이 이뤄지며, 언박싱 과정에서 `NullPointerException`을 던질 수 있다.
- 기본 타입을 박싱하는 작업은 필요 없는 객체를 생성하는 부작용을 나을 수 있다.



