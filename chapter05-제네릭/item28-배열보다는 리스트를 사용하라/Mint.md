# 28. 배열보다는 리스트를 사용하라
## 배열과 제네릭 타입의 차이
### 1. 배열은 공변이지만, 제네릭은 불공변이다.
- **공변**(함께 변한다) : Sub가 Super의 하위 타입이라면, 배열 Sub[]는 배열 Super[]의 하위 타입이다.
- **불공변** : 서로 다른 타입 Type1, Type2가 있을 때, `List<Type1>`은 `List<Type2>`의 하위 타입도 아니고 상위 타입도 아니다.
> 리스트를 포함한 컬렉션은 불공변
#### 공변은 문제를 가지고 있다.
- 배열이 공변이므로 런타임 에러가 발생할 수 있다.
```java
Object[] objectArray = new Long[1];
objectArray[0] = "타입이 달라 넣을 수 없다."; // ArrayStoreException
```
Long은 Object의 하위 타입이므로 Long[]도 Object[]의 하위 타입이다.
컴파일러는 objectArray를 Object[]로 보기 때문에, String을 대입해도 에러가 나지 않는다.
런타임에 JVM은 실제 배열이 Long[]임을 알기 때문에 에러를 던진다.

#### 리스트의 불공변은 타입 안전성을 컴파일 시간에 제공한다.
```java
List<Object> ol = new ArrayList<Long>(); // 경고
ol.add("타입이 달라 넣을 수 없다"); 
```
Long이 Object의 하위 타입이더라도 리스트는 불공변이므로 `List<Object>`에 `ArrayList<Long>`을 대입할 수 없다.
컴파일되지 않으므로 예외를 컴파일 시간에 알아챌 수 있다.

### 2. 배열은 실체화되지만, 제네릭은 실체화되지 않는다.
#### 배열은 실체화된다.
- 배열은 런타임에도 자신의 타입 정보를 유지한다.
- Long[]에 String을 대입하려고 할때 런타임에서 에러를 발생시킨다 (`ArrayStoreException`)

#### 제네릭은 타입 정보가 런타임에는 소거된다.
- **소거** : 제네릭이 지원되기 전의 레거시 코드와 제네릭 타입을 함께 사용할 수 있게 해주는 메커니즘 (런타임에서 타입 정보 제거)
- 원소 타입을 컴파일 시간에만 검사한다.

### 배열과 제네릭은 잘 어우러지지 못한다.
- 배열은 제네릭 타입, 매개변수화 타입, 타입 매개변수로 사용할 수 없다.
    - `new List<E>[]`, `new List<String>[]`, `new E[]` 로 작성하면 컴파일할 때 **제네릭 배열 생성 오류**를 일으킨다.
- 제네릭은 실체화 불가 타입이다.
    -  런타임에 타입 정보가 소거, 실체화되지 않아서 런타임에는 컴파일 타입보다 타입 정보를 적게 가지는 타입
    - `List<String>`은 런타임에서 그냥 `List`가 된다.

#### 제네릭 배열을 만들지 못하게 막는 이유
- 타입 안전하지 않는다.
    - 컴파일러가 자동 생성한 형변환 코드에서 런타임 에러가 발생할 수 있다.
    - 런타임에 `ClassCastException`이 발생하는 것을 막을 수 없다.
```java
List<String>[] stringLists = new List<String>[1];
List<Integer> intList = List.of(42);
Object[] objects = stringLists; // 공변이므로 okay
objects[0] = intList; // List[]에 List 대입(런타임에 타입 정보 소거)
String s = stringLists[0].get(0); // 런타임 에러
```
원소가 Integer인데 String으로 형변환하므로 런타임에 ClassCastException이 발생한다.
=> 이를 막기 위해 제네릭 배열을 만들지 못하도록 처음부터 컴파일 오류를 낸다.


#### 매개변수화 타입 가운데 실체화될 수 있는 타입은 비한정적 와일드카드(?) 타입이다.
- 모든 타입을 나타내는 `?` 가 실제로 `Object` 타입으로 대체되기 때문이다.
- 실체화 가능 타입
    - 원시 타입(`int`, `double`)
    - 비제네릭 타입(String, `Integer`)
    - 비한정적 와일드카드 타입 (`List<?>`)
    - raw type (`List`)
    - 제네릭 배열 타입의 요소가 실체화 가능 타입인 경우 (`List<?>[]`, `String[]`)
> `raw type`은 런타임에 타입 정보를 삭제하기 않고 모든 타입 매개변수를 `Object`로 대체한다.
> `List`는 런타임에 `List<Object>`와 유사하게 취급된다.

#### 배열을 제네릭으로 만들 수 없다.
- 제네릭 컬렉션에서는 자신의 원소 타입을 담은 배열을 반환하는게 보통 불가능하다.
- 제네릭 타입과 가변인수 메서드를 함께 쓰면 경고 메세지를 받게 된다.
    - 가변 인수 메서드를 호출할 때마다 가변인수 매개변수를 담을 배열이 만들어지는데, 그 배열의 원소가 실체화 불가 타입이기 때문이다.
    - `@SafeVarags` 어노테이션으로 대체할 수 있다.

## 배열로 형변환할 때 **제네릭 배열 생성 오류**나 **비검사 형변환 경고**가 뜨는 경우 배열 `E[]` 대신 컬렉션인 `List<E>`를 사용하면 해결된다.
- 배열은 공변이며 런타임에 타입을 체크한다.
    - 제네릭 배열을 허용하지 않는다.
- 컬렉션은 불공변이며 컴파일 시간에 타입 정보를 체크한다.
    - 제네릭 타입 파라미터를 사용할 수 있으며, 타입 안전성을 컴파일 시간에 보장한다.

### 비검사 형변환 경고는 컬렉션을 사용하면 해결된다.
**비검사 형변환 경고** : 제네릭 타입을 사용할 때 발생하며, 컴파일러가 런타임에 타입 안전성을 체크할 수 없는 상황에서 발생한다.
타입 소거로 인해 런타임에 제네릭 타입 정보가 소실되어 발생한다.

#### 배열 사용시 비검사 형변환 경고 발생하는 경우
```java
public class Stack<E> {
    private E[] elements;
    
    @SuppressWarnings("unchecked")
    public Stack(int capacity) {
        elements = (E[]) new Object[capacity];  // 비검사 형변환 경고
    }
}
```
- 컴파일러는 위 형변환이 런타임에도 안전한지 보장할 수 없으므로 경고를 발생한다.
    - 런타임에 제네릭은 타입 정보가 소거되기 때문이다.
- `Object[]`는 어떤 타입의 객체이든 넣을 수 있고, 어떤 타입으로도 캐스팅할 수 있다.
- `Object[]`는 `E[]`로 캐스팅될 수 있지만(공변성), 후에 배열에 `E`가 아닌 객체를 넣으려고 하면 `ArrayStoreException`이 발생할 수 있다.
- 또한 배열에서 요소를 꺼내 E로 사용할 때 `ClassCastException`이 발생할 수 있다.
> 런타임에서 타입 정보가 소거되므로 E[]로 캐스팅시 위와 같은 에러가 발생할 수 있음을 경고한다.

#### 리스트는 **타입 안전성**을 보장하므로 비검사 형변환 경고가 발생되지 않는다.
```java
public class Stack<E> {
    private List<E> elements;
    
    public Stack(int capacity) {
        elements = new ArrayList<>(capacity); // 경고 없음
    }

    public void push(E item) {
        elements.add(item);
    }
}
```
- 제네릭 타입 `E`가 컬렉션 생성시 명시되어, 별도의 형변환이 필요 없다.
    - `List<String>`은 String 타입만 추가할 수 있다.
- 컬렉션 사용시 컴파일러가 **타입 안전성을 보장**할 수 있고, 런타임시 타입 소거 후에도 `List<E>`는 안전하게 `Object`를 저장하고 반환한다.
> 컬렉션을 사용하면 형변환이 필요 없다.

```java
// 코드 28-6 리스트 기반 Chooser - 타입 안전성 확보! (168쪽)  
public class Chooser<T> {  
    private final List<T> choiceList;  
  
    public Chooser(Collection<T> choices) {  
        choiceList = new ArrayList<>(choices);  
    }  
  
    public T choose() {  
        Random rnd = ThreadLocalRandom.current();  
        return choiceList.get(rnd.nextInt(choiceList.size()));  
    }  
  
    public static void main(String[] args) {  
        List<Integer> intList = List.of(1, 2, 3, 4, 5, 6);  
  
        Chooser<Integer> chooser = new Chooser<>(intList);  
  
        for (int i = 0; i < 10; i++) {  
            Number choice = chooser.choose();  
            System.out.println(choice);  
        }  
    }  
}
```

## 결론
- 배열은 공변이고 실체화되는 반면, 제네릭은 불공변이고 타입 정보가 소거된다.
    - 배열은 런타임에는 타입 안전하지만 컴파일 타입에는 그렇지 않다.
    - 제네릭은 컴파일 타입에는 타입 안전하지만 런타임에는 그렇지 않다.
      배열
    - 컴파일 타임: 안전하지 않음
      ```java
      Object[] arr = new Long[1];
      arr[0] = "문자열"; // 컴파일 시 오류 없음
      ```
    - 런타임: 안전함
      ```java
      // 위 코드 실행 시 ArrayStoreException 발생
      ```
>  컴파일 시 타입 불일치를 허용하지만, 런타임에 실제 타입을 확인하여 오류를 발생시킨다.

제네릭
- 컴파일 타임: 안전함
  ```java
  List<String> list = new ArrayList<>();
  list.add("문자열");
  // list.add(10); // 컴파일 오류
  ```
- 런타임: 타입 정보 소실
  ```java
  // 런타임에는 List<String>이 그냥 List가 됨
  ```

> 컴파일 시 엄격한 타입 검사를 수행하지만, 런타임에는 타입 정보가 소거되어 검사할 수 없다.

제네릭은 타입 안전성을 확보한다.
- 배열: 런타임 오류 가능성이 있어 예기치 않은 동작이 발생할 수 있다.
- 제네릭: **컴파일 시 대부분의 타입 오류를 잡아내어 안전하다.**

- 배열과 제네릭을 섞어쓰는 것은 쉽지 않다.
    - 둘을 섞어 쓰다가 컴파일 오류나 경고를 만나면, **가장 먼저 배열을 리스트로 대체해보자.**
