## 요약

컨테이너 타입을 반환할 때 값이 없는 경우 

`null` 보다는 빈 컬렉션이나, 배열을 반환하는 것이 항상 좋다 

비어있는 컨테이너를 만드는 것은 문제가 되지 않음

- 성능 저하의 주범이라고 확인되지 않는 이상 이정도의 성능 차이는 신경 쓸 수준이 못된다
- 빈 컬렉션과 배열을 굳이 새로 할당하지 않고 만들수 있음

### 비어있는 컬렉션

```java
private final List<cheese> cheesesInStock = ....

public List<Cheese> getCheeses() {
	return new ArrayList<>(cheesesInStock);
}
// 일반적인 빈 컬렉션 반환 방법

public List<Cheese> getCheeses() {
	return cheesesInStock.isEmpty() ? Collections.emptyList() : new ArrayList<>(cheesesInStock);
}

// 컬렉션을 새로 할당하지 않는 방법 
```

- 자바에서 제공하는 `Collections.empryList()` `Collections.empryMap()` `Collections.emprySet()` 과 같은 비어있는 불변 컬렉션을 활용해도 좋다

### 길이가 0인 배열

```java
public Cheese[] getCheeses(){
	return CheesesInStock.toArray(new Cheese[0]);
}

private static final Cheese[] EMPTY_CHEESE_ARRAY = new Cheese[0];
```

- `toArray` 사용해서 길이 0인 배열에 관한 처리를 해줌
- 배열을 새로 만드는 게 마음에 안들면 길이 0 상수 배열을  미리 선언

```java
cheesesInStock.toArray([cheesesInStock.size()]);
```

- 성능 개선을 목적으로 배열의 사이즈를 미리 지정하는 건 추천하지 않음

> <T> T[] toArray(T[] a) 는  주어진 배열 a가 충분히 크다면 a 안에 원소를 담아 반환하고, 그렇지 않으면 T[] 타입 배열을 새로 만들어
> 그 안에 원소를 담아 반환한다. 따라서 길이 0인 배열을 주면 원소가 0개일 때는 그대로 반환하고, 원소가 있으면 원소를 담을 수 있는 배열을 새로 만들어 반환한다.
