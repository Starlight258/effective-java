## 요약

### 금융과 관련된 계산에는 float 나 double 타입은 적합하지 않다 
- 넓은 범위의 수를 빠르게, 정밀한 근사치로 계산하도록 설계되었다
- 따라서 정확한 결과가 필요할 때는 사용하면 안 된다 

### 금융 계산해서는 BigDecimal, int 혹은 long 을 사용해야 한다

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
- `BigDecimal` 은 기본 타입보다 쓰기가 불편하고 훨씬 느리다

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
- 기본 타입은 다룰 수 있는 값의 크기가 제한되고 소수점을 직접 관리해야 한다 