# 51. 메서드 시그니처를 신중히 설계하라
### 메서드 이름을 신중하게 짓자
- 항상 표준 명명 규칙을 따라야한다.
    - 이해할 수 있고, 같은 패키지에 속한 다른 이름들과 일관되게 짓자
    - 개발자 커뮤니티에서 널리 받아들여지는 이름을 사용하자
    - 긴 이름은 피하자

### 편의 메서드를 너무 많이 만들지 말자
- 메서드가 너무 많으면 익히기 힘들다
- 확신이 서지 않으면 만들지 말자

### 매개변수 목록은 짧게 유지하자
- `4개 이하`가 좋다.
- 4개가 넘어가면 매개변수를 모두 기억하기 어렵다.
    - 같은 타입의 매개변수가 연달아 나오는 경우가 특히 해롭다.

#### 매개변수를 짧게 유지하는 기술
- 1. **여러 메서드로 쪼개자**
    - 메서드 수가 많아질 수 있지만, 직교성을 높여 오히려 메서드 수를 줄여주는 효과도 있다.
```java
/**
 * 주어진 요소의 첫 번째 출현 이후의 모든 요소를 반환한다.
 */
public List<E> subListAfter(E element) {
	int index = indexOf(element);
	return index >= 0 ? subList(index + 1, size()) : new ArrayList<>();
}
```
>`subList`와 `indexOf` 를 조합

- 2. **매개변수 여러개를 묶어주는 `도우미 클래스`를 만들자**
    - 도우미 클래스는 일반적으로 정적 멤버 클래스로 둔다.
    - 매개변수 몇개를 독립된 하나의 개념으로 두어 주고받으면 내부 구현도 깔끔해진다.
      기존 코드
```java
public class OrderProcessingSystem {
    public void processOrder(String customerId, String productId, int quantity, 
                             String shippingAddress, String paymentMethod) {
    }
}
```
개선한 코드
```java
// 도우미 클래스를 사용하여 개선된 주문 처리 메서드
public void processOrder(OrderDetails orderDetails, ShippingInfo shippingInfo) {

}

// 주문 상세 정보를 위한 도우미 클래스
public static class OrderDetails {
	private final String customerId;
	private final String productId;
	private final int quantity;

	public OrderDetails(String customerId, String productId, int quantity) {
		this.customerId = customerId;
		this.productId = productId;
		this.quantity = quantity;
	}

	// Getters...

	@Override
	public String toString() {
		return "OrderDetails{" +
			   "customerId='" + customerId + '\'' +
			   ", productId='" + productId + '\'' +
			   ", quantity=" + quantity +
			   '}';
	}
}

// 배송 정보를 위한 도우미 클래스
public static class ShippingInfo {
	private final String address;
	private final String paymentMethod;

	public ShippingInfo(String address, String paymentMethod) {
		this.address = address;
		this.paymentMethod = paymentMethod;
	}

	// Getters...

	@Override
	public String toString() {
		return "ShippingInfo{" +
			   "address='" + address + '\'' +
			   ", paymentMethod='" + paymentMethod + '\'' +
			   '}';
	}
}

// 사용 예시
public static void main(String[] args) {
	OrderProcessingSystem system = new OrderProcessingSystem();
	
	OrderDetails orderDetails = new OrderDetails("CUST123", "PROD456", 2);
	ShippingInfo shippingInfo = new ShippingInfo("123 Main St, City, Country", "Credit Card");
	
	system.processOrder(orderDetails, shippingInfo);
}
```

- 3. 객체 생성에 사용한 **빌더 패턴**을 메서드 호출에 응용한다.
    - 매개변수가 많은데 그 중 일부는 생략해도 괜찮을 때 도움이 된다.
    - 모든 매개변수를 하나로 추상화된 객체를 정의하고, 클라이언트에서 이 객체의 setter 메서드를 호출해 필요한 값을 설정한다.
    - `execute()`를 이용해 유효성을 검사한다.
```java
public class PizzaOrderSystem {

    public void processOrder(PizzaOrder order) {
        System.out.println("Processing order: " + order);
    }

    @Builder
    @ToString
    public static class PizzaOrder {
        private final String size;
        private final String crust;
        private final boolean cheese;
        private final boolean pepperoni;
        private final boolean mushroom;
        private final String specialInstructions;

        public static class PizzaOrderBuilder {
            // Lombok이 자동으로 생성한 빌더에 유효성 검사 추가
            public PizzaOrder build() {
                if (size == null || crust == null) {
                    throw new IllegalStateException("Size and crust must be specified");
                }
                return new PizzaOrder(size, crust, cheese, pepperoni, mushroom, specialInstructions);
            }
        }
    }

    public static void main(String[] args) {
        PizzaOrderSystem system = new PizzaOrderSystem();

        PizzaOrder order1 = PizzaOrder.builder()
            .size("Large")
            .crust("Thin")
            .cheese(true)
            .pepperoni(true)
            .mushroom(false)
            .specialInstructions("Extra crispy")
            .build();

        system.processOrder(order1);

        // 일부 매개변수만 사용
        PizzaOrder order2 = PizzaOrder.builder()
            .size("Medium")
            .crust("Thick")
            .cheese(true)
            .build();

        system.processOrder(order2);
    }
}
```

### 매개변수의 타입으로는 `클래스`보다 `인터페이스`가 더 낫다
- **매개변수로 적합한 인터페이스가 있다면 그 인터페이스를 직접 사용하자**
- HashMap 대신 Map 인터페이스를 넘기자
    - Map의 어떤 구현체든 인수로 건넬 수 있다.

### boolean보다는 원소 2개짜리 `열거 타입`이 낫다
- `열거 타입`을 사용하면 코드를 읽고 쓰기가 더 쉬워진다.
- 나중에 `선택지`를 추가하기도 쉽다.
    - 열거 타입에 추가하기만 하면 된다.
```java
public enum TemperatureScale { FAHRENHEIT, CELSIUS}
```
- `Thermometer.newInstance(true)`보다 `Thermometer.newInstance(TemperatureScale.CELSIUS)`가 할 일을 더 명확하게 알려준다.

