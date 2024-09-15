# 58. 전통적인 for 문보다는 for-each 문을 사용하라
## 순회 방법
### 전통적인 for 문 - 컬렉션 순회
```java
for (Interator<Element> i = c.iterator(); i.hasNext();){
	Element e = i.next();
}
```

### 전통적인 for 문 - 배열 순회
```java
for (int i=0;i<a.length(); i++){

}
```
- while문보다는 낫지만 가장 좋은 방법은 아니다.
- 쓰이는 변수 종류가 늘어나면 변수를 잘못 사용할 틈새가 넓어진다.

## for-each 문
- 항상된 for 문이다.
- 반복자와 인덱스를 사용하지 않으니 코드가 깔끔해지고 오류가 날 일도 없다.
- 하나의 관용구로 컬렉션과 배열을 모두 처리할 수 있어서 어떤 컨테이너를 다루는지는 신경쓰지 않아도 된다.
```java
for (Element e: elements){

}
```
- 전통적인 for 문과 속도는 같다.
    - 손으로 최적화한 것과 같다.

## 컬렉션 중첩
### 전통적인 for 문 - 버그를 찾아보자
```java
public class Card {  
    private final Suit suit;  
    private final Rank rank;  
  
    // 버그를 찾아보자.  
    enum Suit { CLUB, DIAMOND, HEART, SPADE }  
    enum Rank { ACE, DEUCE, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT,  
        NINE, TEN, JACK, QUEEN, KING }  
  
    static Collection<Suit> suits = Arrays.asList(Suit.values());  
    static Collection<Rank> ranks = Arrays.asList(Rank.values());  
  
    Card(Suit suit, Rank rank ) {  
        this.suit = suit;  
        this.rank = rank;  
    }  
  
    public static void main(String[] args) {  
        List<Card> deck = new ArrayList<>();  
          
        for (Iterator<Suit> i = suits.iterator(); i.hasNext(); )  
            for (Iterator<Rank> j = ranks.iterator(); j.hasNext(); )  
                deck.add(new Card(i.next(), j.next()));
}
```
- 버그 : `i.next()`는 숫자당 한번씩만 불려야하는데, 내부 반복문에 호출되므로 카드 하나당 한번 호출되어 `NoSuchElementException`을 던진다.

#### 해결 : for -each 문
```java
// 코드 58-7 컬렉션이나 배열의 중첩 반복을 위한 권장 관용구 (349쪽)  
for (Suit suit : suits)  
    for (Rank rank : ranks)  
        deck.add(new Card(suit, rank));
```

### 전통적인 for 문 - 버그를 찾아보자 2
```java
// 코드 58-5 같은 버그, 다른 증상! (349쪽)  
public class DiceRolls {  
    enum Face { ONE, TWO, THREE, FOUR, FIVE, SIX }  
  
    public static void main(String[] args) {  
        // 같은 버그, 다른 증상!  
        Collection<Face> faces = EnumSet.allOf(Face.class);  
  
        for (Iterator<Face> i = faces.iterator(); i.hasNext(); )  
            for (Iterator<Face> j = faces.iterator(); j.hasNext(); )  
                System.out.println(i.next() + " " + j.next());  
  
        System.out.println("***************************");  
    }  
}
```
- 버그: 36가지를 출력해야하는데 `"ONE ONE"`부터 `"SIX SIX"` 단 6쌍만 출력하고 끝나버린다.
- 버그 발생을 파악하기 어렵다.

#### 해결 : for -each 문
```java
        // 컬렉션이나 배열의 중첩 반복을 위한 권장 관용구  
        for (Face f1 : faces)  
            for (Face f2 : faces)  
                System.out.println(f1 + " " + f2);  
```
- 코드도 간결하고 버그 작성 가능성도 줄어든다.

## for-each 문을 사용할 수 없는 상황
### 파괴적인 필터링
- **컬렉션을 순회하면서 선택된 원소를 제거**해야한다면 반복자의 `remove` 메서드를 호출해야 한다.
```java
List<Integer> numbers = new ArrayList<>(Arrays.asList(1, 2, 3, 4, 5, 6));
Iterator<Integer> iterator = numbers.iterator();
while (iterator.hasNext()) {
    int num = iterator.next();
    if (num % 2 == 0) {
        iterator.remove();
    }
}
System.out.println(numbers); // 출력: [1, 3, 5]
```
- `java 8` 부터는 컬렉션의 `removeIf` 메서드를 사용해 컬렉션을 명시적으로 순회하지 않아도 된다.
```java
List<Integer> numbers = new ArrayList<>(Arrays.asList(1, 2, 3, 4, 5, 6));
numbers.removeIf(num -> num % 2 == 0);
System.out.println(numbers); // 출력: [1, 3, 5]
```

### 변형
- 리스트나 배열을 순회하면서 **그 원소의 값 일부 혹은 전체를 교체**해야 한다면 리스트의 반복자나 배열의 인덱스를 사용해야 한다.
```java
List<String> words = new ArrayList<>(Arrays.asList("apple", "banana", "cherry"));
for (int i = 0; i < words.size(); i++) {
    words.set(i, words.get(i).toUpperCase());
}
System.out.println(words); // 출력: [APPLE, BANANA, CHERRY]
```

### 병렬 반복
- **여러 컬렉션을 병렬로 순회**해야 한다면 각각의 반복자와 인덱스 변수를 사용해 명시적으로 제어해야 한다.
```java
List<String> names = Arrays.asList("a", "b", "c");
List<Integer> ages = Arrays.asList(25, 30, 35);

for (int i = 0; i < names.size(); i++) {
    System.out.println(names.get(i) + " is " + ages.get(i) + " years old.");
}
// 출력:
// a is 25 years old.
// b is 30 years old.
// c is 35 years old.
```

## for-each 문 : Iterable 인터페이스
- for-each 문은 컬렉션과 배열은 물론 Iterable 인터페이스를 구현한 객체라면 무엇이든 순회할 수 있다.
- 원소들의 묶음을 표현하는 타입을 작성해야 한다면 Iterable 구현을 고려하자.

# 결론
- `전통적인 for 문`과 비교했을때 `for-each 문`은 명료하고, 유연하고, 버그를 예방해준다.
    - 성능 저하도 없다.
- 가능한 모든 곳에서 `for 문`이 아닌 `for-each` 문을 사용하자.
