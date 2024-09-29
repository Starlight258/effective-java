## ✍️ 개념의 배경

명명 패턴: 프로그램 요소의 이름을 일관된 방식으로 작성하는 패턴 

에너테이션(annotation): 

- 소스코드 주석에 다른 프로그램을 위한 메타데이터를 포함시킨 것
- 미리 정의된 “@” 태그를 붙여 (@override, @test ….)  다른 프로그램에게 유용한 정보를 제공하며 프로그램 간의 “주석” 처럼 사용
- 표준 애너테이션, 메타 애너테이션, 사용자정의 애너테이션 등으로 구분

# 요약

---

### 명명 패턴의 단점

- 오타가 나면 안 됨
- 올바른 프로그램 요소에서만 사용되리라 보증할 방법이 없다
- 프로그램 요소를 매개변수로 전달할 마땅한 방법이 없다

### 마커 애너테이션

```java
import java.lang.annotation.*;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Test {
}
```

- Retention :  `@Test`가 런타임에도 유지되어야 한다는 의미이며, 만약 이를 생략하면 테스트 도구는 `@Test`를 인식할 수 없게 된다.
(RetentionPolicy.Source, Class 등도 있음)
- Target : `@Test`가 반드시 메서드 선언에만 사용되어야 한다고 알려주는 것

아무 매개변수 없이 단순히 대상에 마킹한다는 뜻에서 마커(marker) 애너테이션이라고 함  

```java
public class Sample {
    @Test
    public static void m1() { }        // 성공해야 한다.
    public static void m2() { }
    @Test public static void m3() {    // 실패해야 한다.
        throw new RuntimeException("실패");
    }
    public static void m4() { }  // 테스트가 아니다.
    @Test public void m5() { }   // 잘못 사용한 예: 정적 메서드가 아니다.
    public static void m6() { }
    @Test public static void m7() {    // 실패해야 한다.
        throw new RuntimeException("실패");
    }
    public static void m8() { }
}
```

- 애너테이션을 달아준 매서드들만 테스트 도구가 인식함

```java

public class RunTests {
    public static void main(String[] args) throws Exception {
        int tests = 0;
        int passed = 0;
        Class<?> testClass = Class.forName(args[0]);
        for (Method m : testClass.getDeclaredMethods()) {
            if (m.isAnnotationPresent(Test.class)) {
                tests++;
                try {
                    m.invoke(null); // 정적 메서드 , 매개변수 x 
                    passed++;
                } catch (InvocationTargetException wrappedExc) {
                    Throwable exc = wrappedExc.getCause();
                    System.out.println(m + " 실패: " + exc);
                } catch (Exception exc) {
                    System.out.println("잘못 사용한 @Test: " + m);
                }
            }
        }
        System.out.printf("성공: %d, 실패: %d%n",
                passed, tests - passed);
    }
}
```

- getDeclaredMethods:  클래스의 메서드 목록 호출
- isAnnotationPresent : Test 애너테이션이 선언된 메서드들을 호출
- Invoke: 정적  메소드 호출(null), 예외 발생 시엔 원래 예외를 InvocationTargetException 로 래핑해서 던짐
- 애너테이션은 표시만 해주는 것이며 단지 이를 활용하는 프로그램에 추가적인 정보를 제공함

### 매개변수 하나를 받는 애너테이션

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTest {
    Class<? extends Throwable> value();
}
```

- 특정 예외를 던져야만 성공하는 테스트를 위한 애너테이션
- 애너테이션의 매개변수로 Throwable 를 확장한 모든 클래스를 지정

```java
public class Sample2 {
    @ExceptionTest(ArithmeticException.class)
    public static void m1() {  // 성공해야 한다.
        int i = 0;
        i = i / i;
    }
    @ExceptionTest(ArithmeticException.class)
    public static void m2() {  // 실패해야 한다. (다른 예외 발생)
        int[] a = new int[0];
        int i = a[1];
    }
    @ExceptionTest(ArithmeticException.class)
    public static void m3() { }  // 실패해야 한다. (예외가 발생하지 않음)
}

if (m.isAnnotationPresent(ExceptionTest.class)) {
                tests++;
                try {
                    m.invoke(null);
                    System.out.printf("테스트 %s 실패: 예외를 던지지 않음%n", m);
                } catch (InvocationTargetException wrappedEx) {
                    Throwable exc = wrappedEx.getCause();
                    Class<? extends Throwable> excType =
                            m.getAnnotation(ExceptionTest.class).value();
                    if (excType.isInstance(exc)) {
                        passed++;
                    } else {
                        System.out.printf(
                                "테스트 %s 실패: 기대한 예외 %s, 발생한 예외 %s%n",
                                m, excType.getName(), exc);
                    }
                } catch (Exception exc) {
                    System.out.println("잘못 사용한 @ExceptionTest: " + m);
                }
            }
        }
```

- 애너테이션 매개변수의 값을 추출하여 올바른 예외를 던지는 지 확인

### 다수의 예외를 명시하는 애너테이션(1) : 배열 매개변수를 받는 애너테이션

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTest {
    Class<? extends Exception>[] value();
}

@ExceptionTest({ IndexOutOfBoundsException.class,
                     NullPointerException.class })
    public static void doublyBad() {   // 성공해야 한다.
        List<String> list = new ArrayList<>();

        // 자바 API 명세에 따르면 다음 메서드는 IndexOutOfBoundsException이나
        // NullPointerException을 던질 수 있다.
        list.addAll(5, null);
    }
```

- 여러 예외를 받아, 그 중 하나가 발생하면 테스트가 성공할 수 있도록 하는 경우
- 원소들을 중괄호로 감싸고, 쉼표로 구분하여 배열 입력

```java
if (m.isAnnotationPresent(ExceptionTest.class)) {
                tests++;
                try {
                    m.invoke(null);
                    System.out.printf("테스트 %s 실패: 예외를 던지지 않음%n", m);
                } catch (Throwable wrappedExc) {
                    Throwable exc = wrappedExc.getCause();
                    int oldPassed = passed;
                    Class<? extends Throwable>[] excTypes =
                            m.getAnnotation(ExceptionTest.class).value();
                    for (Class<? extends Throwable> excType : excTypes) {
                        if (excType.isInstance(exc)) {
                            passed++;
                            break;
                        }
                    }
                    if (passed == oldPassed)
                        System.out.printf("테스트 %s 실패: %s %n", m, exc);
                }
            }
```

### 다수의 예외를 명시하는 애너테이션(2) : Repeatable

- 자바 8에서는 배열 대신 @Repeatable 메타 애너테이션을 사용하여 코드 가독성을 높일 수 있음
- `@Repeatable`을 단 애너테이션을 반환하는 '컨테이너 애너테이션'을 하나 더 정의하고, `@Repeatable`에 이 컨테이너 애너테이션의 class 객체를 매개변수로 전달해야 한다.
- 컨테이너 애너테이션은 내부 애너테이션 타입의 배열을 반환하는 value 메서드를 정의
- 컨테이너 애너테이션 타입에는 적절한 보존 정책(@Retention)과 적용 대상(@Target)을 명시해야 한다.(그렇지 않으면 컴파일 X)

먼저 반복 가능한 애너테이션 정의

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
@Repeatable(ExceptionTestContainer.class)
public @interface ExceptionTest {
    Class<? extends Throwable> value();
}
```

애너테이션을 반환하는 컨테이너 정의 

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTestContainer {
    ExceptionTest[] value();
}
```

실제 적용 모습

```java
@ExceptionTest(IndexOutOfBoundsException.class)
@ExceptionTest(NullPointerException.class)
public static void doublyBad() {...}
```

- 애너테이션을 여러개 달면 하나만 달았을 때와 구분하기 위해 해당 '컨테이너' 애너테이션 타입이 적용
- isAnnotationPresent() (반복 가능 애너테이션을 여러 번 달았을 때 그렇지 않다고 대답함 )
    - 반복 가능 애너테이션 검사 : 컨테이너가 달렸으므로 false 호출
    - `AnnotatedElement.getAnnotationsByType()` : 원래 에너테이션과 컨테이너 에너테이션을 구분하지 않음. 따라서 두 경우 모두 가져옴
    - 컨테이너 애너테이션 검사  : 반복 가능 애너테이션이 한 번만 달려있는 메서드가 무시됨
    - `AnnotatedElement.isAnnotationPresent()` : 원래 에너테이션과 컨테이너 에너테이션을 구분함

```java
if (m.isAnnotationPresent(ExceptionTest.class)
                    || m.isAnnotationPresent(ExceptionTestContainer.class)) {
                tests++;
                try {
                    m.invoke(null);
                    System.out.printf("테스트 %s 실패: 예외를 던지지 않음%n", m);
                } catch (Throwable wrappedExc) {
                    Throwable exc = wrappedExc.getCause();
                    int oldPassed = passed;
                    ExceptionTest[] excTests =
                            m.getAnnotationsByType(ExceptionTest.class);
                    for (ExceptionTest excTest : excTests) {
                        if (excTest.value().isInstance(exc)) {
                            passed++;
                            break;
                        }
                    }
                    if (passed == oldPassed)
                        System.out.printf("테스트 %s 실패: %s %n", m, exc);
                }
            }
```
- 테스트코드가 반복 가능 버전을 사용하도록 함 



##  ElementType 정리

| ElementType 열거상수 | 적용대상 |  |
| --- | --- | --- |
| TYPE | 클래스, 인터페이스, 열거타입 |  |
| ANNOTAION_TYPE | 어노테이션 |  |
| FIELD | 필드 |  |
| CONSTRUCTOR | 생성자 |  |
| METHOD | 메소드 |  |
| LOCAL_VARIABLE | 로컬 변수 |  |
| PACKAGE | 패키지 |  |

