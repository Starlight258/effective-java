



# 요약

### 1️⃣ 정적 멤버 클래스 = 독립

> static이 붙은 중첩 클래스라고도 부른다.
> 

바깥 클래스의 보조적인 기능을 제공하거나, 네임스페이스를 관리하는 데 사용

```java
class OuterClass {
    private int a = 100;

    static class InnerClass {
        private int b;
        
        void accessOuterClass(){
            OuterClass outerClass = new OuterClass();
            outerClass.a = 1;
        }
    }
}
// 바깥 클래스 인스턴스 없이 정적 클래스 인스턴스 생성 가능. 이는 바깥 클래스에 대한 참조가 필요 없다는 뜻이다.
public void createClass(){
    OuterClass.InnerClass innerClass = new InnerClass();
}
```

- 바깥 클래스와 **함께** 쓰일때만 유용하다. 즉 바깥 클래스의 구성 요소일 때 유용하다.
- 개념상 중첩 클래스의 인스턴스가 바깥 인스턴스 없이 존재할 수 있다면 정적 멤버 클래스로 만들어야한다.
- 일반 정적 멤버와 똑같은 접근 규칙을 적용받는다.

### 2️⃣ 비정적 멤버 클래스 = 인스턴스 종속

> 겉으로 보기에는 그냥 **static이 붙지 않은 중첩 클래스**지만, 의미상으로는 차이가 있다.
> 

```java
class OuterClass {
    private int a = 100;

    class InnerClass {
        private int b;
    }
}

public class Main {
    public static void main(String[] args) {
        final OuterClass outerClass = new OuterClass();
        outerClass.new InnerClass();
    }
}
```

- 비정적 멤버 클래스의 인스턴스는 바깥 클래스의 인스턴스와 **암묵적으로 연결**된다.

→ 따라서, 비정적 멤버 클래스의 인스턴스 메서드에서 ***정규화된 this**를 사용하여 바깥 인스턴스의 메서드를 호출하거나 바깥 인스턴스의 참조를 가져올 수 있다. 

---

*정규화된 this: 클래스명.this 형태로 바깥 클래스의 이름을 명시하는 용법

- 비정적 멤버 클래스의 인스턴스-바깥 클래스 인스턴스는 내부 클래스가 인스턴스화 될 때 관계가 확립이 되고 변경할 수 없다.
- 보통 바깥 클래스의 인스턴스 메서드에서 비정적 멤버 클래스의 생성자를 호출하면 자동으로 만들어지지만, 드물게 바깥 인스턴스 [클래스.](http://클래스.new)new Member class()로 만들기도 한다.

→ 이는 비정적 멤버 클래스의 인스턴스 안에 만들어져 메모리 공간을 차지하게 된다 + 생성시간도 더 걸린다. 

- **어댑터 패턴을 사용할 때** 자주 쓰인다. 어떤 클래스의 인스턴스를 감싸 마치 다른 클래스의 인스턴스처럼 보이게 하기위해 사용하는 것! 아래 예시의 경우, Map ≠ Set이지만, Map에서 keySet()을 호출 시 마치 Set의 인스턴스가 있는 것처럼 보이게 한다.



- 이런 경우 말고, 멤버 클래스에서 밖 인스턴스에 접근할 일이 없다면 정적 멤버 클래스로 만드는 것이 좋다. 바깥 인스턴스로의 참조를 가지고 있어 OOM이 일어날 수도 있다!

### 3️⃣ 익명 내부 클래스

> 1) 바깥 클래스의 멤버가 아니고 2) 이름도 없다.
> 

다만 쓰이는 시점에 선언하고 인스턴스도 만들어진다. 

```java
public class Calculator {
    private int x;
    private int y;

    public Calculator(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public int plus() {
        Operator operator = new Operator() { // **1) 바깥 클래스의 멤버라고 할 수 없다.**
            private static final String COMMENT = "더하기"; // 상수
            // private static int num = 10; // 상수 외의 정적 멤버는 불가능
          
            @Override
            public int plus() {
                // 3) Calculator.plus()가 static이면 x, y 참조 불가
                return x + y;
            }
						public void makeString(){
								} 
        };
				// operator.makeString() 4) 호출 불가능. 
// operator는 인터페이스를 구현한 익명 클래스를 참조하고 있기 때문에 인터페이스에 정의되어 있지 않기 때문
        return operator.plus();
    }
}

interface Operator {
    int plus();
}
```

3) 비정적인 문맥에서 사용될 때만 바깥 클래스의 인스턴스를 참조할 수 있다. 정적인 경우, 상수 변수 이외의 정적 멤버는 가질 수 없다. (상수 변수란 **`final`** 키워드로 선언된 변수를 의미한다.)

👇 **제약이 많다** 👇 

- 선언한 지점에서만 인스턴스를 만들 수 있고 instanceof 검사나 클래스의 이름이 필요한 작업은 수행 불가하다.
- 여러 인터페이스 구현 불가, 하나의 인터페이스 구현하더라도 다른 클래스 상속 불가
- 4) 익명 클래스를 사용하는 클라이언트는 그 익명 클래스가 상위 타입에서 상속한 멤버 외에는 호출할 수 없다.
- 익명 클래스는 표현식 중간에 등장하므로 길면 가독성이 떨어진다. (**주의할 것**)
- 람다 이전에는 작은 함수 객체나 처리 객체를 만들기위해 사용해왔지만 이제는 아니다.

```java
List<Integer> list = Arrays.asList(10, 5, 6, 7, 1, 3, 4);

// 익명 클래스 사용
Collections.sort(list, new Comparator<Integer>() {
    @Override
    public int compare(Integer o1, Integer o2) {
        return Integer.compare(o1, o2);
    }
		
});

// 람다 도입 후
Collections.sort(list, Comparator.comparingInt(o -> o));
```

- 혹은 정적 팩터리 메서드를 구현할 때 사용될 때가 있다.

### 4️⃣ 지역 클래스

> 지역 변수를 선언 가능하면 실질적으로 어디서든 선언할 수 있고, 유효범위도 지역변수 딱 그정도다.
> 
- 이름 O
- 비정적 문맥에서만 바깥 인스턴스를 참조할 수 있다.
- 정적 멤버는 가질 수 없다. 지역 클래스는 메서드 내부에서 선언되고 해당 메서드가 호출될 때만 존재하는데 반해, 정적 멤버는 클래스 레벨에서 존재하기 때문이다.
- 가독성을 주의해야한다.

```java
public class OuterClass {
    void someMethod() {
        class LocalInnerClass {
            // ...
        }
    }
}
```


