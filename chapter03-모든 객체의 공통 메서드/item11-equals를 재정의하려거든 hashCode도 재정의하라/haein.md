## ✍️ 개념의 배경

hashCode 의 일반 규약

- `equals` 비교에 사용되는 정보가 변경되지 않았다면, 어플리케이션이 실행되는 동안 그 객체의 `hashCode` 메소드는 몇 번을 호출해도 일관되게 항상 같은 값을 반환해야 한다.(단, 애플리케이션을 다시 실행한다면 이 값이 달라져도 상관없다.)
- `equals(Object)`가 두 객체를 같다고 판단했다면, `hashCode`는 똑같은 값을 반환해야 한다.
- `equals(Object)`가 두 객체를 다르다고 판단했더라도, `hashCode`가 서로 다른 값을 반환할 필요는 없다. **단, 다른 객체에 대해서는 다른 값을 반환해야 해시테이블의 성능이 좋아진다.**


해시 테이블

- 해시 테이블은 key 마다 해시 함수를 적용한 인덱스를 생성하여 이를 bucket 에 저장한다.
- 자바에서는 Object 에 구현된 hashcode() 메소드를 사용하여 해시 함수의 결과를 생성해줄 수 있다.
- 해시 테이블(아니면 HashMap) 은 객체의 hashcode() 를 사용하여 객체의 동등성을 판단한다.

# 요약

---

### 문제상황

```java
public final class PhoneNumber {
    private final short areaCode, prefix, lineNum;

    public PhoneNumber(int areaCode, int prefix, int lineNum) {
        this.areaCode = rangeCheck(areaCode, 999, "area code");
        this.prefix   = rangeCheck(prefix,   999, "prefix");
        this.lineNum  = rangeCheck(lineNum, 9999, "line num");
    }

Map<PhoneNumber, String> m = new HashMap<>();
m.put(new PhoneNumber(707, 867, 5309), "제니");
System.out.println(m.get(new PhoneNumber(707, 867, 5309))); // null;
```

- 2개의 PhonwNumber 인스턴스가 논리적으로는 같지만(equals 재정의 가정) hashcode() 를 재정의하지 않았기 때문에, HashMap 이 적절한 bucket 을 찾지 못했다.
- 이 문제를 해결할 수 있는 방법을 고민해보자.

### 적법한 최악

```java
@override
public int hashcode(){
	return 42;
} 
```

- 논리적으로 동등한 모든 객체에게 같은 해시코드를 반환하므로 동등하다.
- 하지만 모든 객체가 하나의 bucket 에 담기는 문제가 있다.
- 이는 시간복잡도를 O(n) 까지 증가시킬 수 있다.

### hashCode를 잘 작성하는 요령

1. int 변수 result를 선언한 후 값 c로 초기화한다. 이때 c는 해당 객체의 첫번째 핵심 필드를 다음 소개하는 2.a 방식으로 계산한 해시코드이다. 참고로 여기 소개되는 핵심 필드는 equals 비교에 사용되는 필드이다. **equals에서 사용되지 않는 필드는 반드시 hashCode에서도 제외해야한다.** 이를 어기면 hashCode의 두번째 규약을 어기기 때문이다.
2. 해당 객체의 나머지 핵심 필드 f에 대해 각각 다음 작업을 수행한다.
    
    a. 필드의 해시코드 c를 계산한다.
    
    - 기본 필드라면 Type.hashCode(f)를 수행한다. 이때 Type은 기본 타입에 매핑되는 래퍼 타입이다.
    - 참조 필드이면서 클래스의 equals가 이 필드의 equals를 재귀적으로 호출해 비교한다면 이 필드의 hashCode가 재귀적으로 호출한다. 계산이 더 복잡해질 것 같으면, 표준형(Canonical Type)을 만들어 그 표준형의 hashCode를 호출한다. 만약 필드의 값이 `null`이면 0을 반환한다.
    - 배열이라면 핵심 원소 각각을 별도의 필드로 나눈다. 별도로 나눈 필드를 위 규칙을 적용하여 해시코드를 계산한 후 다음 소개되는 2.b 방식으로 갱신한다. 배열에 핵심 원소가 하나도 없다면, 0을 추천한다. 모든 원소가 핵심이라면 `Arrays.hashCode`를 이용한다.
    
    b. 2.a로 계산한 해시코드 c로 result를 갱신한다.
    
    ```java
    public int hashCode() {
        int result = Integer.hashCode(x);
        result = 31 * result + Integer.hashCode(y);
        return result;
    }
    ```
    
- 31은 소수이면서 홀수이므로 오버플로에 안전하다.
- 다른 필드로부터 계산해낼 수 있는 파생 필드는 무시한다.
- `equals` 비교에 사용되지 않은 필드는 **반드시** 제외한다.

### 전형적인 hashCode 메소드

```java
    @Override public int hashCode() {
        int result = Short.hashCode(areaCode);
        result = 31 * result + Short.hashCode(prefix);
      result = 31 * result + Short.hashCode(lineNum);
      return result;
}
```

### 성능에 민감하지 않다면 사용해보자

```java
   @Override public int hashCode() {
       return Objects.hash(lineNum, prefix, areaCode);
}
```

- 입력 인수를 담기 위한 배열이 만들어짐
- 입력 중 기본 타입이 있다면 박싱과 언박싱도 거친다. 속도가 느리다.

### 해시 코드를 계산하는 비용 줄이기

- 클래스가 불변일 때, 해시 코드를 계산하는 비용이 큰 경우
- 클래스의 객체가 주로 해시의 키로 사용될 것 같다면 인스턴스가 만들어질 때 해시코드를 계산해둬야 한다.
- 키로 사용되지 않는다면 hashCode가 처음 호출될 때 계산하는 지연 초기화(lazy initialization) 전략을 사용해볼 수 있다.
- hashCode 필드의 초깃값은 흔히 생성되는 객체의 초깃값과는 달라야 한다.

```java
    private int hashCode; // 자동으로 0으로 초기화된다.
    @Override public int hashCode() {
       int result = hashCode;
       if (result == 0) {
            result = Short.hashCode(areaCode);
           result = 31 * result + Short.hashCode(prefix);
           result = 31 * result + Short.hashCode(lineNum);
           hashCode = result;
       }
        return result;
    }
```

### 주의할 점

- 해시코드를 계산할 때 핵심 필드를 생략해서는 안 된다.
    - 연산은 빨라질 수 있지만 해시테이블의 성능을 심각하게 떨어트릴 수 있다.
    - 자바 2 이전의 String은 최대 16개의 문자로 해시코드를 계산했는데 URL과 같이 비슷한 문자열을 대량으로 사용할 때 성능이 쉽게 저하될 수 있다.
- hashCode 생성 규칙을 API 사용자에게 자세히 공표하지 말자
    - 추후에 hashCode 생성 규칙이 변경될 수 있으니 사용자가 hashCode의 값에 의지하지 않도록 만들어야 한다.
    - 해시 성능을 개선하기 위해 해시코드 생성 규칙은 얼마든지 바뀔 수 있다.


