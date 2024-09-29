

### 태그 달린 클래스의 문제

> **장황**하고, **오류**를 내기 쉽고, **비효율적**이다.
> 
- 열거 타입 선언, tag field, switch문 등 불필요한 코드 존재
- 그 때문에 추가적 코드로 메모리 낭비를 하게된다.
- final로 선언하기 위해 쓸데없는 코드가 필요하다. 해당 의미에 쓰이지 않는 필드들도 초기화를 해야하기 때문이다.
- 컴파일러가 초기화를 도와줄 수도 없어 런타임에 문제를 발견하게 됨
- 인스턴스의 타입만으로는 현재 나타내는 의미를 알기 쉽지 않음

클래스 계층 구조(=**서브 타이핑**)가 이에 대한 대안이 된다. 

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

# 요약
---

### 클래스 계층 구조로 바꾸는 과정

1. 루트가 될 추상 클래스를 정의한다.
2. 태그 값에 따라 동작이 달라지는 메서드들을 루트 클래스의 추상 메서드로 선언
3. 태그 값에 관계없이 동작이 일정한 메서드들을 루트 클래스에 일반 메서드로 추가. 동시에 공통으로 사용하는 데이터 필드들도 루트 클래스에 위치
4. 루트 클래스 확장한 구체 클래스를 하나씩 정의



### 이 모두는 태그 달린 클래스의 단점을 상쇄한다.

- 간결하고 명확하다. 쓸데없는 코드가 없기 때문이다.
- 각 클래스의 생성자가 모든 필드를 남김없이 초기화하고 추상 메서드를 모두 구현했는지 컴파일러가 확인해준다.
- 루트 클래스의 코드와는 관계없이 계층구조의 확장이 가능하다.
- 타입이 의미별로 다로 존재하니 변수의 의미를 명시하거나 제한할 수 있다. 특정 의미만 매개변수로 받을 수 있다.
- 타입 사이의 자연스러운 계층 관계를 반영할 수 있어 유연하고, 컴파일 타임 타입 검사 능력을 높여준다.

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

class Square extends Rectangle {
    Square(double side) {
        super(side, side);
    }
}
```