# 15. 클래스와 멤버의 접근 권한을 최소화하라.

## 캡슐화
### 잘 설계된 컴포넌트란?
- **캡슐화**가 잘 지켜진 컴포넌트이다.
    - **클래스 내부 데이터와 내부 구현 정보를 외부 컴포넌트로부터 잘 숨긴다**.
    - 모든 내부 구현을 완벽히 숨겨, **구현(내부 로직)과 API(public, 외부 공개)를 깔끔하게 분리**한다.
    - 오직 API를 통해서만 다른 컴포넌트와 소통하며, 서로의 내부 동작 방식에는 전혀 개의치 않는다.
```java
public class BankAccount {
    private double balance;  // 내부 구현

    // API (외부 공개)
    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }

    // API
    public boolean withdraw(double amount) {
        if (amount > 0 && balance >= amount) {
            balance -= amount;
            return true;
        }
        return false;
    }

    // API
    public double getBalance() {
        return balance;
    }
}
```

### 캡슐화의 장점
1. 시스템 **개발 속도**를 높인다.
    - 여러 컴포넌트를 병렬로 개발할 수 있기 때문이다.
2. 시스템 **관리 비용**을 낮춘다.
    - 컴포넌트를 파악하기 쉽고 다른 컴포넌트로 대체하기 쉽다.
3. **성능 최적화**에 도움이 된다.
    - 다른 컴포넌트에 영향을 주지 않고 해당 컴포넌트만 최적화할 수 있다.
4. 소프트웨어 **재사용성**을 높인다.
    - 낯선 환경에서도 독자적으로 동작할 수 있다.
5. 큰 시스템을 제작하는 **난이도를 낮춰준다**.
    - 전체 시스템이 완성되지 않았더라도 개별 컴포넌트의 동작을 검증할 수 있다.

## 접근 제어 메커니즘
- 클래스, 인터페이스, 멤버의 접근성(접근 허용 범위)을 명시한다.
    - 각 요소의 접근성은 그 요소가 선언된 **위치**와 **접근 제한자**로 정해진다.
- 접근 제한자를 활용하는 것이 캡슐화(정보 은닉)의 핵심이다.
- 접근 제한자
    - **private** : 멤버를 선언한 톱 클래스에서만 접근 가능
    - **package-private**: 같은 패키지 안에서만 접근 가능
    - **protected**: 같은 패키지 + 다른 패키지의 하위 클래스에서 접근 가능
    - **public** : 모든 곳에서 접근 가능

### 모든 클래스와 멤버의 접근성을 가능한 한 좁혀야 한다.
- 소프트웨어가 올바로 동작하는 한 항상 가장 낮은 접근 수준을 부여해야 한다.
- **top-level 클래스(가장 바깥 클래스, 독립적인 클래스, .java)와 인터페이스**에 부여할 수 있는 접근 수준은 **package-private**과 **public** 2가지이다.
    - **protected**이 안되는 이유 : 적용시 논리적 모순이 생긴다. protected class는 상속을 받아야 볼 수 있는데, 가장 바깥(top-level, interface)이므로 접근 조차 불가능하다.
    - **private**이 안되는 이유: top-level 클래스나 인터페이스를 아무 곳에서도 사용할 수 없게 된다.

#### 클래스 : **공개 API는 public**으로, **내부 구현은 package-private**으로 선언하자.
- 패키지 외부에서 쓸 이유가 없다면 package-private으로 선언하자. 내부 구현이 되어 언제든 수정이 가능하다.
- public으로 선언시 api가 되므로 하위 호환을 위해 영원히 관리해주어야한다.

#### 멤버 : 클래스의 **공개 API**를 세심하게 설계한 후, **그 외의 모든 멤버는 private**으로 만들자.
- 그 다음 오직 **같은 패키지의 다른 클래스가 접근해야 하는 멤버에 한하여 package-private**으로 풀어주자.
> 권한을 풀어주는 일을 자주 하게 된다면 시스템에서 컴포넌트를 더 분해해야하는 것은 아닌지 고민해보자.

- public 클래스의 protected 멤버도 공개 API이다.
    - 멤버의 접근 수준을 package-private에서 protected로 변경할 경우 멤버에 접근할 수 있는 대상 범위가 매우 넓어지므로 주의해야한다.
    - **protected 멤버의 수는 적을 수록 좋다.**

> Serializable을 구현한 클래스의 경우 private과 package-private의 멤버가 직렬화 과정에서 저장되고,
> 역직렬화시 복원되므로 실질적으로 클래스의 공개 api가 될 수 있어 주의해야한다.
> 필요할 경우 @Transient를 이용해 직렬화에서 제거하는 것을 고려하자.

#### 제약사항 : 상위 클래스의 메서드를 재정의할 때는 그 접근 수준을 상위 클래스보다 좁게 설정할 수 없다.
- 리스코프 치환 원리(상위 클래스의 인스턴스는 하위 클래스의 인스턴스로 대체해 사용할 수 있어야한다)를 지키기 위해 필요하다.
- 하위 클래스의 접근 수준을 좁히지 못하는 제약 사항이 되기도 한다.

### 한 클래스에서만 사용하는 package-private 톱레벨 클래스나 인터페이스는 **사용하는 클래스 안에 private static으로 중첩**시키자.
- top-level로 두면 패키지의 모든 클래스에서 접근이 가능하지만, private static으로 중첩시키면 바깥 클래스 하나에서만 접근이 가능하다.

- 기존 방식
```java
class Helper {
    void help() {
        System.out.println("I'm helping!");
    }
}

public class MainClass {
    void doSomething() {
        Helper helper = new Helper();
        helper.help();
    }
}
```
> MainClass외의 다른 클래스도 Helper에 접근 가능하다.

- 내부 private static 클래스로 선언
```java
public class MainClass {
    private static class Helper {
        void help() {
            System.out.println("I'm helping!");
        }
    }

    void doSomething() {
        Helper helper = new Helper();
        helper.help();
    }
}
```
> **private** : Helper는 MainClass 외의 다른 클래스에서 접근이 불가능하다.

> **static**으로 선언한 이유: 메모리 누수를 방지하기 위해서이다.
static으로 선언시 내부 클래스가 외부 클래스의 인스턴스에 대한 참조를 가지지 않기 때문에, 내부 클래스의 인스턴스가 살아있더라도 **외부 클래스가 독립적으로 GC 대상**이 될 수 있다.
반면에 non-static 내부 클래스의 경우, 외부 클래스의 인스턴스에 대한 참조를 가져 **내부 클래스가 살아있는 한 외부 클래스는 참조를 가지므로 GC 대상이 아니다**.

### 테스트만을 위해 클래스, 인터페이스, 멤버를 공개 API로 만들어서는 안된다.
- 단지 코드를 테스트할 목적으로 클래스, 인터페이스, 멤버의 접근 범위를 넓히려 할 때가 있다.
    - 적당한 수준(public 클래스의 private 멤버를 package-private으로 변경)까지는 괜찮다.
    - 그 이상은 안된다.
- 테스트 코드를 테스트 대상과 같은 패키지에 두면 pakcage-private 요소에 접근할 수 있다.
> 테스트 대상과 테스트를 함께 둘 일은 얼마 없을 듯 하다..

### public 클래스의 인스턴스 필드는 되도록 public이 아니어야 한다.
- 필드가 **가변 객체를 참조**하거나, **final이 아닌 인스턴스 필드**를 public으로 선언하면 **불변식을 보장할 수 없게 된다.**
```java
class BadExample {
    public List<String> names; // 가변 객체 참조
    public int age; // final이 아닌 인스턴스 필드

    public BadExample(List<String> names, int age) {
        this.names = names;
        this.age = age;
    }
}

class GoodExample {
    private final List<String> names;
    private int age;

    public GoodExample(List<String> names, int age) {
        this.names = new ArrayList<>(names);  // 방어적 복사
        this.age = age;
    }

    public List<String> getNames() {
        return Collections.unmodifiableList(names);
    }
}

public class Main {
    public static void main(String[] args) {
        List<String> nameList = Arrays.asList("Alice", "Bob");
        
        BadExample bad = new BadExample(nameList, 25);
        bad.names.clear();  // 외부에서 직접 리스트를 수정
        bad.age = -5;  // 불변식 위반 (나이가 음수)

        GoodExample good = new GoodExample(nameList, 25);
        try {
	         names.add("Charlie"); // UnsupportedOperationException 발생 
        } catch (UnsupportedOperationException e) {
	         System.out.println("Can't modify the list"); 
        }
    }
}
```

- **public 가변 필드를 갖는 클래스는** 필드가 수정될 때 lock 획득 같은 다른 작업을 할 수 없고 **필드 접근을 제어할 수 없으므로, 스레드 안전하지 않다.**
```java
public class UnsafeCounter {
    public int count;  // public 가변 필드
}
```
여러 외부 클래스에서 count를 직접 접근할 수 있어 lock 동작을 수행할 수 없다.

- 필드를 private로 변경한다면 필드 접근을 제어할 수 있다.
```java
public class SafeCounter {
    private int count;  // private 필드
    private final Lock lock = new ReentrantLock();

    public void increment() {
        lock.lock();  // 락 획득
        try {
            count++;
        } finally {
            lock.unlock();  // 락 해제
        }
    }
}
```

#### 해당 클래스가 표현하는 추상 개념을 완성하는 데 꼭 필요한 구성요소로써의 **상수**라면 public static final 필드로 공개해도 좋다.
```java
public class MathConstants {
    public static final double PI = 3.141592;
}
```
- `대문자 알파벳`과 `_`을 넣는다.
- **기본 타입 값**이나 **불변 객체**를 참조해야 한다.

#### 클래스에서 public static final 배열 필드를 두거나 이 필드를 반환하는 접근자 메서드를 제공해서는 안된다.
```java
// 문자열 배열
String[] names = {"Alice", "Bob", "Charlie"};
names[1] = "David";  

public static final Thing[] VALUES = {...};
```
- Java에서 배열은 객체이다.
    - 배열이 생성되면 그 크기는 고정되지만, **배열 내의 요소들은 변경 가능**하다.
    - 길이가 0인 배열은 요소가 없으므로 변경할 수 없다.
    - 길이가 0이 아닌 배열은 요소가 하나 이상 있으므로 그 요소들의 값을 변경할 수 있기 때문에 변경이 가능하다.

- 참고) **String[]** vs **Thing[]**
    - String[]은 문자열 객체의 배열이고 각 요소가 불변이다. 문자열 pool을 사용할 수 있고 heap에 저장된다.
        - 같은 내용의 문자열 리터럴은 풀 내에서 하나의 인스턴스만 유지하므로 메모리 사용이 최적화된다.
    - Thing[]은 사용자 정의 클래스나 그 클래스의 하위 클래스의 객체 배열이고 가변일 수 있다. 별도의 heap 메모리를 사용한다.

- 배열 필드를 반환하는 **접근자 메서드**를 제공해서는 안된다.
    - 외부에서 배열의 요소를 변경할 수 있다.
```java
public class UnsafeExample {
    private static final String[] COLORS = {"Red", "Green", "Blue"};
    
    public static String[] getColors() { // 접근자 메서드
        return COLORS;
    }
}

public class Main {
    public static void main(String[] args) {
        String[] colors = UnsafeExample.getColors();
        colors[0] = "Yellow";  // Red가 Yellow로 변경됨
        System.out.println(Arrays.toString(UnsafeExample.getColors()));  // [Yellow, Green, Blue]
    }
}
```

#### 해결책 1 : public 배열을 private으로 만들고 public 불변 리스트를 추가한다.
```java
private static final Thing[] PRIVATE_VALUES = {...};
public static final List<Thing> VALUES = 
    Collections.unmodifidableList(Arrays.asList(PRIVATE_VALUES));
```
- 직접적인 외부 접근을 막는다.
- unmodifidableList로 변경 불가능한 view를 만든다.
    - 배열의 요소가 가변이라면 변경 가능하다.

#### 해결책 2 : public 배열을 private으로 만들고 그 복사본을 반환하는 public 메서드를 추가한다.
```java
private static final Thing[] PRIVATE_VALUES = {...};
public static final Thing[] values() {
    return PRIVATE_VALUES.clone();
}
```
- clone()을 사용해 배열의 복사본을 반환한다.

### 모듈 시스템
- **모듈은 패키지들의 묶음**이다.
- 자신에 속한 패키지 중 **공개할(export) 것들을 선언**한다.
    - protected 혹은 public 멤버라도 해당 패키지를 공개하지 않았다면 모듈 외부에서는 접근할 수 없다.
    - 모듈 시스템을 활용하여 외부에 클래스를 공개하지 않으면서도 같은 모듈을 이루는 패키지 사이에서는 자유롭게 공유할 수 있다.
- 숨겨진 패키지 안에 있는 public 클래스의 public 혹은 protected는 효과가 모듈 내로 한정된다.
> 모듈의 JAR 파일을 자신의 모듈 경로가 아닌 애플리케이션의 classpath에 두면 그 모듈 안의 모듈 패키지는 모듈이 없는 것처럼 행동한다.
- jdk는 모듈 시스템의 접근 수준을 적극적으로 활용한 예시이다.

- 모듈 예시
```java
module com.example.api {
    exports com.example.api.public_package; // 공개할 패키지
}

package com.example.api.public_package;

public class PublicAPI {
    public void publicMethod() {
        System.out.println("This is a public API method");
        internalMethod();
    }

    private void internalMethod() {
        System.out.println("This is an internal method");
    }
}

// 공개하지 않는 패키지
package com.example.api.internal_package;

public class InternalAPI {
    public void internalMethod() {
        System.out.println("This is an internal API method");
    }
}
```
- 사용
```java
module com.example.client {
    requires com.example.api; // Client에서 사용할 모듈
}

package com.example.client;

import com.example.api.public_package.PublicAPI;

public class Client {
    public static void main(String[] args) {
        PublicAPI api = new PublicAPI(); // 공개된 패키지만 사용 가능
        api.publicMethod();
    }
}
```
#### 모듈 시스템을 잘 사용하는 방법
1. 패키지들을 모듈 단위로 묶고, 모듈 선언에 패키지들의 모든 의존성을 명시한다.
2. 소스 트리를 재배치하고, 모듈 안으로부터 일반 패키지로의 모든 접근에 조취를 취해야한다.

### 결론
- 프로그램 요소의 접근성은 가능한 한 최소한으로 하자.
    - 꼭 필요한 것만 골라 최소한의 public api를 설계하자.
    - 그 외에는 클래스, 인터페이스, 멤버가 의도치 않게 api로 공개되는 일이 없도록 해야 한다.
- public 클래스는 상수용 public static final 필드  외에는 어떠한 public 필드도 가져서는 안된다.
    - public static final 필드가 참조하는 객체가 불변인지 확인하라.

