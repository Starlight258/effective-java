# 60. 정확한 답이 필요하다면 `float`와 `double`은 피하라
### float과 double
- `float`과 `double` 타입은 과학과 공학 계산용으로 설계되었다.
    - 이진 부동소수점 연산에 쓰인다.
    - 넓은 범위의 수를 빠르게 정밀한 `근사치`로 계산하도록 설계된다.
#### 잔돈 구하는 코드 - 버그 O
```java
public class Change {  
    // 코드 60-1 오류 발생! 금융 계산에 부동소수 타입을 사용했다. (356쪽)  
    public static void main(String[] args) {  
        double funds = 1.00;  
        int itemsBought = 0;  
        for (double price = 0.10; funds >= price; price += 0.10) {  
            funds -= price;  
            itemsBought++;  
        }  
        System.out.println(itemsBought + "개 구입");  
        System.out.println("잔돈(달러): " + funds);  
    }  
}
```
- 잔돈은 0.399999...9 달러로 잘못된 결과가 나온다.

# 금융 계산에는 BigDecimal, int 혹은 long을 사용해야 한다.
### BigDecimal
#### 잔돈 구하는 코드 (BigDecimal, 버그 X)
```java
public class BigDecimalChange {  
    // 코드 60-2 BigDecimal을 사용한 해법. 속도가 느리고 쓰기 불편하다. (356쪽)  
    public static void main(String[] args) {  
        final BigDecimal TEN_CENTS = new BigDecimal(".10");  
  
        int itemsBought = 0;  
        BigDecimal funds = new BigDecimal("1.00");  
        for (BigDecimal price = TEN_CENTS;  
             funds.compareTo(price) >= 0;  
             price = price.add(TEN_CENTS)) {  
            funds = funds.subtract(price);  
            itemsBought++;  
        }  
        System.out.println(itemsBought + "개 구입");  
        System.out.println("잔돈(달러): " + funds);  
    }  
}
```
- 올바른 답이 나온다.

#### BigDecimal 단점
- 기본 타입보다 쓰기 훨씬 불편하고 훨씬 느리다.

### int, long 사용하기
```java
public class IntChange {  
    // 코드 60-3 정수 타입을 사용한 해법 (357쪽)  
    public static void main(String[] args) {  
        int itemsBought = 0;  
        int funds = 100;  
        for (int price = 10; funds >= price; price += 10) {  
            funds -= price;  
            itemsBought++;  
        }  
        System.out.println(itemsBought + "개 구입");  
        System.out.println("잔돈(센트): " + funds);  
    }  
}
```
- 모든 계산을 달러 대신 센트로 수행하면 된다.

#### int, long 단점
- int, long은 다룰 수 있는 값의 크기가 제한되고, 소수점을 직접 관리해야한다.

# 결론
- 정확한 답이 필요한 계산에는 `float`과 `double`을 피하라
- 소수점 추적은 시스템에 맡기고, 코딩 시의 불편함과 성능 저하를 신경 쓰지 않겠다면 `BigDecimal`을 사용하라
- 성능이 중요하고 소수점을 직접 추적할 수 있고 숫자가 너무 크지 않다면 `int`나 `long`을 사용하라
    - 숫자를 `9자리 십진수`로 표현 가능하다면 `int`
    - 숫자를 `18자리 십진수`로 표현 가능하다면 `long`
    - `18자리`를 넘어가면 `BigDecimal`
