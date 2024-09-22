
## ✍️ 개념의 배경

### Comparable 인터페이스

**`Comparable`** 인터페이스는 Java에서 구현되는 인터페이스 중 하나로, 객체의 ***자연 순서(natural order)**를 정의하는 데 사용된다. 이 인터페이스를 구현하는 클래스는 `Arrays.sort(a)`와 같은 방식으로 해당 클래스의 인스턴스를 정렬할 수 있다.

```java

Arrays.sort(array, new Comparator<int[]>() {
    // Override된 compare 함수를 어떻게 정의하냐에 따라서 다양한 정렬이 가능함
    @Override
    public int compare(int[] o1, int[] o2) {
        return o1[0] - o2[0];
        // 내림차순 정렬을 하고 싶다면 o2와 o1의 위치를 바꿔줌
        // return o2[0] - o1[0];
    }
});
// 출처: https://ykh6242.tistory.com/entry/Comparator를-이용한-Array와-List의-정렬
```

---

** 자연 순서: 객체들을 비교하거나 정렬할 때 해당 객체들이 가지고 있는 내재적인 순서를 나타낸다. 이 순서는 객체 자체의 속성이나 값에 의해 결정된다. (예를 들자면, 정수 숫자의 경우 자연 순서는 수의 크기에 따라, 문자열의 경우, 유니코드 코드 포인트 순서 또는 사전순으로 정렬, 사용자가 정의한 클래스의 경우, 해당 클래스에서 **`Comparable`** 인터페이스를 구현하여 객체 간의 비교 방법을 정의할 수 있다.)*

그리고 이 **`Comparable`** 인터페이스는 오직 **`compareTo**()` 메서드만을 가지고 있다. 모든 값 클래스들과 열거 타입이 `Comparable`을 구현했으므로 해당 메서드를 사용할 수 있다. 비교를 위하여서는 `Comparable`을 상속받아 구현하는 것이 좋다.

### compareTo 메서드

**`compareTo`**는 Object의 `equals`와 두가지 포인트를 제외하면 동일하다. 

- 순서를 비교할 수 있다. 따라서 Comparable을 구현했다는 것은 자연적인 순서가 있음을 뜻한다.
- 제네릭하다. 즉 `Comparable`이 생성될 때 데이터 타입을 지정할 수 있다.

```java
public interface Comparable<T> {
	int compareTo(T t);
}
```

# 요약: compareTo에 관하여

---

### compareTo의 규약

`equals`와 비슷하다. 주어진 객체와 지금 객체의 순서를 비교하여 지금 객체가 작으면 음의 정수, 같으면 0, 크면 양의 정수를 반환한다. 비교할 수 없는 객체가 주어지면 **`ClassCastException`**을 던진다. 따라서 타입이 다른 객체를 신경 쓰지 않아도 된다.

> **1. 모든 x, y에 대해 `sgn(x.compareTo(y)) == -sgn(y.compareTo(x))`**
> 

두 객체 참조의 순서를 바꾸어도 예상한 결과가 나와야한다는 뜻이다. 대칭성을 충족해야한다.

> **2. `x.compareTo(y) > 0 && y.compareTo(z) > 0` 면 `x.compareTo(z) > 0`**
> 

equals 규약과 같이, 추이성을 충족해야한다. 

> **3. 모든 z에 대해 `x.compareTo(y) == 0`이면 `sgn(x.compareTo(z)) == sgn(y.compareTo(z))`**
> 

반사성을 충족한다고 한다. x = y일 경우 어떤 다른 객체와 비교해도 결과 값이 같아야한다. 

> [**4. (필수 아님) `x.compareTo(y) == 0` == `x.equals(y)`**](https://www.notion.so/14-Comparable-07019851dcdc4d89954b2b834e4a9c8f?pvs=21)
> 

**필수는 아니지만** 잘 지키게 되면 compareTo 결과의 순서와 equals의 결과가 일관되게 된다. 만약 일관되지 않으면, 클래스가 동작은 하지만 정렬된 컬렉션에 넣으면 해당 컬렉션의 동작과 다르게 작동하게된다. 정렬된 컬렉션은 compareTo를 사용하기 때문이다. ex. BigDecimal

---

### compareTo 작성요령

compareTo 메서드의 인수 타입은 컴파일 타임에 정해지므로, 입력 인수의 타입을 확인하거나 형변환할 필요가 없다. equals 처럼 Object를 인자로 받지 않기 때문이다. null 을 집어넣었다면 NullPointerException이 던져진다. 

 

1. **클래스 참조는 같은 클래스 참조랑만 비교가 가능하다.**

```java
public final class CaseInsensitiveString 
					implements Comparable<**CaseInsensitiveString**> { 
	public int compareTo(CaseInsensitiveString cis){
		return String.CASE_INSENSITIVE_ORDER.compare(s, cis.s);
	}
} // CaseInsensitiveString 참조는 CaseInsensitiveString 참조랑만 비교가 가능하다.
```

---

1. **박싱된 기본 타입 클래스들에 새로 추가된 정적 메서드인 `compare`를 사용하라**

기존에는 정수 기본 타입 필드 비교 시 < 혹은 >을 사용해야했는데, 자바 7부터는 박싱된 (ex. Integer) 기본 타입 클래스들에 compare가 생겼다. 

---

1. **객체 참조 필드를 비교하려면 `compareTo`를 재귀적으로 호출한다.** 클래스에 핵심 필드가 여러개라면 가장 핵심적 필드부터 비교한다. 비교 결과 0이 아니면, 결과를 곧장 반환하고 가장 핵심이 되는 필드가 똑같으면 그보다 덜 중요한 필드를 비교한다. 

```java
public class Person implements Comparable<Person> {
    private String name;
    private int age;

    public Person(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public int compareTo(Person otherPerson) {
        // 이름 비교
        int nameComparison = this.name.compareTo(otherPerson.name);
        if (nameComparison != 0) {
            return nameComparison;
        }
        
        // 이름이 같다면 나이 비교
        return Integer.compare(this.age, otherPerson.age);
    }
}
```

---

1. **Comparator 인터페이스로 3을 구현해볼 수 있다.** 

만일 Comparable을 구현하지 않은 필드나 표준이 아닌 순서로 비교해야하면 자바 8에서부터 나온 Comparator를 사용한다. 그러나 그것이 아니더라도 편해서 이를 사용할 수도 있다.

```java
private static final Comparator<PhoneNumber> COMPARATOR = 
	comparingInt((PhoneNumber pn) -> pn.areaCode) // Comparator<PhoneNumber> 반환
			.thenComparingInt(pn->pn.prefix) /
			.thenComparingInt(pn->pn.lineNum);

public int compareTo(PhoneNumber pn){
	return COMPARATOR.compare(this.pn);
}
```

 일련의 비교자 생성 메서드인 `comparingInt`, `thenComparingInt`를 사용하여 메서드 연쇄 방식으로 비교자를 생성한다. 그러나 이는 성능 저하를 주의해야한다. 

`comparingInt` 를 사용할 때는 java가 타입 추론을 할 수 없어서 앞에 PhoneNumber 타입을 적어주어 Comparator<PhoneNumber> 반환을 시켰고, `thenComparingInt` 부터는 타입을 추론할 수 있어 굳이 적지 않았다. 

`comparingInt`, `thenComparingInt` 외에 기본 숫자 타입 메서드들과, 객체 참조용 비교자 생성 메서드도 존재한다. (`comparing`, `thenComparing`)

---

1. **일방적으로 값의 차를 이용한 비교를 할 때는 주의해야한다.**

아래는 해시 코드 값의 차를 기준으로 하는 비교자다. 

```java
static Comparator<Object> hashCodeOrder = new Comparator<>() {
	public int compare(Object o1, Object o2){
		return o1.hashCode() - o2.hashCode();
	}
}
```

이는 그러나 정수 오버 플로우 혹은 [부동 소수점 계산방식에 따른 오류](https://www.notion.so/14-Comparable-07019851dcdc4d89954b2b834e4a9c8f?pvs=21)를 낼 수 있고, 그렇게 빠르지도 않다. 이는 그리고 규약들 중 결과값이 상황에 따라 다르게 나올 수 있기 때문에 추이성을 위배한다. 따라서 아래 두가지 중 하나로 대체해야한다. 

```java
// 1번 방법
static Comparator<Object> hashCodeOrder = new Comparator<>() {
	public int compare(Object o1, Object o2){
		return Integer.compare(o1.hashCode(), o2.hashCode());
	}
}

// 2번 방법
static Comparator<Object> hashCodeOrder = Comparator.comparingInt(o->o.hashCode());

```