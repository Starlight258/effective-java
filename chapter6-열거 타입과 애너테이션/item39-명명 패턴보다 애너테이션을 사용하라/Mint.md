# 39. 명명 패턴보다 애너테이션을 사용하라
# 명명 패턴 (Naming Pattern)
- `메서드`나 `클래스` 이름을 특정 방식으로 지어 역할이나 기능을 나타내는 방법
- 전통적으로 도구나 프레임워크가 특별히 다뤄야 할 프로그램 요소에는 명명 패턴을 적용해왔다.
- `JUnit`은 버전 3까지 테스트 메서드 이름을 test로 시작하게 끔 했다.
- 단점
    - 오타가 나면 안된다. (무시하고 지나간다)
    - 올바른 프로그램 요소에서만 사용되리라 보장할 수 없다.
        - 클래스 이름에 Test를 추가하고 메서드에는 추가하지 않는다면 JUinit은 무시한다.
    - 프로그램 요소를 매개변수로 전달할 마땅한 방법이 없다.
        - 특정 예외를 던져야 하는 테스트가 있을 때 예외를 테스트 매개변수에 전달해야한다면, 메서드 명에 예외를 덧붙이더라도 컴파일러는 이해할 수 없다.
```java
public void testDivideByZeroShouldThrowArithmeticException() {
}
```
> 컴파일러는 문자열로만 인식할 뿐이다.

- java 5부터 도입된 어노테이션을 사용하면 위 문제를 해결할 수 있다.
- 예외를 메서드 이름에 포함시키는 대신, **어노테이션의 파라미터로 전달**한다.
    - 컴파일러가 이해할 수 있고 타입 안전성도 보장된다.
```java
@Test(expected = ArithmeticException.class)
public void divideByZero() {
}
```

# 애너테이션
## 마커(marker) 애너테이션
- 아무 매개변수 없이 단순히 대상에 마킹 한다.
    - Test 이름에 오타를 내거나 메서드 선언 외의 프로그램 요소에 달면 컴파일 오류를 내준다.
```java
/**  
 * 테스트 메서드임을 선언하는 애너테이션이다.  
 * 매개변수 없는 정적 메서드 전용이다.  
 */
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD)  
public @interface Test {  
}
```

### 메타 애너테이션
- 애너테이션 선언에 다는 애너테이션
- `@Retention(RetentionPolicy.RUNTIME)`  : `@Test`가 런타임에도 유지되어야 한다.
- `@Target(ElementType.METHOD)` : `@Test` 는 메서드 선언에서만 사용되어야 한다.

### 마커 애너테이션을 처리하는 프로그램
```java
// 코드 39-3 마커 애너테이션을 처리하는 프로그램 (239-240쪽)  
import java.lang.reflect.*;  
  
public class RunTests {  
    public static void main(String[] args) throws Exception {  
        int tests = 0;  
        int passed = 0;  
        Class<?> testClass = Class.forName(args[0]);  
        for (Method m : testClass.getDeclaredMethods()) {  
            if (m.isAnnotationPresent(Test.class)) {  // 어노테이션 존재하는지 확인
                tests++;  
                try {  
                    m.invoke(null);  
                    passed++;  
                } catch (InvocationTargetException wrappedExc) {  // 예외
                    Throwable exc = wrappedExc.getCause();  
                    System.out.println(m + " 실패: " + exc);  
                } catch (Exception exc) {  // 어노테이션 잘못 사용해서 발생한 예외
                    System.out.println("잘못 사용한 @Test: " + m);  
                }  
            }  
        }  
        System.out.printf("성공: %d, 실패: %d%n",  
                passed, tests - passed);  
    }  
}
```
- `@Test` 를 사용하면 해당 어노테이션에 관심있는 도구에서 특별한 처리를 할 수 있게 해준다.
    - `@Test` 애너테이션이 달린 메서드를 차례로 호출하고, 예외를 던지면 원래 예외에 담긴 실패 정보를 추출해 출력한다.

### 마커 애너테이션을 사용한 프로그램
```java
// 코드 39-2 마커 애너테이션을 사용한 프로그램 예 (239쪽)  
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
- `@Test` 를 붙이지 않은 나머지 메서드는 테스트 도구가 무시한다.

## 매개변수 하나를 받는 어노테이션 타입
- 특정 예외를 던져야만 성공하는 테스트를 지원하는 어노테이션을 만들자.
    - 새로운 애너테이션 타입이 필요하다.

### 매개변수 하나를 받는 어노테이션 타입
```java
// 코드 39-4 매개변수 하나를 받는 애너테이션 타입 (240-241쪽)  
import java.lang.annotation.*;  
  
/**  
 * 명시한 예외를 던져야만 성공하는 테스트 메서드용 애너테이션  
 */  
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD)  
public @interface ExceptionTest {  
    Class<? extends Throwable> value();  
}
```
- 매개변수는 `Throwable` 을 확장한 클래스의 `Class` 객체라는 뜻이며, **모든 예외(와 오류) 타입을 수용**한다.
    - `class 리터럴`은 애너테이션 매개변수의 값으로 사용된다.

### 해당 애너테이션을 처리하는 프로그램
```java
// 마커 애너테이션과 매개변수 하나짜리 애너태이션을 처리하는 프로그램 (241-242쪽)  
public class RunTests {  
    public static void main(String[] args) throws Exception {  
        int tests = 0;  
        int passed = 0;  
        Class<?> testClass = Class.forName(args[0]);  
        for (Method m : testClass.getDeclaredMethods()) {  
            if (m.isAnnotationPresent(Test.class)) {  // @Test 처리
                tests++;  
                try {  
                    m.invoke(null);  
                    passed++;  
                } catch (InvocationTargetException wrappedExc) {  
                    Throwable exc = wrappedExc.getCause();  
                    System.out.println(m + " 실패: " + exc);  
                } catch (Exception exc) {  
                    System.out.println("잘못 사용한 @Test: " + m);  
                }  
            }  
  
            if (m.isAnnotationPresent(ExceptionTest.class)) {  // @ExceptionTest 처리
                tests++;  
                try {  
                    m.invoke(null);  
                    System.out.printf("테스트 %s 실패: 예외를 던지지 않음%n", m);  
                } catch (InvocationTargetException wrappedEx) {  
                    Throwable exc = wrappedEx.getCause(); // 실제 던져진 예외
                    Class<? extends Throwable> excType =  
                            m.getAnnotation(ExceptionTest.class).value();  // @ExceptionTest의 예외
                    if (excType.isInstance(exc)) {  // 기대한 예외인지 확인
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
  
        System.out.printf("성공: %d, 실패: %d%n",  
                passed, tests - passed);  
    }  
}
```
- 애너테이션 매개변수의 값을 추출하여 테스트 메서드가 올바른 예외를 던지는지 확인한다.

### 사용하는 프로그램
```java
// 코드 39-5 매개변수 하나짜리 애너테이션을 사용한 프로그램 (241쪽)  
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
```

## 배열 매개변수를 받는 애너테이션 타입
- 예외를 여러 개 명시하고 그 중 하나가 발생하면 성공하게 만들기

### 배열 매개변수를 받는 애너테이션 타입
- 매개변수 타입을 `Class 객체의 배열`로 수정한다.
```java
// 코드 39-6 배열 매개변수를 받는 애너테이션 타입 (242쪽)  
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD)  
public @interface ExceptionTest {  
    Class<? extends Exception>[] value();  
}
```

### 애너테이션 처리 코드
```java
// 마커 애너테이션과 배열 매개변수를 받는 애너테이션을 처리하는 프로그램 (243쪽)  
public class RunTests {  
    public static void main(String[] args) throws Exception {  
        int tests = 0;  
        int passed = 0;  
        Class<?> testClass = Class.forName(args[0]);  
        for (Method m : testClass.getDeclaredMethods()) {  
            if (m.isAnnotationPresent(Test.class)) {  
                tests++;  
                try {  
                    m.invoke(null);  
                    passed++;  
                } catch (InvocationTargetException wrappedExc) {  
                    Throwable exc = wrappedExc.getCause();  
                    System.out.println(m + " 실패: " + exc);  
                } catch (Exception exc) {  
                    System.out.println("잘못 사용한 @Test: " + m);  
                }  
            }  
  
            // 배열 매개변수를 받는 애너테이션을 처리하는 코드 (243쪽)  
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
                    for (Class<? extends Throwable> excType : excTypes) {  // 명시한 예외들 순회
                        if (excType.isInstance(exc)) { // 기대한 예외인지 확인 
                            passed++;  
                            break;  
                        }  
                    }  
                    if (passed == oldPassed)  
                        System.out.printf("테스트 %s 실패: %s %n", m, exc);  
                }  
            }  
        }  
        System.out.printf("성공: %d, 실패: %d%n",  
                passed, tests - passed);  
    }  
}
```
- 반복문을 돌면서 기대하는 예외인지 확인한다.

### 애너테이션 사용 프로그램
```java
import java.util.*;  
  
// 배열 매개변수를 받는 애너테이션을 사용하는 프로그램 (242-243쪽)  
public class Sample3 {  
    // 이 변형은 원소 하나짜리 매개변수를 받는 애너테이션도 처리할 수 있다. (241쪽 Sample2와 같음)  
    @ExceptionTest(ArithmeticException.class)  
    public static void m1() {  // 성공해야 한다.  
        int i = 0;  
        i = i / i;  
    }  

    // 코드 39-7 배열 매개변수를 받는 애너테이션을 사용하는 코드 (242-243쪽)  
    @ExceptionTest({ IndexOutOfBoundsException.class,  
                     NullPointerException.class })  
    public static void doublyBad() {   // 성공해야 한다.  
        List<String> list = new ArrayList<>();  
  
        // 자바 API 명세에 따르면 다음 메서드는 IndexOutOfBoundsException이나  
        // NullPointerException을 던질 수 있다.  
        list.addAll(5, null);  
    }  
}
```

## 반복 가능한 애너테이션 타입
- 배열 매개변수를 사용하는 대신 `@Repeatable` 메타 애너테이션을 단다.
    - `@Repeatable` : 하나의 프로그램 요소에 여러번 달 수 있다.

### 작성 방법
#### 1. `@Repeatable` 단 애너테이션을 반환하는 `컨테이너 애너테이션`을 정의한다.
```java
// 반복 가능한 애너테이션의 컨테이너 애너테이션 (244쪽)  
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD)  
public @interface ExceptionTestContainer {  
    ExceptionTest[] value();  
}
```
- 내부 어노테이션 타입의 배열을 반환하는 `value()`를 정의해야 한다.
- 적절한 `@Retention` 과 `@Target` 을 명시해야 한다.
> 한 요소에 동일한 어노테이션을 여러번 적용하기 위해 우회하는 방법이다.

#### 2. `@Repeatable` 에 컨테이너 애너테이션의 `class 객체`를 매개변수로 전달한다.
```java
// 코드 39-8 반복 가능한 애너테이션 타입 (243-244쪽)  
@Retention(RetentionPolicy.RUNTIME)  
@Target(ElementType.METHOD)  
@Repeatable(ExceptionTestContainer.class) // 컨테이너 애너테이션
public @interface ExceptionTest {  
    Class<? extends Throwable> value();  
}
```

#### 참고) 컨테이너 어노테이션
- Java 런타임은 반복된 어노테이션을 사용할 때 이를 컨테이너 어노테이션으로 감싸서 처리한다.
- 애너테이션 사용 코드
```java
@ExceptionTest(IndexOutOfBoundsException.class)
@ExceptionTest(NullPointerException.class)
public void doublyBadTest() { ... }
```
- 내부 처리 코드
```java
@ExceptionTestContainer({
    @ExceptionTest(IndexOutOfBoundsException.class),
    @ExceptionTest(NullPointerException.class)
})
public void doublyBadTest() { ... }
```

- 하나만 사용할 때는 컨테이너 어노테이션으로 감싸지 않는다.
- 장점 : `getAnnotationsByType`는 단일 어노테이션이든 여러 개의 어노테이션이든 상관없이 항상 배열을 반환한다.
```java
ExceptionTest[] tests = method.getAnnotationsByType(ExceptionTest.class);
```
- 어노테이션 수와 상관없이 동일한 코드로 처리할 수 있다.
```java
for (ExceptionTest test : tests) {
}
```

### 반복 가능 애너테이션 처리 코드
```java
// 마커 애너테이션과 반복 가능 애너테이션을 처리하는 프로그램 (244-245쪽)  
public class RunTests {  
    public static void main(String[] args) throws Exception {  
        int tests = 0;  
        int passed = 0;  
        Class testClass = Class.forName(args[0]);  
        for (Method m : testClass.getDeclaredMethods()) {  
            if (m.isAnnotationPresent(Test.class)) {  
                tests++;  
                try {  
                    m.invoke(null);  
                    passed++;  
                } catch (InvocationTargetException wrappedExc) {  
                    Throwable exc = wrappedExc.getCause();  
                    System.out.println(m + " 실패: " + exc);  
                } catch (Exception exc) {  
                    System.out.println("잘못 사용한 @Test: " + m);  
                }  
            }  
  
            // 코드 39-10 반복 가능 애너테이션 다루기 (244-245쪽)  
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
        }  
        System.out.printf("성공: %d, 실패: %d%n",  
                          passed, tests - passed);  
    }  
}
```
- 반복 가능 애너테이션을 여러개 달면 하나만 달았을 때 와 구분하기 위해 해당 컨테이너 애너테이션 타입이 적용된다.
    - `getAnnotationByType` : 반복 가능 애너테이션과 그 컨테이너 애너테이션을 모두 가져온다.
    - `isAnnotationPresent` : 반복 가능 애너테이션과 그 컨테이너 애너테이션을 구분한다.
        - 특정 타입의 어노테이션이 존재하는지 확인한다.
- 어노테이션을 여러 번 단 경우 컨테이너 어노테이션이 존재하고, 그렇지 않은 경우 컨테이너 어노테이션이 존재하지 않는다.
    - 둘을 따로따로 확인해야 한다.
```java
if (m.isAnnotationPresent(ExceptionTest.class)  
		|| m.isAnnotationPresent(ExceptionTestContainer.class)) {  
```

#### getAnnotationByType, isAnnotationPresent
1. 애너테이션 정의
```java
import java.lang.annotation.*;

@Repeatable(ExceptionTestContainer.class)
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTest {
    Class<? extends Throwable> value();
}

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface ExceptionTestContainer {
    ExceptionTest[] value();
}
```

2. 테스트 클래스
```java
public class Sample {
@ExceptionTest(IndexOutOfBoundsException.class)
public void testSingleException() { }

@ExceptionTest(IndexOutOfBoundsException.class)
@ExceptionTest(NullPointerException.class)
public void testMultipleExceptions() { }
}
```
- `testSingleException` : 어노테이션 한번 쓴 클래스
- `testMultipleExceptions` : 어노테이션 여러번 쓴 클래스
    - 컨테이너 애너테이션으로 감싸져 있다.

3. 애너테이션 처리 및 출력 코드
```java
public class AnnotationProcessor {
    public static void main(String[] args) {
        processAnnotations(Sample.class);
    }

    public static void processAnnotations(Class<?> clazz) {
        for (Method method : clazz.getDeclaredMethods()) {
            System.out.println("Processing method: " + method.getName());
            
            ExceptionTest[] tests = method.getAnnotationsByType(ExceptionTest.class);
            
            System.out.println("Number of ExceptionTest annotations: " + tests.length); 
            
            for (ExceptionTest test : tests) {
                System.out.println("  Exception type: " + test.value().getSimpleName());
            }
            
            System.out.println("Is ExceptionTest present? " + 
                method.isAnnotationPresent(ExceptionTest.class));
            System.out.println("Is ExceptionTestContainer present? " + 
                method.isAnnotationPresent(ExceptionTestContainer.class));
            
            System.out.println(); // 줄바꿈
        }
    }
}
```

```java
Processing method: testSingleException
Number of ExceptionTest annotations: 1
  Exception type: IndexOutOfBoundsException
Is ExceptionTest present? true
Is ExceptionTestContainer present? false

Processing method: testMultipleExceptions
Number of ExceptionTest annotations: 2
  Exception type: IndexOutOfBoundsException
  Exception type: NullPointerException
Is ExceptionTest present? false
Is ExceptionTestContainer present? true
```

### 애너테이션 사용 프로그램
```java
// 반복 가능한 애너테이션을 사용한 프로그램 (244쪽)  
public class Sample4 {  
    // 코드 39-9 반복 가능 애너테이션을 두 번 단 코드 (244쪽)  
    @ExceptionTest(IndexOutOfBoundsException.class)  
    @ExceptionTest(NullPointerException.class)  
    public static void doublyBad() {  
        List<String> list = new ArrayList<>();  
  
        // 자바 API 명세에 따르면 다음 메서드는 IndexOutOfBoundsException이나  
        // NullPointerException을 던질 수 있다.  
        list.addAll(5, null);  
    }  
}
```

### 주의할 점
- 반복 가능 애너테이션을 사용하면 코드 양이 늘어나며 처리 코드가 복잡해져 오류가 날 가능성이 커진다.

# 결론
- 애너테이션으로 할 수 있는 일을 명명 패턴으로 처리할 이유는 없다.
- `java` 프로그래머라면 예외 없이 자바가 제공하는 애너테이션 타입들을 사용해야 한다.
