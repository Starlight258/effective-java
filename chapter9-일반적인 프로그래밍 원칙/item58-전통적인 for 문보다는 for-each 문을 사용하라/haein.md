## 요약

### for-each: enhanced for statement
- 컬렉션의 원소에만 관심이 있는데 불필요하게 반복자와 인덱스를 사용하지 않아 오류를 줄이고 코드를 깔끔하게 만든다

```java
    public static void main(String[] args) {
        List<Card> deck = new ArrayList<>();
        
        for (Iterator<Suit> i = suits.iterator(); i.hasNext(); )
            for (Iterator<Rank> j = ranks.iterator(); j.hasNext(); )
                deck.add(new Card(i.next(), j.next()));
```
- 이 코드는 `NoSuchElementException` 이 발생할 수 있다 
- 원래 의도는 `Suit` 하나 당 반복하는 것인데 `Rank`  하나 당 반복하고 있다
- 만약 바깥 컬렉션의 크기가 안쪽 컬렉션 크기의 배수라면 예외조차 던지지 않고 종료된다 
- 향상된 for-each 문을 사용하면 깔끔하게 처리할 수 있다


```java
        for (Suit suit : suits)
            for (Rank rank : ranks)
                deck.add(new Card(suit, rank));
```

### for-each 문을 사용할 수 없는 상황

- **파괴적인 필터링**
    - 컬렉션을 순회하면서 선택된 원소를 제거해야 하는 경우
    - 자바 8부터 Collection.removeIf()를 사용해 컬렉션을 명시적으로 순회하는 일을 피할 수 있다.
- **변형**
    - 리스트나 배열을 순회하며, 그 원소의 값 일부/전체를 교체해야 하는 경우
    - 리스트 반복자나 배열 인덱스를 사용해야 함
- **병렬 반복**
    - 여러 컬렉션을 병렬로 순회해야 하는 경우
    - 각각의 반복자와 인덱스 변수로 엄격하고, 명시적으로 제어해야 한다