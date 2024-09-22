## ✍️ 개념의 배경

## 요약

---

### 싱글턴 구현 방법 1 : public static final 선언

```java
public class Elvis {
    public static final Elvis INSTANCE = new Elvis();

    private Elvis() { }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.INSTANCE;
        elvis.leaveTheBuilding();
    }
}
```

- 리플렉션을 이용한 공격이 있을 수 있는데 이 경우 두번째 객체가 생성될 때 예외를 던지도록 구현해라
- API 에 싱글턴임이 명확하게 드러난다

### 싱글턴 구현 방법 2: 정적 팩터리

```java
public class Elvis {
    private static final Elvis INSTANCE = new Elvis();
    private Elvis() { }
    public static Elvis getInstance() { return INSTANCE; }

    public void leaveTheBuilding() {
        System.out.println("Whoa baby, I'm outta here!");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.getInstance();
        elvis.leaveTheBuilding();
    }
}
```

- 하나의 장점으로 getInstance 내부 구현만을 변경하여 싱글턴이 아니도록 (혹은 반대로) 바꿀 수 있다
- 제네릭 타입도 활용할 수 있고, 원한다면 팩터리 메서드의 참조를 supplier 로 설정할 수 있음 ( 이것은 나중에 책 더 보고 돌아와야 할듯, 아이템 43-44)

### 싱글턴 구현 방법 3: 열거 타입

```java
public enum Elvis {
    INSTANCE;

    public void leaveTheBuilding() {
        System.out.println("기다려 자기야, 지금 나갈께!");
    }

    // 이 메서드는 보통 클래스 바깥(다른 클래스)에 작성해야 한다!
    public static void main(String[] args) {
        Elvis elvis = Elvis.INSTANCE;
        elvis.leaveTheBuilding();
    }
}
```

- 원소가 하나뿐인 열거 타입을 선언하는 것은 싱글턴을 보증하는 가장 좋은 방법이다

## 개념 관련 경험

(springboot 에서  lombok을 사용하는 경우

의존성 주입할 때  구현 방법 1번을 따르는 듯 하다)

## 이해되지 않았던 부분

## ⭐️ **번외: 추가 조각 지식**

## 질문