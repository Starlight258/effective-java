# 70. 복구할 수 있는 상황에는 검사 예외를, 프로그래밍 오류에는 런타임 예외를 사용하라
## 문제 상황을 알리는 타입(throwable)
- 검사 예외
- 런타임 예외
- 에러(Error)

#### 참고) Throwable vs Exception vs Error
- `Throwable`
    - Java에서 **모든 오류와 예외의 최상위 클래스**
    - `Exception`과 `Error` 클래스의 부모 클래스
    - try-catch 블록으로 잡을 수 있는 모든 객체의 기본 클래스
- `Exception`
    - `Throwable`의 하위 클래스
    - 프로그램이 처리할 수 있는 예외적인 상황
        - a) `Checked Exceptions`: 컴파일러가 처리를 강제하는 예외 (ex) `IOException`)
        - b) `Unchecked Exceptions`: 런타임에 발생하는 예외 (ex) `NullPointerException`)
    - 대부분 애플리케이션 코드에서 처리할 수 있거나 처리해야 하는 상황
- `Error`
    - `Throwable`의 또 다른 하위 클래스
    - 심각하고 일반적으로 복구 불가능한 상황
        - Exception과 달리 일반적으로 애플리케이션에서 처리하지 않음
    - 주로 `JVM`에 의해 발생하며, 애플리케이션 코드에서 잡거나 처리하려고 시도하지 않아야 함
    - ex) `OutOfMemoryError`, `StackOverflowError`

### 호출하는 쪽에서 복구하리라 여겨지는 상황이라면 검사 예외를 사용하라
- 검사 예외를 던지면 호출자가 그 예외를 catch로 잡아 처리하거나 더 바깥으로 전파하도록 강제하게 된다.
- 검사 예외를 던지며 그 상황에서 회복해내라고 요구한다.
    - API 사용자는 예외를 잡기만 하고 별다른 조치를 취하지 않을 수도 있지만, 이는 좋지 않은 생각이다.
```java
import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class FileReader {
    public static String readFile(String fileName) throws FileNotFoundException {
        File file = new File(fileName);
        StringBuilder content = new StringBuilder();
        
        try (Scanner scanner = new Scanner(file)) {
            while (scanner.hasNextLine()) {
                content.append(scanner.nextLine()).append("\n");
            }
        }
        
        return content.toString();
    }

    public static void main(String[] args) {
        try {
            String content = readFile("example.txt");
            System.out.println("파일 내용: " + content);
        } catch (FileNotFoundException e) {
            System.out.println("파일을 찾을 수 없습니다. 파일 이름을 확인해주세요.");
            // 파일 이름 다시 입력받는 등의 복구 작업 수행하기
        }
    }
}
```
## 비검사 throwable
- 종류
    - 런타임 예외
    - 에러
- 프로그램에서 잡을 필요가 없거나 혹은 통상적으로 잡지 말아야 한다.
- 복구가 불가능하거나 더 실행해봐야 득보다는 실이 많다는 뜻이다.
- 이런 throwable을 잡지 않은 스레드는 적절한 오류 메세지를 내뱉으며 중단된다.
```java
public class ArrayProcessor {
    public static int getElement(int[] array, int index) {
        if (index < 0 || index >= array.length) {
            throw new IllegalArgumentException("유효하지 않은 인덱스입니다: " + index);
        }
        return array[index];
    }

    public static void main(String[] args) {
        int[] numbers = {1, 2, 3, 4, 5};
        
        System.out.println("3번 인덱스의 값: " + getElement(numbers, 3));

        System.out.println("10번 인덱스의 값: " + getElement(numbers, 10));

        System.out.println("이 메시지는 출력되지 않습니다.");
    }
}
```

### 프로그래밍 오류를 나타낼 때는 런타임 예외를 사용하자.
- 대부분은 전제조건을 만족하지 못했을 때 발생한다.
- 복구 가능하다고 믿는다면 검사 예외를, 그렇지 않다면 런타임 예외를 사용하자.
    - 확신하기 어렵다면 비검사 예외를 선택하자.

### Error 클래스의 하위 클래스를 만들지 말자
- 구현하는 `비검사 throwable`은 모두 `RuntimeException`의 하위 클래스여야 한다.
- `Error`는 상속하지 말아야 할 뿐 아니라, `throw` 문으로 직접 던지는 일도 없어야 한다.

### 예외의 메서드
- 주로 그 예외를 일으킨 상황에 관한 정보를 코드 형태로 전달하는데 쓰인다.
- 검사 예외는 복구할 수 있을때 발생하므로, **예외 상황에서 벗어나는데 필요한 정보를 알려주는 메서드**를 함께 제공해야 한다.
```java
public class InsufficientStockException extends Exception {
    private final String productId;
    private final int requestedQuantity;
    private final int availableQuantity;

    public InsufficientStockException(String productId, int requestedQuantity, int availableQuantity) {
        super("상품이 충분하지 않습니다. 상품 Id:" + productId);
        this.productId = productId;
        this.requestedQuantity = requestedQuantity;
        this.availableQuantity = availableQuantity;
    }

    public String getProductId() {
        return productId;
    }

    public int getRequestedQuantity() {
        return requestedQuantity;
    }

    public int getAvailableQuantity() {
        return availableQuantity;
    }

    public int getQuantityShortfall() {
        return requestedQuantity - availableQuantity;
    }

    public String getSuggestedAction() {
        if (availableQuantity > 0) {
            return availableQuantity + "만큼 주문하는 것을 고려해보세요.";
        } else {
            return "재고 부족입니다.";
        }
    }
}
```

## 핵심 정리
- **복구할 수 있는 상황이면 검사 예외**를, **프로그래밍 오류라면 비검사 예외**를 던지자.
    - 확실하지 않다면 비검사 예외를 던지자.
- 검사 예외도 아니고 비검사 예외도 아닌 throwable은 정의하지도 말자.
- 검사 예외라면 복구에 필요한 정보를 알려주는 메서드도 제공하자.

