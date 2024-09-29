# 1. 생성자 대신 정적 팩터리 메서드를 고려하라.
- 클라이언트가 클래스의 인스턴스를 얻는 전통적인 수단은 public 생성자이다.
- 클래스는 생성자와 별도로 정적 팩터리 메서드를 제공할 수 있다.
	- 정적 팩터리 메서드: 클래스의 인스턴스를 반환하는 정적 메서드

```java
public class Car {
    private final String make;
    private final String model;
    private final int year;
    private final String color;
    private final boolean isElectric;

    // 생성자
    public Car(String make, String model, int year, String color, boolean isElectric) {
        this.make = make;
        this.model = model;
        this.year = year;
        this.color = color;
        this.isElectric = isElectric;
    }

    // 정적 팩토리 메서드들
    public static Car createSedan(String make, String model, int year) {
        return new Car(make, model, year, "Silver", false);
    }

    public static Car createElectricCar(String make, String model, int year) {
        return new Car(make, model, year, "White", true);
    }

    // 기존 차량으로부터 새로운 연식의 차량을 만드는 정적 팩토리 메서드
    public static Car createNextYearModel(Car currentCar) {
        return new Car(currentCar.make, currentCar.model, currentCar.year + 1, 
                       currentCar.color, currentCar.isElectric);
    }

    @Override
    public String toString() {
        return year + " " + make + " " + model + " (" + color + ", " + 
               (isElectric ? "Electric" : "Gas") + ")";
    }
}

public class CarFactory {
    public static void main(String[] args) {
        // 생성자 사용
        Car customCar = new Car("Toyota", "Camry", 2023, "Blue", false);
        System.out.println("Custom Car: " + customCar);

        // 정적 팩토리 메서드 사용
        Car sedan = Car.createSedan("Honda", "Accord", 2023);
        System.out.println("Sedan: " + sedan);

        Car electricCar = Car.createElectricCar("Tesla", "Model 3", 2023);
        System.out.println("Electric Car: " + electricCar);

        // 기존 차량으로부터 새 모델 생성
        Car nextYearSportsCar = Car.createNextYearModel(sportsCar);
        System.out.println("Next Year Sports Car: " + nextYearSportsCar);
    }
}
```

### 1. 이름을 가질 수 있다.
- 생성자에 넘기는 매개 변수와 생성자 자체 만으로는 반환될 객체의 특성을 제대로 설명하지 ㅁ소한다.
- 정적 팩터리는 이름만 잘 지으면 반환될 객체의 특성을 쉽게 묘사할 수 있다.

```java
public class Pizza {
    private int size;
    private boolean cheese;
    private boolean pepperoni;
    private boolean bacon;

    // 생성자
    public Pizza(int size, boolean cheese, boolean pepperoni, boolean bacon) {
        this.size = size;
        this.cheese = cheese;
        this.pepperoni = pepperoni;
        this.bacon = bacon;
    }

    // 정적 팩터리 메서드들
    public static Pizza smallVeggie() {
        return new Pizza(10, true, false, false);
    }

    public static Pizza mediumMeatLovers() {
        return new Pizza(12, true, true, true);
    }

    public static Pizza largeCheese() {
        return new Pizza(14, true, false, false);
    }
}

public class PizzaOrder {
    public static void main(String[] args) {
        // 생성자 사용
        Pizza customPizza = new Pizza(12, true, false, true);
        
        // 정적 팩터리 메서드 사용
        Pizza veggiePizza = Pizza.smallVeggie();
        Pizza meatLoversPizza = Pizza.mediumMeatLovers();
        Pizza cheesePizza = Pizza.largeCheese();
    }
}
```

- 하나의 시그니처로는 생성자를 하나만 만들 수 있지만, 정적 팩토리 메서드는 제약이 없다.
=> **시그니처가 같은 생성자가 여러 개 필요할 것 같으면, 생성자를 정적 팩터리 메서드로 바꾸고 각각의 차이를 잘 드러내는 이름을 지어주자.**

### 2. 호출될 때마다 인스턴스를 새로 생성하지 않아도 된다.
- 불변 클래스는 인스턴스를 미리 만들어 놓거나 새로 생성된 인스턴스를 캐싱하여 재활용하는 식으로 불필요한 객체 생성을 피할 수 있다.
  ex) Integer.valueOf(100);
- **인스턴스 통제** : 언제 인스턴스를 살아있게 할지 철저히 통제할 수 있다.
> 캐싱을 통해 성능을 끌어올릴 수 있다. 플라이웨이트 패턴도 이와 비슷한 기법이라 할 수 있다.

#### Flyweight 패턴
- 객체의 공통된 상태를 공유하여 메모리 사용을 최적화하는 패턴
- 객체 공유: 동일하거나 유사한 객체들 사이에 가능한 많은 데이터를 공유한다.
- 내부 상태와 외부 상태 구분:
    - 내부 상태: 여러 객체 간에 공유될 수 있는 불변의 데이터
    - 외부 상태: 각 객체마다 고유한, 변할 수 있는 데이터
- 팩토리: Flyweight 객체를 생성하고 관리하는 팩토리를 사용한다.
```java
import java.util.HashMap;
import java.util.Map;

// Flyweight 인터페이스
interface Shape {
    void draw();
}

class Circle implements Shape {
    private String color; // 내부 상태
    private int x, y, radius; // 외부 상태

    public Circle(String color) {
        this.color = color;
    }

    public void setX(int x) {
        this.x = x;
    }

    public void setY(int y) {
        this.y = y;
    }

    public void setRadius(int radius) {
        this.radius = radius;
    }

    @Override
    public void draw() {
        System.out.println("Drawing Circle[ color: " + color + 
                           ", x: " + x + ", y: " + y + 
                           ", radius: " + radius + " ]");
    }
}

// Flyweight Factory
class ShapeFactory {
    private static final Map<String, Shape> circleMap = new HashMap<>();

    public static Shape getCircle(String color) {
        Circle circle = (Circle)circleMap.get(color);

        if(circle == null) {
            circle = new Circle(color);
            circleMap.put(color, circle);
            System.out.println("Creating circle of color : " + color);
        }
        return circle;
    }
}

// 클라이언트
public class FlyweightExample {
    private static final String[] colors = { "Red", "Green", "Blue", "White", "Black" };

    public static void main(String[] args) {
        for(int i=0; i < 20; ++i) {
            Circle circle = (Circle)ShapeFactory.getCircle(getRandomColor());
            circle.setX(getRandomX());
            circle.setY(getRandomY());
            circle.setRadius(100);
            circle.draw();
        }
    }

    private static String getRandomColor() {
        return colors[(int)(Math.random()*colors.length)];
    }

    private static int getRandomX() {
        return (int)(Math.random()*100);
    }

    private static int getRandomY() {
        return (int)(Math.random()*100);
    }
}
```

### 3. 반환 타입의 하위 타입 객체를 반환할 수 있는 능력이 있다.
- **반환할 객체의 클래스를 자유롭게 선택**할 수 있다.
- API를 만들 때 정적 팩토리 메서드를 응용하여 **구현 클래스를 공개하지 않고도 그 객체를 반환**할 수 있어 api를 작게 유지할 수 있다.
	- 정적 팩토리는 public으로 공개하고 **인터페이스를 반환**한다. 
	- 클라이언트의 코드가 인터페이스에 의존하여 **클라이언트는 구현 세부사항을 알 필요가 없다.**
	=> 인터페이스를 중심으로 프레임워크를 만드는 **인터페이스 기반 프레임워크를 만드는 핵심 기술**이다.

```java
// 인터페이스
public interface Animal {
    void makeSound();
}

// 구현 클래스 (비공개)
class Dog implements Animal {
    @Override
    public void makeSound() {
        System.out.println("Woof!");
    }
}

// 구현 클래스 (비공개)
class Cat implements Animal {
    @Override
    public void makeSound() {
        System.out.println("Meow!");
    }
}

// 팩토리 클래스
public class AnimalFactory {
    // 정적 팩토리 메서드
    public static Animal createDog() {
        return new Dog();
    }

    public static Animal createCat() {
        return new Cat();
    }
}

// 클라이언트
public class Main {
    public static void main(String[] args) {
        Animal dog = AnimalFactory.createDog(); 
        Animal cat = AnimalFactory.createCat();

		// 클라이언트는 구현 클래스를 알 필요 없이 Animal 인터페이스만 알면 된다.
        dog.makeSound(); // Woof! 
        cat.makeSound(); // Meow!
    }
}
```

#### 정적 메서드 구현시 별도의 package-private 클래스에 두어야 할 수 있다.

1. 과거 Java 8 이전:
인터페이스는 정적 메서드를 가질 수 없었다. 
동반 클래스(companion class)를 만들어 정적 메서드를 구현했다.

```java
// 인터페이스
public interface OldCollection<E> {
    void add(E element);
}

// 동반 클래스
public class OldCollections {
    public static <E> OldCollection<E> unmodifiableCollection(OldCollection<E> c) {
    }
}
```

2. Java 8 이후:
**인터페이스에 public 정적 메서드**를 직접 정의할 수 있게 되었다.

```java
public interface ModernCollection<E> {
    void add(E element);

    public static <E> ModernCollection<E> unmodifiableCollection(ModernCollection<E> c) {
    }
}
```

3. Java 9 이후:
**인터페이스에 private 정적 메서드**도 정의할 수 있게 되었다.

```java
public interface Java9Collection<E> {
    void add(E element);

    public static <E> Java9Collection<E> unmodifiableCollection(Java9Collection<E> c) {
        return new UnmodifiableCollection<>(c);
    }

    private static <E> Java9Collection<E> createUnmodifiable(Java9Collection<E> c) {
    }
}
```

4. 현재:
- **인터페이스에서는** **정적 필드와 정적 멤버 클래스가 여전히 public**이어야 한다.
	- 인터페이스 안에 **public 정적 메서드**와 **private 정적 메서드**를 가질 수는 있다.
- 복잡한 구현 로직이나 private 정적 필드가 필요한 경우, package-private 클래스를 사용해야 한다.

```java
public interface ModernInterface {
    // public 정적 필드만 가능
    public static final int CONSTANT = 42;

    // public 정적 메서드
    public static void publicStaticMethod() {
        privateStaticMethod();
        int count = HelperClass.getCounter();
        // ..
    }

    // private 정적 메서드 (Java 9+)
    private static void privateStaticMethod() {
    }

    // 정적 멤버 클래스는 public만 가능
    public static class NestedClass {
    }
}

// package-private 클래스
class HelperClass {
    private static int counter = 0; // private 정적 필드를 가질 경우 default 클래스 생성해야한다.

    static void complexImplementation() {
	    counter++;
    }
    
	static int getCounter() { return counter; }
}
```

### 4. 입력 매개변수에 따라 매번 다른 클래스의 객체를 반환할 수 있다.
- 반환 타입의 하위 타입이기만 하면 어떤 클래스의 객체를 반환하든 상관없다.
```java
interface PaymentMethod {
    void processPayment(double amount);
}

// 신용카드 결제
class CreditCardPayment implements PaymentMethod {
    @Override
    public void processPayment(double amount) {
        System.out.println("Processing credit card payment of $" + amount);
    }
}

// 암호화폐 결제
class CryptoPayment implements PaymentMethod {
    @Override
    public void processPayment(double amount) {
        System.out.println("Processing cryptocurrency payment of $" + amount);
    }
}

// 결제 팩토리 클래스
class PaymentFactory {
    // 정적 팩토리 메서드
    public static PaymentMethod getPaymentMethod(String paymentType) {
        switch (paymentType.toLowerCase()) {
            case "credit":
                return new CreditCardPayment();
            case "crypto":
                return new CryptoPayment();
            default:
                throw new IllegalArgumentException("Unknown payment type: " + paymentType);
        }
    }
}

// 클라이언트
public class PaymentExample {
    public static void main(String[] args) {
        double amount = 100.00;

        PaymentMethod creditPayment = PaymentFactory.getPaymentMethod("credit");
        creditPayment.processPayment(amount);

        PaymentMethod cryptoPayment = PaymentFactory.getPaymentMethod("crypto");
        cryptoPayment.processPayment(amount);
    }
}
```

### 5. 정적 팩터리 메서드를 작성하는 시점에는 반환할 객체의 클래스가 존재하지 않아도 된다.
#### 서비스 제공자 프레임워크
ex) JDBC
- 제공자 : 서비스의 구현체
- 프레임워크 : 구현체를 클라이언트에 제공하는 역할을 통제하여 클라이언트를 구현체로부터 분리한다.
	- 클라이언트는 구현체를 직접 다루지 않고 프레임워크를 통해 얻는다.
- 3가지 핵심 컴포넌트
	- **서비스 인터페이스** : 구현체의 동작 정의
	- **제공자 등록 API** : 제공자가 구현체를 등록할 때 사용
	- **서비스 접근 API** : 클라이언트가 서비스의 인스턴스를 얻을 때 사용, 유연한 정적 팩터리
	- + **서비스 제공자 인터페이스** : 서비스 인터페이스의 인스턴스를 생성하는 팩터리 객체
		- 서비스 제공자 인터페이스가 없다면 각 구현체를 인스턴스로 만들때 리플렉션을 사용해야한다.

1. **서비스 인터페이스** (Connection):
```java
public interface Connection {
    Statement createStatement() throws SQLException;
    PreparedStatement prepareStatement(String sql) throws SQLException;
}
```

2. **서비스 제공자 인터페이스** (Driver):
```java
public interface Driver {
    Connection connect(String url, Properties info) throws SQLException;
    boolean acceptsURL(String url) throws SQLException;
}
```

3. **제공자 등록 API** (DriverManager.registerDriver):
```java
public class DriverManager {
    public static void registerDriver(Driver driver) throws SQLException {
    }
}
```

4. **서비스 접근 API** (DriverManager.getConnection):
```java
public class DriverManager {
    public static Connection getConnection(String url) throws SQLException {
    }
}
```
- 정적 팩토리 메서드를 사용하여 **클라이언트는 구현체를 직접 다루지 않고 JDBC 프레임워크가 제공하는 인터페이스만을 사용**한다.

5. Driver 구현 예시
```java
public class MySQLDriver implements Driver {
    static {
        try {
            DriverManager.registerDriver(new MySQLDriver());
        } catch (SQLException e) {
            throw new RuntimeException("Can't register driver!");
        }
    }

    @Override
    public Connection connect(String url, Properties info) throws SQLException {
        if (!acceptsURL(url)) return null;
        return new MySQLConnection(url, info);
    }

    @Override
    public boolean acceptsURL(String url) throws SQLException {
        return url.startsWith("jdbc:mysql:");
    }
}

class MySQLConnection implements Connection {
}
```

6. 클라이언트
```java
public class JDBCClient {
    public static void main(String[] args) {
        try {
	        // 드라이버 로드
            Class.forName("com.mysql.jdbc.Driver");

            String url = "jdbc:mysql://localhost:3306/mydb";
            Connection conn = DriverManager.getConnection(url, "username", "password");

            // 연결 사용
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM users");

            while (rs.next()) {
                System.out.println(rs.getString("name"));
            }

            // 리소스 정리
            rs.close();
            stmt.close();
            conn.close();
            
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
}
```

##### 서비스 제공자 프레임워크의 변형 - 공급자가 제공하는 것보다 더 풍부한 서비스 인터페이스를 클라이언트에 반환
1. 브리지 패턴 : 추상화와 구현을 분리하여 둘을 독립적으로 변형할 수 있는 디자인 패턴
```java
// 기본 서비스 인터페이스 (공급자가 제공)
interface BasicDrawAPI {
    void drawShape();
}

// 확장된 서비스 인터페이스 (클라이언트에 제공)
interface AdvancedDrawAPI extends BasicDrawAPI {
    void setColor(String color);
    void resize(int percent);
}

// 구체적인 구현 클래스
class CircleAPI implements BasicDrawAPI {
    public void drawShape() {
        System.out.println("Drawing a circle");
    }
}

// 브리지 클래스 (확장된 기능 구현)
class AdvancedDrawAPIImpl implements AdvancedDrawAPI {
    private BasicDrawAPI basicAPI;
    private String color = "black";
    private int size = 100;

    public AdvancedDrawAPIImpl(BasicDrawAPI basicAPI) {
        this.basicAPI = basicAPI;
    }

    public void drawShape() {
        System.out.println("Drawing in " + color + " at " + size + "% size");
        basicAPI.drawShape();
    }

    public void setColor(String color) {
        this.color = color;
    }

    public void resize(int percent) {
        this.size = percent;
    }
}

// 서비스 제공자
class DrawingServiceProvider {
    public static AdvancedDrawAPI getDrawingAPI() {
        return new AdvancedDrawAPIImpl(new CircleAPI());
    }
}

// 클라이언트 코드
public class Client {
    public static void main(String[] args) {
        AdvancedDrawAPI api = DrawingServiceProvider.getDrawingAPI();
        api.setColor("red");
        api.resize(150);
        api.drawShape();
    }
}
```

2. 의존관계 주입 프레임워크 : 클래스의 의존성을 외부에서 주입받아 사용
```java
// 기본 서비스 인터페이스
interface DatabaseService {
    void executeQuery(String query);
}

// 로깅 서비스 인터페이스
interface LoggingService {
    void log(String message);
}

// 확장된 서비스 인터페이스
interface AdvancedDatabaseService extends DatabaseService {
    void executeQueryWithLogging(String query);
}

// 구현 클래스
class MySqlService implements DatabaseService {
    public void executeQuery(String query) {
        System.out.println("Executing query on MySQL: " + query);
    }
}

class ConsoleLoggingService implements LoggingService {
    public void log(String message) {
        System.out.println("LOG: " + message);
    }
}

// 의존 객체 주입을 사용한 확장 서비스 구현
class AdvancedDatabaseServiceImpl implements AdvancedDatabaseService {
    private DatabaseService databaseService;
    private LoggingService loggingService;

    public AdvancedDatabaseServiceImpl(DatabaseService databaseService, LoggingService loggingService) {
        this.databaseService = databaseService;
        this.loggingService = loggingService;
    }

    public void executeQuery(String query) {
        databaseService.executeQuery(query);
    }

    public void executeQueryWithLogging(String query) {
        loggingService.log("Executing query: " + query);
        databaseService.executeQuery(query);
        loggingService.log("Query execution completed");
    }
}

// 서비스 접근 API
class ServiceProvider {
    public static AdvancedDatabaseService getAdvancedDatabaseService() {
        DatabaseService databaseService = new MySqlService();
        LoggingService loggingService = new ConsoleLoggingService();
        return new AdvancedDatabaseServiceImpl(databaseService, loggingService);
    }
}

// 클라이언트
public class Client {
    public static void main(String[] args) {
        AdvancedDatabaseService service = ServiceProvider.getAdvancedDatabaseService();
        service.executeQueryWithLogging("SELECT * FROM users");
    }
}
```

## 정적 팩토리 메서드 단점
### 1. 상속을 하려면 public이나 protected 생성자가 필요하니 정적 팩터리 메서드만 제공하면 하위 클래스를 만들 수 없다.
- 상속보다 컴포지션을 사용하도록 유도한다.
```java
public class Engine {
    private int horsepower;

    private Engine(int horsepower) {
        this.horsepower = horsepower;
    }

    public static Engine create(int horsepower) {
        return new Engine(horsepower);
    }

    public void start() {
        System.out.println("Engine started. Horsepower: " + horsepower);
    }
}

public class Car {
    private Engine engine;  // 컴포지션

    public Car(int horsepower) {
        this.engine = Engine.create(horsepower);  
    }

    public void drive() {
        engine.start();
        System.out.println("Car is driving");
    }
}

// 클라이언트 
public class Main {
    public static void main(String[] args) {
        Car car = new Car(200);
        car.drive();
    }
}
```
- 불변 타입으로 만든다면 오히려 장점이라고 볼 수 있다.
	- 하위 클래스에서 상태를 변경할 수 있는 메서드를 추가하면 불변성이 깨질 수도 있다.

### 2. 정적 팩터리 메서드는 프로그래머가 찾기 어렵다.
- 생성자처럼 API 설명에 명확하게 드러나지 않는다.
- API 문서에 명시하고 메서드 이름도 널리 알려진 규약에 따라 지으면 문제를 완화할 수 있다.
``
#### 정적 팩터리 메서드 네이밍 방식
- from : 매개변수를 하나 받아서 해당 타입의 인스턴스 반환
- of : 여러 매개변수를 받아 적합한 타입의 인스턴스 반환
- valueOf : from과 of의 더 자세한 버전
- instance 혹은 getInstance : 매개변수로 명시한 인스턴스르 반환 (같은 인스턴스임을 보장하지는 X)
- create 혹은 newInstance : 매번 새로운 인스턴스를 생성해 반환
- getType : getInstance와 같지만 생성할 클래스가 아닌 다른 클래스에 팩터리 메서드를 정의할 때 사용
	- type : 팩터리 메서드가 반환할 객체의 타입
- newType: newInstance와 같지만 생성할 클래스가 아닌 다른 클래스에 팩터리 메서드를 정의할 때 사용
	- type : 팩터리 메서드가 반환할 객체의 타입
- type: getType과 newType의 간결한 버전

> 정적 팩터리 메서드와 public 생성자는 상대적인 장단점을 이해하고 사용하는 것이 좋다.
> 정적 팩터리 메서드를 사용하는게 유리한 경우가 많으므로 무작정 public 생성자를 제공하던 습관이 있다면 고치자.
