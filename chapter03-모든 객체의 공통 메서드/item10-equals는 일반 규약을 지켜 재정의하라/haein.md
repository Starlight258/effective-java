## ✍️ 개념의 배경

`Object.equals()`: 모든 객체가 암묵적으로 상속 받는 메서드로 `“논리적 동치성”` 을 검사한다.

# 요약

---

### `equals`를 재정의하지 않아도 되는 경우

- **각 인스턴스가 본질적으로 고유한 경우**
- **인스턴스의 “논리적 동치성”을 검사할 일이 없는 경우**
- **상위 클래스에서 재정의한 `equals`를 그대로 사용할 수 있는 경우**
- **private, package-private이고 `equals`를 호출할 일이 없는 경우**
    - `equals` 내부에 `new AssertionError()`로 `equals` 호출을 막을 수 있다.

### `equals`를 재정의해야 하는 경우

- 객체 식별성이 아닌 논리적 동치성을 확인해야 하는데, 
상위 클래스 `equals`가 논리적 동치성을 비교하도록 재정의되지 않은 경우
    - 주로 Integer, String과 같은 값 클래스가 해당
    - **참고)** 인스턴스가 오로지 하나라면 객체 식별성과 논리적 동치성이 같은 의미이므로 `equals`를 재정의하지 않아도 된다.
    - 재정의 시 Map의 키, Set의 원소로 사용할 수 있게 된다.

### `equals` 일반 규약

<aside>
🔥 **equals 규약을 어길 경우, 그 객체를 사용하는 다른 객체들이 어떻게 반응할지 알 수 없다.**

</aside>

- **equals는 동치 관계(equivalence relation)을 구현한다.**
    - **동치 관계:** 집합을 서로 같은 원소들로 이뤄진 부분 집합으로 나누는 연산
- **반사성(reflexivity):** null이 아닌 모든 참조 값 x에 대해 `x.equals(x)는 true`
- **대칭성(symmetry):** null이 아닌 모든 참조 값 x, y에 대해 `x.equals(y)가 true라면 y.equals(x)도 true`
    - **반례)** 대소문자를 구별하지 않는 문자열 객체와 String을 호환시키려 하는 경우
        

    ```java
    String s = "polish";
    CaseInsensitiveString cis = new CaseInsensitiveString("Polish");
    
    //대칭성 위배
    cis.equals(s) = true
    s.equals(cis) = false
    ```
    
- **추이성(transitivity):** null이 아닌 모든 참조 값 x, y, z에 대해 `x.equals(y)가 true이고 y.equals(z)도 true라면 x.equals(z)도 true`
    - **반례)** 하위 클래스에 새로운 값 필드가 추가된 경우
        
        
        ```java
        Point p = new Point(1, 2);
        ColorPoint cp = new ColorPoint(1, 2, Color.RED);
        
        //대칭성 위배
        p.equals(cp) = true;
        cp.equals(p) = false;
        ```
        
        
        ```java
        Point p = new Point(1, 2);
        ColorPoint cp1 = new ColorPoint(1, 2, Color.RED);
        ColorPoint cp2 = new ColorPoint(1, 2, Color.BLUE);
        
        //추이성 위배
        cp1.equals(p) = true;
        p.equals(cp2) = true;
        cp1.equals(cp2) = false;
        ```
        
        - 무한 재귀에 빠질 수도 있다.
            - 예시) Point의 하위 클래스 SmellPoint와 동일한 방식으로 구현된 equals에서 
            `myColorPoint.equals(mySmellPoint)`를 호출한 경우
                
                <aside>
                🔥 **구체 클래스를 확장해 새로운 값 필드를 추가하면서 equals 규약을 만족시킬 방법은 없다.**
                instanceOf 대신 getClass로 바꾸면 될 것 같지만, 하위 객체는 상위 객체의 타입으로 활용될 수 있어야 한다는 리스코프 치환 원칙을 따르지 않으므로 객체 지향 원칙을 위배하게 된다.
                
                ****다만, 상속 대신 상위 클래스를 필드로 두는 컴포지션을 사용하면 우회할 수 있다.
                
                </aside>
                
    - **추이성 반례)** `java.util.Date`를 확장한 `java.sql.Timestamp`
        - 한 컬렉션에 넣거나 섞어 사용하면 엉뚱하게 동작할 수 있다.
- **일관성(consistency):** null이 아닌 모든 참조 값 x, y에 대해 x.equals(y)를 반복 호출 시 항상 true거나 항상 false 반환
    - 가변 객체는 시점에 따라 equals 반환값이 달라질 수 있지만,
    불변 객체는 언제나 같아야 한다.
    - **equals 판단에 신뢰할 수 없는 자원이 끼어들면 안된다.**
        - **반례)** URL과 매핑되는 호스트 IP 주소를 기반으로 equals를 재정의한 `java.net.URL`
- **null-아님:** null이 아닌 모든 참조 값 x에 대해 `x.equals(null)는 false`
    - 실수로 `NullPointerException`을 던지지 않아야 한다.
    - `instanceOf` 연산자로 입력 매개변수가 올바른 타입인지 검사해야 한다.
        

### 좋은 equals 구현 방법

1. ==을 이용해 입력이 자기 자신의 참조인지 확인한다.
    - 성능 최적화용
2. instanceOf 연산자로 입력이 올바른 타입인지 확인한다.
    - equals()를 구현한 인터페이스를 구현할 타입일 시 비교에 인터페이스 타입을 사용해야 한다.
3. 입력을 올바른 타입으로 형변환한다.
4. 입력 객체와 자기 자신의 대응되는 핵심 필드들이 모두 일치하는지 하나씩 검사한다.
5. equals를 다 구현했다면 다음 사항을 확인한다.
    - 대칭적인가?
    - 추이성이 있는가?
    - 일관적인가?
- null을 정상값으로 취급하는 필드의 경우, `Objects.equals()`를 사용해 `NullPointerException`을 예방하자
- 비교하기 아주 복잡한 필드를 가진 클래스의 경우, 표준형을 저장하고 표준형끼리 비교하자
- `equals`의 성능을 위해 다를 가능성이 크거나, 비교하는 비용이 싼 필드를 먼저 비교하자

### equals 재정의 시 주의 사항

- equals를 재정의할 땐 hashCode도 반드시 재정의하자
- 너무 복잡하게 해결하려 하지 말자
    - 필드들의 동치성만 검사해도 된다.
- `equals`에서 `Object` 타입만 파라미터로 받자
    - 오버라이딩이 아닌 오버로딩이 된다.

### equals를 제대로 구현했는지 테스트하는 프레임워크

- 구글의 AutoValue
- **참고)** 대다수 IDE도 같은 기능 제공

