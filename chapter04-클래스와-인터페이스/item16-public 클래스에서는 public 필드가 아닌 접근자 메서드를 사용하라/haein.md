# 요약

---

- 클라이언트 코드가 직접 사용하면 캡슐화의 장점을 제공하지 못함

```java
public class Point {
	public double x;
	public double y;

	public static void main() {
		Point point = new Point();
		point.x = 10;
		point.y = 20;
	}
}
```

- 필드를 변경하려면 API를 변경해야 함

```java
public class Point {
	private double x;
	private double y;

	public double getX() {
		return x;
	}

	public double getY() {
		return y;
	}

	public double setX(double x) {
		this.x = x;
	}

	public double setY(double y) {
		this.y = y;
	}

	public static void main() {
		Point point = new Point();
		point.setX(x);
		point.setY(y);
	}
}
```

- package-private 혹은 private 중첩 클래스라면 데이터 필드를 노출한다 해도 상관없다.
    
```java
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

    // 나머지 코드 생략
}
```

- public 필드가 불변이라 해도 API 를 변경해야 표현 방식을 변경할 수 있고, 필드를 읽을 때 부수 작업을 수행할 수 없음 

    
