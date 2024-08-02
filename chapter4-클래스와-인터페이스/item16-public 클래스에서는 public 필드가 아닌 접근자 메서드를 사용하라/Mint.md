# 16. public 클래스에서는 pubilc 필드가 아닌 접근자 메서드를 사용하라.

###  public 인스턴스 필드만 모아놓은 클래스는 캡슐화를 지키지 못한다.
```java
class Point{
	public double x;
	public double y;
}
```
#### 단점 1. API(public 메서드와 필드)를 수정하지 않고서는 내부 표현을 바꿀 수 없다.
- 좋지 않은 예시
```java
public class BadDesign {
    public List<String> names;  // 직접 접근 가능한 public 필드

    public BadDesign() {
        names = new ArrayList<>();
    }

    public void addName(String name) {
        names.add(name);
    }

    public int getSize() {
        return names.size();
    }
}
```
- 좋은 예시
```java
public class GoodDesign {
    private List<String> names;  // private 필드

    public GoodDesign() {
        names = new ArrayList<>();
    }

    public void addName(String name) {
        names.add(name);
    }

    public int getSize() {
        return names.size();
    }

    public List<String> getNames() {
        return Collections.unmodifiableList(names);  // 읽기 전용 뷰 반환
    }
}
```
- 나중에 내부 구현을 ArrayList에서 LinkedList로 변경하고 싶다면,
    - 좋지 않은 예시에서는 public 필드인 API를 변경해야한다.
    - 좋은 예시에서는 API는 유지하고 내부 구현만 변경하면 된다.
#### 단점 2. 불변식을 보장할 수 없다.
- 변경이 가능하다.
#### 단점 3. 외부에서 필드에 접근할 때 부수 작업을 수행할 수 없다.
- 필드에 직접 접근 가능하므로 접근시 lock과 같은 부수 작업을 수행할 수 없다.

#### java에서 public 클래스 필드를 노출한 사레
- java.awt.package의 Point와 Dimention 클래스는 public 필드를 직접 노출하여 성능 문제가 발생한다.
- 따라하지 말자.

### 캡슐화의 이점을 지키기 위해 필드를 모두 private으로 바꾸고 public 접근자(getter)를 추가하자. 🌟
```java
// 코드 16-2 접근자와 변경자(mutator) 메서드를 활용해 데이터를 캡슐화한다. (102쪽)  
class Point {  
    private double x;  
    private double y;  
  
    public Point(double x, double y) {  
        this.x = x;  
        this.y = y;  
    }  
  
    public double getX() { return x; }  
    public double getY() { return y; }  
  
    public void setX(double x) { this.x = x; }  
    public void setY(double y) { this.y = y; }  
}
```

### package-private 클래스 혹은 private 중첩 클래스라면 데이터 필드를 노출한다 해도 문제가 없다.
- 접근 범위가 낮아 위 클래스들의 api가 변경되더라도 영향받는 범위가 적다.
    - package-private 클래스는 가은 패키지 내에서만 접근이 가능하다.
    - private 중첩 클래스는 해당 클래스를 포함하는 외부 클래스만 접근이 가능하다.
- 코드가 간결하고 필드를 직접 사용하면 필드에 바로 접근이 가능하므로 미세하게나마 이점이 있다.
- 예시
```java
// package-private 클래스
class PackagePrivateExample {
    public int x;  // 직접 접근 가능한 필드
    public int y;
}

public class OuterClass {
    // private 중첩 클래스
    private class PrivateInnerClass {
        public int a;  // 직접 접근 가능한 필드
        public int b;
    }

    public void useInnerClass() {
        PrivateInnerClass inner = new PrivateInnerClass();
        inner.a = 10;  // 직접 접근
    }
}
```
- 클래스의 사용 범위가 제한적이어서 외부 영향이 적다.
- 필요한 경우 변경하기 쉽고 **코드가 더 간결하다.**
- 클래스의 책임이 증가하거나 사용 범위가 넓어질 가능성이 있다면 캡슐화를 적용하는 것이 좋다.

### 불변이라도 public 필드로 노출하지 않는 것이 좋다.
```java
// 코드 16-3 불변 필드를 노출한 public 클래스 - 과연 좋은가? (103-104쪽)  
public final class Time {  
    private static final int HOURS_PER_DAY    = 24;  
    private static final int MINUTES_PER_HOUR = 60;  
  
    public final int hour;  
    public final int minute;  
  
    public Time(int hour, int minute) {  
        if (hour < 0 || hour >= HOURS_PER_DAY)  
            throw new IllegalArgumentException("Hour: " + hour);  
        if (minute < 0 || minute >= MINUTES_PER_HOUR)  
            throw new IllegalArgumentException("Min: " + minute);  
        this.hour = hour;  
        this.minute = minute;  
    }  
}
```
- 불변식은 보장이 가능하지만, API를 변경해야만 표현 방식을 변경할 수 있고, 필드 접근시 부수 작업을 수행할 수 없다.

### 결론
- **public 클래스는 절대 가변 필드를 직접 노출해서는 안된다.**
    - 불변 필드라면 노출해도 덜 위험하지만 완전히 안심할 수 없다.
- package-private 클래스나 private 중첩 클래스에서는 종종 필드를 노출하는 편이 나을 때도 있다.

