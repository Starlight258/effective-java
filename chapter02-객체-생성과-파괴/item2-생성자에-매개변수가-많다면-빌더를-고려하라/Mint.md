# 2. 생성자에 매개변수가 많다면 빌더를 고려하라.
- 정적 팩터리와 생성자는 선택적 매개변수가 많을 때 적절히 대응하기 어렵다.
- 위 상황을 해결하기 위해 점층적 생성자 패턴, 자바빈즈 패턴, 빌더 패턴을 알아보자.

### 점층적 생성자 패턴
```java
// 코드 2-1 점층적 생성자 패턴 - 확장하기 어렵다! (14~15쪽)  
public class NutritionFacts {  
    private final int servingSize;  // (mL, 1회 제공량)     필수  
    private final int servings;     // (회, 총 n회 제공량)  필수  
    private final int calories;     // (1회 제공량당)       선택  
    private final int fat;          // (g/1회 제공량)       선택  
    private final int sodium;       // (mg/1회 제공량)      선택  
    private final int carbohydrate; // (g/1회 제공량)       선택  
  
    public NutritionFacts(int servingSize, int servings) {  
        this(servingSize, servings, 0);  
    }  
  
    public NutritionFacts(int servingSize, int servings,  
                          int calories) {  
        this(servingSize, servings, calories, 0);  
    }  
  
    public NutritionFacts(int servingSize, int servings,  
                          int calories, int fat) {  
        this(servingSize, servings, calories, fat, 0);  
    }  
  
    public NutritionFacts(int servingSize, int servings,  
                          int calories, int fat, int sodium) {  
        this(servingSize, servings, calories, fat, sodium, 0);  
    }  
    public NutritionFacts(int servingSize, int servings,  
                          int calories, int fat, int sodium, int carbohydrate) {  
        this.servingSize  = servingSize;  
        this.servings     = servings;  
        this.calories     = calories;  
        this.fat          = fat;  
        this.sodium       = sodium;  
        this.carbohydrate = carbohydrate;  
    }  
  
    public static void main(String[] args) {  
        NutritionFacts cocaCola =  
                new NutritionFacts(240, 8, 100, 0, 35, 27);  
    }  
}
```
- 매개변수 개수가 많아지면 클라이언트 코드를 작성하거나 읽기 어렵다.
	- 코드를 읽을 때 각 값의 의미를 알기 어럽다.
	- 매개변수의 개수에 주의해야한다.
	- 타입이 같은 매개변수가 연달아 늘어서 있으면 찾기 어려운 버그가 된다.

### 자바빈즈 패턴 (JavaBeans Pattern)
- 매개변수가 없는 생성자로 객체를 만든 후, setter 메서드들을 호출해 원하는 매개변수의 값을 설정한다.
```java
// 코드 2-2 자바빈즈 패턴 - 일관성이 깨지고, 불변으로 만들 수 없다. (16쪽)  
public class NutritionFacts {  
    // 매개변수들은 (기본값이 있다면) 기본값으로 초기화된다.  
    private int servingSize  = -1; // 필수; 기본값 없음  
    private int servings     = -1; // 필수; 기본값 없음  
    private int calories     = 0;  
    private int fat          = 0;  
    private int sodium       = 0;  
    private int carbohydrate = 0;  
  
    public NutritionFacts() { }  
    // Setters  
    public void setServingSize(int val)  { servingSize = val; }  
    public void setServings(int val)     { servings = val; }  
    public void setCalories(int val)     { calories = val; }  
    public void setFat(int val)          { fat = val; }  
    public void setSodium(int val)       { sodium = val; }  
    public void setCarbohydrate(int val) { carbohydrate = val; }  
  
    public static void main(String[] args) {  
        NutritionFacts cocaCola = new NutritionFacts();  
        cocaCola.setServingSize(240);  
        cocaCola.setServings(8);  
        cocaCola.setCalories(100);  
        cocaCola.setSodium(35);  
        cocaCola.setCarbohydrate(27);  
    }  
}
```
- 점층적 생성자 패턴에 비해 인스턴스를 만들기 쉽고,더 읽기 쉽다.
- 객체 하나를 만들려면 메서드를 여러개 호출해야한다.
- 객체가 완전히 생성되기 전까지는 **일관성이 무너진 상태**에 놓이게 된다.
	- 객체 생성자 호출과 setter 호출 사이에 객체는 일관되지 않은 상태에 놓인다.
	- **클래스를 불변으로 만들 수 없다**. setter로 객체의 상태르 바꿀 수 있기 때문이다.
	- **스레드 안전성을 얻으려면 작업을 해줘야한다**. 자바빈즈 패턴에서는 여러 스레드에서 동시에 객체를 수정할 수 있다.
> freeze를 호출할 수 있지만 런타임에 freeze 호출 여부를 컴파일러가 보증할 수 없다.

## 빌더 패턴
- 점층적 생성자 패턴의 안전성과 자바빈즈  패턴의 가독성을 겸비한다.
- 1. **필수 매개변수만으로 생성자를 호출**해 빌더 객체를 얻는다.
	- Builder는 생성할 클래스 안에 **정적 멤버 클래스**로 보통 만들어놓는다.
- 2. 빌더 객체가 제공하는 일종의 **setter** 메서드들로 **원하는 선택 매개변수들을 설정**한다.
	- setter 메서드들은 빌더 자신을 반환하므로 메서드 체이닝이 가능하다. 
- 3. 매개변수가 없는 **build** 메서드를 호출해 객체를 얻는다.

```java
// 코드 2-3 빌더 패턴 - 점층적 생성자 패턴과 자바빈즈 패턴의 장점만 취했다. (17~18쪽)  
public class NutritionFacts {  
    private final int servingSize;  
    private final int servings;  
    private final int calories;  
    private final int fat;  
    private final int sodium;  
    private final int carbohydrate;  
  
    public static class Builder {  
        // 필수 매개변수  
        private final int servingSize;  
        private final int servings;  
  
        // 선택 매개변수 - 기본값으로 초기화한다.  
        private int calories      = 0;  
        private int fat           = 0;  
        private int sodium        = 0;  
        private int carbohydrate  = 0;  
  
        public Builder(int servingSize, int servings) {  // 필수 매개변수는 생성자에서 강제
            this.servingSize = servingSize;  
            this.servings    = servings;  
        }  
		// 선택 매개변수는 setter 메서드로 설정
        public Builder calories(int val)  
        { calories = val;      return this; }  
        public Builder fat(int val)  
        { fat = val;           return this; }  
        public Builder sodium(int val)  
        { sodium = val;        return this; }  
        public Builder carbohydrate(int val)  
        { carbohydrate = val;  return this; }  
  
        public NutritionFacts build() {  
            return new NutritionFacts(this);  
        }  
    }  
  
    private NutritionFacts(Builder builder) {  
        servingSize  = builder.servingSize;  
        servings     = builder.servings;  
        calories     = builder.calories;  
        fat          = builder.fat;  
        sodium       = builder.sodium;  
        carbohydrate = builder.carbohydrate;  
    }  
  
    public static void main(String[] args) {  
        NutritionFacts cocaCola = new NutritionFacts.Builder(240, 8)  
                .calories(100)
                .sodium(35)
                .carbohydrate(27)
                .build();  
    }  
}
```

### 유효성 검사 코드
- 잘못된 매개변수를 최대한 일찍 발견하는 것이 좋다.
- **빌더의 생성자와 메서드에서 입력 매개변수를 검사**한다.
- **build 메서드가 호출하는 생성자에서 여러 매개변수에 걸친 불변식을 검사**한다.
	- 불변식을 보장하기 위해 빌더로부터 매개변수를 복사한 후 해당 객체 필드도 검사해야한다.  (참조 타입인 경우 복사)
- 잘못된 점을 발견하면 `IllegalArgumentException`을 던진다.
```java
public class Pizza {
    private final List<String> size;
    private final int cheese;
    private final int pepperoni;
    private final int bacon;

    private Pizza(Builder builder) {
        this.size = new ArrayList<>(builder.size); // 참조 타입 방어적 복사
        this.cheese = builder.cheese;
        this.pepperoni = builder.pepperoni;
        this.bacon = builder.bacon;
        
        if (this.size.isEmpty()) {
            throw new IllegalArgumentException("Size list cannot be empty");
        }
        
        // 여러 매개변수에 걸친 불변식 검사
        int totalToppings = this.cheese + this.pepperoni + this.bacon;
        if (totalToppings > 3) {
            throw new IllegalArgumentException("Too many toppings");
        }
    }

    public List<String> getSize() {
        return Collections.unmodifiableList(size);
    }

    public static class Builder {
        private final List<String> size = new ArrayList<>();
        private int cheese = 0;
        private int pepperoni = 0;
        private int bacon = 0;

        public Builder addSize(String sizeElement) {
            if (sizeElement == null || sizeElement.isEmpty()) {
                throw new IllegalArgumentException("Size element cannot be null or empty");
            }
            this.size.add(sizeElement);
            return this;
        }

        public Builder cheese(int value) {
            if (value < 0) {
                throw new IllegalArgumentException("Negative cheese is not allowed");
            }
            this.cheese = value;
            return this;
        }

        public Builder pepperoni(int value) {
            if (value < 0) {
                throw new IllegalArgumentException("Negative pepperoni is not allowed");
            }
            this.pepperoni = value;
            return this;
        }

        public Builder bacon(int value) {
            if (value < 0) {
                throw new IllegalArgumentException("Negative bacon is not allowed");
            }
            this.bacon = value;
            return this;
        }

        public Pizza build() {
            return new Pizza(this); // 생성자 호출
        }
    }

    @Override
    public String toString() {
        return "Pizza{size='" + size + "', cheese=" + cheese +
               ", pepperoni=" + pepperoni + ", bacon=" + bacon + "}";
    }
}
```
#### 불변과 불변식
- **불변** : 어떠한 변경도 허용되지 않는다.
	- ex) String은 불변
- **불변식**: 프로그램이 실행되거나 정해진 기간동안 반드시 만족해야하는 조건
	- 가변 객체에도 불변식이 존재할 수 있다.
	- ex) 리스트의 크기는 반드시 0 이상이어야한다.

### 빌더 패턴은 계층적으로 설계된 클래스와 함께 쓰기에 좋다. (계층 빌더)
- 각 계층의 클래스에 관련 빌더를 멤버로 정의하자.
	- 추상 클래스는 추상 빌더를, 구체 클래스는 구체 빌더를 갖게 한다.

#### 추상 빌더
```java
// 코드 2-4 계층적으로 설계된 클래스와 잘 어울리는 빌더 패턴 (19쪽)  
  
// 참고: 여기서 사용한 '시뮬레이트한 셀프 타입(simulated self-type)' 관용구는  
// 빌더뿐 아니라 임의의 유동적인 계층구조를 허용한다.  
  
public abstract class Pizza {  
    public enum Topping { HAM, MUSHROOM, ONION, PEPPER, SAUSAGE }  
    final Set<Topping> toppings;  
  
    abstract static class Builder<T extends Builder<T>> {  
        EnumSet<Topping> toppings = EnumSet.noneOf(Topping.class);  
        public T addTopping(Topping topping) {  
            toppings.add(Objects.requireNonNull(topping));  
            return self();  
        }  
  
        abstract Pizza build();  
  
        // 하위 클래스는 이 메서드를 재정의(overriding)하여  
        // "this"를 반환하도록 해야 한다.  
        protected abstract T self();  
    }  
    Pizza(Builder<?> builder) {  
        toppings = builder.toppings.clone(); // 아이템 50 참조  
    }  
}
```

- **재귀적 타입 한정**
	- T는 Builder<T>의 하위타입이어야한다.
	-  T의 정의가 T 자체를 포함하기 때문에 재귀적이다.
- **추상 메서드 self()**
	- 하위 클래스에서 자기 자신을 반환할 수 있다.
	- Builder는 self()를 반환한다.
=> 시뮬레이트(모방)한 셀프 타입(simulated self-type)으로, self 타입이 없는 java를 위한 우회 방법이다.
    이를 통해 **메서드 체이닝**을 지원한다.
```java
abstract static class Builder<T extends Builder<T>>

protected abstract T self();  
```

#### 구체 빌더
```java 
// 코드 2-5 뉴욕 피자 - 계층적 빌더를 활용한 하위 클래스 (20쪽)  
public class NyPizza extends Pizza {  
    public enum Size { SMALL, MEDIUM, LARGE }  
    private final Size size;  
  
    public static class Builder extends Pizza.Builder<Builder> {  
        private final Size size;  
  
        public Builder(Size size) {  
            this.size = Objects.requireNonNull(size);  
        }  
  
        @Override public NyPizza build() {  // 오버라이드
            return new NyPizza(this);  
        }  
  
        @Override protected Builder self() { return this; }  
    }  
  
    private NyPizza(Builder builder) {  
        super(builder);  
        size = builder.size;  
    }  
  
    @Override public String toString() {  
        return toppings + "로 토핑한 뉴욕 피자";  
    }  
}
```

- 추상 빌더(Pizza.Builder)를 상속하는 NyPizza.Builder를 생성한다.
	- Builder<\T>에서 T는 NyPizza.Builder이고, Builder는 Pizza.Builder이다.
	- toppings 필드나 addTopping()과 같은 메서드는 추상 빌더로부터 상속받아 사용한다.
```java
public static class Builder extends Pizza.Builder<Builder> {  
```

- build()
	- 생성자를 호출하여 실제 하위 클래스의 인스턴스(객체)를 만든다.
	- 하위 클래스가 상위 클래스의 메서드가 정의한 반환 타입이 아닌, 그 하위 타입을 반호나하는 기능을 공반환 타이핑이라고 한다.
		- NyPizza.Builder는 NyPizza를 반환하고, Calzone.Builder는 Calzone을 반환한다.
- self()
	- 하위 클래스 자기 자신을 반환하여 메서드 체이닝을 가능하게 한다.

### 가변인수의 매개변수를 여러 개 사용할 수 있다.
- 가변인수를 설정할 때 적절히 메서드를 나눠서 사용할 수 있다.
	- addToppings()뿐 아니라 addSauces()도 만든다.
```java
public class Pizza {
    private final String size;
    private final List<String> toppings;
    private final List<String> sauces;

    private Pizza(Builder builder) {
        this.size = builder.size;
        this.toppings = new ArrayList<>(builder.toppings);
        this.sauces = new ArrayList<>(builder.sauces);
    }

    public static class Builder {
        private final String size;
        private final List<String> toppings = new ArrayList<>();
        private final List<String> sauces = new ArrayList<>();

        public Builder(String size) {
            this.size = size;
        }

        public Builder addToppings(String... toppings) {
            Collections.addAll(this.toppings, toppings);
            return this;
        }

        public Builder addSauces(String... sauces) {
            Collections.addAll(this.sauces, sauces);
            return this;
        }

        public Pizza build() {
            return new Pizza(this);
        }
    }
    @Override 
    public String toString() {
	    return "Pizza{" + "size='" + size + '\'' + ", toppings=" + toppings + ", sauces=" + sauces + '}'; 
	}
}

public class PizzaOrder {
    public static void main(String[] args) {
        Pizza pizza1 = new Pizza.Builder("large")
            .addToppings("mushroom", "olive", "onion")
            .addSauces("tomato")
            .build();
    }
}
```

- 각 호출때 넘겨진 매개변수들을 하나의 필드로 모을 수도 있다.
	- Pizza의 toppings

### 빌더 패턴은 유연하다.
- 빌더 하나로 여러 객체를 숞회하면서 만들 수 있다.
	- 빌더를 초기화하여 하나의 빌더로 여러 객체를 만들 수 있다.
```java
import java.util.ArrayList;
import java.util.List;

class Pizza {
    private final String size;
    private final List<String> toppings;

    private Pizza(Builder builder) {
        this.size = builder.size;
        this.toppings = new ArrayList<>(builder.toppings);
    }

    @Override
    public String toString() {
        return "Pizza{size='" + size + "', toppings=" + toppings + '}';
    }

    public static class Builder {
        private String size;
        private List<String> toppings = new ArrayList<>();

        public Builder size(String size) {
            this.size = size;
            return this;
        }

        public Builder addTopping(String topping) {
            this.toppings.add(topping);
            return this;
        }

        public Builder reset() {
            this.size = null;
            this.toppings.clear();
            return this;
        }

        public Pizza build() {
            return new Pizza(this);
        }
    }
}

public class PizzaShop {
    public static void main(String[] args) {
        List<Pizza> orders = new ArrayList<>();
        Pizza.Builder builder = new Pizza.Builder();

        // 첫 번째 피자
        orders.add(builder.size("Large")
                          .addTopping("Cheese")
                          .addTopping("Pepperoni")
                          .build());

        // 빌더 초기화 후 두 번째 피자
        builder.reset();
        orders.add(builder.size("Medium")
                          .addTopping("Mushroom")
                          .addTopping("Onion")
                          .build());
    }
}
```

- 빌더에 넘기는 매개변수에 따라 다른 객체를 만들 수도 있다.
	- 매개변수에 따라 다른 구체 빌더를 호출한다.
- 일련 번호와 같은 특정 필드는 빌더가 알아서 채우게 할수도 있다.
```java
abstract class Vehicle { // 추상 클래스
    protected final int id;
    protected final String model;
    protected final String color;

    protected Vehicle(Builder<?> builder) {
        this.id = builder.id;
        this.model = builder.model;
        this.color = builder.color;
    }

    @Override
    public String toString() {
        return getClass().getSimpleName() + " {id=" + id + ", model='" + model + "', color='" + color + "'}";
    }

    // 추상 빌더 클래스
    abstract static class Builder<T extends Builder<T>> {
        private static int nextId = 1;  // 자동 증가하는 ID (일련번호 자동 채우기)
        private int id = nextId++;
        private String model;
        private String color;

        public T model(String model) {
            this.model = model;
            return self();
        }

        public T color(String color) {
            this.color = color;
            return self();
        }

        abstract Vehicle build();

        protected abstract T self();
    }
}

class Car extends Vehicle {
    private final int numDoors;

    private Car(Builder builder) {
        super(builder);
        this.numDoors = builder.numDoors;
    }

    public static class Builder extends Vehicle.Builder<Builder> {
        private int numDoors;

        public Builder numDoors(int numDoors) {
            this.numDoors = numDoors;
            return this;
        }

        @Override
        public Car build() {
            return new Car(this);
        }

        @Override
        protected Builder self() {
            return this;
        }
    }

    @Override
    public String toString() {
        return super.toString() + " Car {numDoors=" + numDoors + "}";
    }
}

class Motorcycle extends Vehicle {
    private final boolean hasSidecar;

    private Motorcycle(Builder builder) {
        super(builder);
        this.hasSidecar = builder.hasSidecar;
    }

    public static class Builder extends Vehicle.Builder<Builder> {
        private boolean hasSidecar;

        public Builder hasSidecar(boolean hasSidecar) {
            this.hasSidecar = hasSidecar;
            return this;
        }

        @Override
        public Motorcycle build() {
            return new Motorcycle(this);
        }

        @Override
        protected Builder self() {
            return this;
        }
    }

    @Override
    public String toString() {
        return super.toString() + " Motorcycle {hasSidecar=" + hasSidecar + "}";
    }
}

class VehicleFactory {
    public List<Vehicle> createVehicles(List<String> specifications) {
        List<Vehicle> vehicles = new ArrayList<>();
        for (String spec : specifications) {
            String[] parts = spec.split(",");
            String type = parts[0].trim();
            String model = parts[1].trim();
            String color = parts[2].trim();

			// type에 Car을 넘기면 Car 타입의 객체를, Motorcycle을 넘기면 MotoCycle 타입의 객체를 만들 수 있다.
            if ("Car".equalsIgnoreCase(type)) {
                int doors = Integer.parseInt(parts[3].trim());
                vehicles.add(new Car.Builder().model(model).color(color).numDoors(doors).build());
            } else if ("Motorcycle".equalsIgnoreCase(type)) {
                boolean sidecar = Boolean.parseBoolean(parts[3].trim());
                vehicles.add(new Motorcycle.Builder().model(model).color(color).hasSidecar(sidecar).build());
            }
        }
        return vehicles;
    }
}

// 메인 클래스
public class VehicleProduction {
    public static void main(String[] args) {
        List<String> orders = List.of(
            "Car, Sedan, Red, 4",
            "Motorcycle, Sport, Black, false",
            "Car, SUV, Blue, 5",
            "Motorcycle, Cruiser, Silver, true"
        );

        VehicleFactory factory = new VehicleFactory();
        List<Vehicle> producedVehicles = factory.createVehicles(orders);

        for (Vehicle vehicle : producedVehicles) {
            System.out.println(vehicle);
        }
    }
}
```

### 빌더 패턴의 단점
- 객체를 만드려면 그에 앞서 빌더부터 만들어야한다.
- 점층적 생성자 패턴보다는 코드가 장황해서 **매개변수 4개 이상이어야 값어치를 한다.**
	- api는 시간이 지날수록 매개변수가 많아지는 경향이 있다.

### 결론
- 생성자나 정적 팩터리가 **처리해야 할 매개변수가 많다면 빌더 패턴을 선택하는것이 좋다.**
- 매개변수 중 다수가 **필수가 아니거나 같은 타입이면 특히 더 그렇다.**
