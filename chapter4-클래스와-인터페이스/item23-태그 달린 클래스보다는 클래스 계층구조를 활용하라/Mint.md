# 23. 태그 달린 클래스보다는 클래스 계층구조를 활용하라
## 태그 달린 클래스
- 두가지 이상의 의미를 표현
- 현재 표현하는 의미를 태그 값으로 알려주는 클래스
```java
// 코드 23-1 태그 달린 클래스 - 클래스 계층구조보다 훨씬 나쁘다! (142-143쪽)  
class Figure {  
    enum Shape { RECTANGLE, CIRCLE };  
  
    // 태그 필드 - 현재 모양을 나타낸다.  
    final Shape shape;  
  
    // 다음 필드들은 모양이 사각형(RECTANGLE)일 때만 쓰인다.  
    double length;  
    double width;  
  
    // 다음 필드는 모양이 원(CIRCLE)일 때만 쓰인다.  
    double radius;  
  
    // 원용 생성자  
    Figure(double radius) {  
        shape = Shape.CIRCLE;  
        this.radius = radius;  
    }  
  
    // 사각형용 생성자  
    Figure(double length, double width) {  
        shape = Shape.RECTANGLE;  
        this.length = length;  
        this.width = width;  
    }  
  
    double area() {  
        switch(shape) {  
            case RECTANGLE:  
                return length * width;  
            case CIRCLE:  
                return Math.PI * (radius * radius);  
            default:  
                throw new AssertionError(shape);  
        }  
    }  
}
```

### 태그 달린 클래스의 단점
- 열거 타입 선언, 태그 필드, switch 문 등 **쓸데없는 코드가 많다.**
- **여러 구현이 한 클래스에 혼합**돼 있어서 **가독성도 나쁘다.**
    - 다른 의미를 위한 코드도 함께 하니 **메모리도 많이 사용**한다.
- 필드들을 `final`로 선언하려면 **해당 의미에 쓰이지 않는 필드들까지 생성자에서 초기화**해야 한다.
- 엉뚱한 필드를 초기화해도 **런타임에서야 문제가 드러난다**.
- 의미를 추가하려면 코드를 수정해야한다. (`switch` 문)
- 인스턴스의 타입만으로는 현재 나타내는 의미를 알 수 없다.
> 태그 달린 클래스는 장황하고, 오류를 내기 쉽고, 비효율적이다.
대신 클래스 계층구조를 활용하자.

### 태그 달린 클래스를 클래스 계층구조로 바꾸자.
1. 계층구조의 루트가 될 **추상 클래스**를 정의하자
2. 태그 값에 따라 **동작이 달라지는** 메서드들을 **루트 클래스의 추상 메서드**로 선언한다.
3. 태그 값에 상관없이 **동작이 일정한** 메서드들을 **루트 클래스에 일반 메서드**로 추가한다.
4. 모든 하위 클래스에서 **공통으로 사용하는 데이터 필드**들도 전부 루트 클래스로 올린다.
5. 루트 클래스를 확장한 **구체 클래스**를 의미별로 하나씩 정의하여 구현한다.
```java
abstract class Figure {  
    abstract double area();  
}

class Circle extends Figure {  
    final double radius;  
  
    Circle(double radius) { this.radius = radius; }  
  
    @Override double area() { return Math.PI * (radius * radius); }  
}

class Rectangle extends Figure {  
    final double length;  
    final double width;  
  
    Rectangle(double length, double width) {  
        this.length = length;  
        this.width  = width;  
    }  
    @Override double area() { return length * width; }  
}
```
- 간결하고 명확하며, 쓸데없는 코드도 모두 사라졌다.
- 각 의미를 독립된 클래스에 담아 **관련 없던 데이터 필드를 모두 제거**했다.
- **컴파일러**가 모든 필드가 초기화되었는지, 추상 메서드를 모두 구현했는지 확인해준다.
- 런타임 오류가 발생할 일도 없다.
> 접근자 메서드 없이 필드를 노출하는 것은 좋지 않다. 예시는 단순하게 구현한 것이다.

#### **루트 클래스의 코드를 건드리지 않고도** 다른 프로그래머들이 **독립적으로 계층구조를 확장하고 함께 사용**할 수 있다.
새로운 정사각형 클래스를 손쉽게 추가할 수 있다.
```java
// 태그 달린 클래스를 클래스 계층구조로 변환 (145쪽)  
class Square extends Rectangle {  
    Square(double side) {  
        super(side, side);  
    }  
}
```

## 결론
- 태그 달린 클래스를 써야하는 상황은 거의 없다.
- **새로운 클래스를 작성하는 태그 필드가 등장한다면 태그를 없애고 계층구조로 대체**하는 방법을 생각해보자.
- **기존 클래스가 태그 필드를 사용하고 있다면 계층구조로 리팩토링**하자.

