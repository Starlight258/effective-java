# 54. null이 아닌, 빈 컬렉션이나 배열을 반환하라
## null을 반환하지 말자
- 컬렉션이 비었을때 `null`을 반환할 경우 클라이언트는 `null` 상황을 처리하는 코드를 추가로 작성해야한다.
```java
public List<Cheese> getCheeses(){
	return cheesesInStock.isEmpty() ? null 
		: new ArrayList<>(cheesesInStock);
}

List<Cheese> cheeses = shop.getCheeses();
if (cheeses != null && cheeses.contains(Cheese.STILTON)){
	System.out.println("Good");
}
```

### 빈 컬렉션을 반환하자
```java
public List<Cheese> getCheeses() {
	return new ArrayList<>(cheesesInStock);
}
```

#### 매번 똑같은 빈 불변 컬렉션을 반환할 수 있다.
- 매번 새로 빈 컬렉션을 할당할 필요가 없다.
- 불변 객체는 자유롭게 공유해도 안전하다.
    - `Collections.emptyList`
    - `Collections.emptySet`
    - `Collections.emptyMap`
```java
public List<Cheese> getCheeses(){
	return cheesesInStock.isEmpty() ? Collections.emptyList() 
		: new ArrayList<>(cheesesInStock);
}
```

### null 말고 길이가 0인 배열을 반환하자 (빈 배열 사용)
```java
private static final Cheese[] EMPTY_CHEESE_ARRAY = new Cheese[0];

public List<Cheese> getCheeses(){
	return cheesesInStock.toArray(EMPTY_CHEESE_ARRAY);
}
```
- 항상 같은 빈 배열을 재사용한다.
    - 길이가 0인 배열은 불변이므로 공유해도 된다.
- 만약 `cheesesInStock`이 비어있다면, `EMPTY_CHEESE_ARRAY`가 그대로 반환된다.
- `cheesesInStock`에 요소가 있다면, 그 크기에 맞는 새 배열이 생성되어 반환된다.

#### 배열을 미리 할당하면 성능이 나빠진다.
```java
public List<Cheese> getCheeses(){
	return cheesesInStock.toArray(new Cheese[cheesesInStock.size()]);
}
```
- 매번 새로운 배열을 할당한다.
- 단순히 성능 개선 목적이라면 toArray에 넘기는 배열을 미리 할당하는 것은 추천하지 않는다.
> 오히려 성능이 떨어진다는 연구 결과도 있다.

# 결론
- `null`이 아닌, `빈 배열`이나 `컬렉션`을 반환하라
    - `null`을 반환하는 api는 사용하기 어렵고, 오류 처리 코드도 늘어난ㄷ나.
    - 그렇다고 성능이 좋은 것도 아니다.
