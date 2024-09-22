## ✍️ 개념의 배경

정적 팩터리 메서드 :  정적 메서드를 통해 객체 인스턴스를 생성한다

```java
public static Boolean valueOf(boolean b){return b ? Boolean.TRUE : Boolean.FALSE ;}
```

## 요약

---

### 정적 팩터리 메서드의 장점

1. 이름을 가질 수 있다
    - 반환될 객체의 특성을 알기 쉽게 묘사할 수 있음
    - 같은 시그니처를 사용해도 특징이 다른 여러 객체를 반환하도록 할 수 있음
2. 호출할 때마다 인스턴스를 새로 생성하지 않아도 된다
    - 불변 클래스를 생성하거나, 캐싱에 활용한다 —> 객체 생성 비용절약
    - 인스턴스 통제(instance-controlled) 가 가능하다  ex: 싱글턴
3. 반환할 객체의 클래스(하위 타입 등)를 자유롭게 선택 할 수 있음
    - 최신 자바는 인터페이스에 정적 메서드를 사용할 수 있으므로 다형성을 활용할 수 있다
    - 이를 통해 유연성을 확보할 수 있고 클라이언트가 API 에 가지는 부담이 완화된다
    
    ```java
    interface SmarPhone {
        public static SmarPhone getSamsungPhone() {
            return new Galaxy();
        }
    
        public static SmarPhone getApplePhone() {
            return new IPhone();
        }
    
        public static SmarPhone getChinesePhone() {
            return new Huawei();
        }
    }
    ```
    
4. 입력 매개변수에 따라 매번 다른 클래스의 객체를 반환할 수 있다
    - 3번을 응용하여 메서드 블록 내에서 조건문 분기에 따라 다양한 하위타입을 반환하도록 구현할 수도 있다 
    ex) EnumSet (클라이언트는 어느 하위타입의 인스턴스인지 신경쓰지 않아도 된다)
5. 정적 팩토리 메서드를 작성하는 시점에는 반환할 객체의 클래스가 존재하지 않아도 된다
    - 서비스 제공자 프레임워크를 만들 수 있다
    - ex. JDBC (서비스 제공자 프레임워크)
        
        — 서비스 인터페이스 (Connection) 
        
        — 제공자 등록 API (DriverManager.registerDriver)
        
        — 서비스 접근 API (DriverManager.getConnection)
        

### 정적 팩터리 메서드의 단점

1. 상속을 하려면 `public` 이나 `protected` 생성자가 필요하므로, 정적 팩토리 메서드만 제공하면 하위 클래스를 만들 수 없음
2. 프로그래머가 찾기 어렵다
    
    정적 팩토리 메서드 규약 
    
    | 이름 | 설명 | 예제 |
    | --- | --- | --- |
    | from | 매개변수를 하나 받아 해당 타입의 인스턴스 반환 | Date d = Date.from(instant); |
    | of | 여러 매개변수를 받아 적합한 타입의 인스턴스를 반환 | Set<Rank> faceCards = EnumSet.of(JACK, QUEEN, KING); |
    | valueOf | from 과 of의 더 자세한 버전 |  |
    | getInstance | 매개변수로 명시한 인스턴스 반환, 같은 인스턴스임을 보장하지 않음 | private static final CarsRepository instance = new CarsRepository();
    public static CarsRepository getInstance() {
        return instance;
    } |
    | create |  getInstance와 같지만, 매번 새로운 인스턴스를 생성해 반환함을 보장 |  |
    | getType | 생성할 클래스가 아닌 다른 클래스에서 type을 반환할 때 사용 | FileStore fs = Files.getFileStore(path); |
    | newType | 매번 새로운 인스턴스를 생성 |  |
    | type | getType과 newType의 간결 버전 | List<Complaint> library = Collections.list(legacyLitany); |
    

## 개념 관련 경험

컬렉션 만들 때 많이 씀 

## 이해되지 않았던 부분

## ⭐️ **번외: 추가 조각 지식**

[💠 정적 팩토리 메서드 패턴 (Static Factory Method)](https://inpa.tistory.com/entry/GOF-%F0%9F%92%A0-%EC%A0%95%EC%A0%81-%ED%8C%A9%ED%86%A0%EB%A6%AC-%EB%A9%94%EC%84%9C%EB%93%9C-%EC%83%9D%EC%84%B1%EC%9E%90-%EB%8C%80%EC%8B%A0-%EC%82%AC%EC%9A%A9%ED%95%98%EC%9E%90)

## 질문

