# 71. 필요 없는 검사 예외 사용은 피하라
- 검사 예외는 발생한 문제를 프로그래머가 처리하여 안전성을 높이게끔 해준다.
- 검사 예외를 던지는 메서드라면, 이를 호출하는 코드에서는 catch 블록을 두어 그 예외를 붙잡아 처리하거나, 더 바깥으로 던져 문제를 전파해야만 한다.
    - API 사용자에게 부담을 준다.
- 검사 예외를 던지는 메서드는 스트림 안에서 직접 사용할 수 없다.

## 검사 예외를 회피하는 방법
### 1.적절한 결과 타입을 담은 옵셔널을 반환한다.
- 단점이라면 예외가 발생한 이유를 알려주는 부가 정보를 담을 수 없다는 것이다.
- 예외를 사용하면 구체적인 예외 타입과 그 타입이 제공하는 메서드들을 활용해 부가 정보를 제공할 수 있다.
- 코드
    - 기존 코드 (try-catch)
```java
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

public class FileReader {
    public static List<String> readFile(String fileName) throws IOException {
        return Files.readAllLines(Paths.get(fileName));
    }

    public static void main(String[] args) {
        try {
            List<String> lines = readFile("example.txt");
            System.out.println("파일 내용: " + lines);
        } catch (IOException e) {
            System.out.println("파일을 읽는 중 오류 발생: " + e.getMessage());
        }
    }
}
```

- 수정 코드 : 호출하는 쪽에서는 try-catch 블록 없이 `Optional`의 메서드를 사용하여 결과를 처리한다.
```java
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

public class FileReader {
    public static Optional<List<String>> readFile(String fileName) {
        try {
            List<String> lines = Files.readAllLines(Paths.get(fileName));
            return Optional.of(lines);
        } catch (IOException e) {
            System.err.println("파일 읽기 실패: " + e.getMessage());
            return Optional.empty();
        }
    }

    public static void main(String[] args) {
        Optional<List<String>> result = readFile("example.txt");
        if (result.isPresent()) {
            System.out.println("파일 내용: " + result.get());
        } else {
            System.out.println("파일을 읽을 수 없습니다.");
        }
    }
}
```

### 2. 검사 예외를 던지는 메서드를 2개로 쪼개 비검사 예외로 바꾼다.
- 첫번째 메서드는 예외가 던져질지 여부를 boolean 값으로 반환한다.
    - 외부 동기화 없이 여러 스레드가 동시에 접근할 수 있거나, 외부 요인에 의해 상태가 변할 수 있다면 리팩토링이 적절하지 않다.
    - actionPermitted와 action 사이에 객체의 상태가 변할 수 있기 때문이다.
```java
if (obj.actionPermitted(args)){
	obj.action(args);
} else {
	// 예외 상황
}
```

# 결론
- 검사 예외는 프로그램의 안전성을 높여주지만, 남용하면 쓰기 고통스러운 API를 낳는다.
    - API 호출자가 예외상황에서 **복구할 방법이 없다면 `비검사 예외`를 던지자.**
- **복구가 가능**하고 호출자가 그 처리를 해주길 바란다면, `옵셔널`을 반환해도 될지 고민하자.
    - **`옵셔널`만으로는 상황을 처리하기에 충분한 정보를 제공할 수 없을 때만 `검사 예외`를 던지자.**
