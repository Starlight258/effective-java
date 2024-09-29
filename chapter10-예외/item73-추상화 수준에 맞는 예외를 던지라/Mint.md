# 73. 추상화 수준에 맞는 예외를 던지라
### 저수준 예외
- 메서드가 저수준 예외를 처리하지 앟고 바깥으로 전파해버리는 경우가 있다.
- 이는 프로그래머를 당황시킬 뿐 아니라, 내부 구현 방식을 드러내어 윗 레벨 API를 오염시킨다.

### 예외 번역
- 상위 계층에서는 저수준 예외를 잡아 자신의 추상화 수준에 맞는 예외로 바꿔 던져야한다.
```java
try {

} catch (LowLevelException e){
	throw new HigherLevelException(..); // 더 일반적인 예외로 번역
}
```

- 예외를 번역할 때, 저수준 예외가 디버깅에 도움이 된다면 예외 연쇄를 사용하는게 좋다.
    - **예외 연쇄** : 문제의 근본 원인인 저수준 예외를 고수준 예외에 실어 보내는 방식
    - 별도의 접근자 메서드(`Throwable의 getCause`) 메서드를 통해 필요하면 언제든 저수준 예외를 꺼내볼 수 있다.
```java
try {

} catch (LowerLevelException cause){
	throw new HigherLevelException(cause); 
}
```
- 고수준 예외의 생성자는 상위 클래스에게 원인을 건네주어, 최종적으로 `Throwable` 생성자까지 건네지게 한다.
```java
class HigherLevelException extedns Exception {
	HigherLevelException(Throwable cause){
		super(cause);
	}
}
```

- 예시 코드
```java
public class LowerLevelComponent {
    public void doSomething() throws SQLException {
        throw new SQLException("Database connection failed");
    }
}

public class HigherLevelComponent {
    private LowerLevelComponent lowerLevel = new LowerLevelComponent();

    public void processData() throws ServiceException {
        try {
            lowerLevel.doSomething();
        } catch (SQLException e) {
            // 예외 번역
            throw new ServiceException("데이터 처리 중 오류 발생", e); // 예외 연쇄
        }
    }
}

// 사용자 정의 예외
public class ServiceException extends Exception {
    public ServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

### 예외 번역을 남용해서는 안된다
- 가능하다면 저수준 메서드가 반드시 성공하도록하여 아래 계층에서는 예외가 발생하지 않도록 하는 것이 최선이다.
- 상위 계층 메서드의 매개변수 값을 **아래 계층 메서드로 건네기 전에 미리 검사**하는 방법으로 목적을 달성할 수 있다.
    - 많은 예외 상황을 미리 처리하고, 그 외에 발생할 수 있는 예외에 대해서만 예외 번역을 사용하자.
```java
public class FileProcessor {

    // 저수준 메서드
    private List<String> readFile(String filePath) throws IOException {
        return Files.readAllLines(Paths.get(filePath));
    }

    // 상위 계층 메서드
    public List<String> processFile(String filePath) throws FileProcessingException {
        // 매개변수 유효성 검사
        if (filePath == null || filePath.isEmpty()) {
            throw new IllegalArgumentException("파일 경로가 유효하지 않습니다.");
        }

        File file = new File(filePath);
        
        // 파일 존재 여부 확인
        if (!file.exists()) {
            throw new FileProcessingException("파일이 존재하지 않습니다: " + filePath);
        }

        // 파일 읽기 권한 확인
        if (!file.canRead()) {
            throw new FileProcessingException("파일을 읽을 수 있는 권한이 없습니다: " + filePath);
        }

        try {
            return readFile(filePath);
        } catch (IOException e) {
            // 여전히 발생할 수 있는 예외에 대해서만 예외 번역 사용
            throw new FileProcessingException(e);
        }
    }

    public static void main(String[] args) {
        FileProcessor processor = new FileProcessor();
        String filePath = "example.txt";

        try {
            List<String> content = processor.processFile(filePath);
            System.out.println("파일 내용: " + content);
        } catch (IllegalArgumentException e) {
            System.out.println("입력 오류: " + e.getMessage());
        } catch (FileProcessingException e) {
            System.out.println("파일 처리 오류: " + e.getMessage());
        }
    }
}
```

#### 차선책
- 상위 계층에서 예외를 조용히 처리하여 문제를 호출자까지 전파하지 않는 방법이 있다.
- `로깅 기능`을 활용하여 기록해두면 좋다.
- 클라이언트 코드와 사용자에게 문제를 전파하지 않으면서도 프로그래머가 로그를 분석해 추가 조치를 취할 수 있게 해준다.
```java
public class FileProcessor {
    private static final Logger logger = Logger.getLogger(FileProcessor.class.getName());

    private List<String> readFile(String filePath) throws IOException {
        return Files.readAllLines(Paths.get(filePath));
    }

    // 상위 계층 메서드 
    public List<String> processFile(String filePath) {
        try {
            return readFile(filePath);
        } catch (IOException e) {
            // 예외를 로깅하고 기본값 반환
            logger.log(Level.SEVERE, "파일 처리 중 오류 발생: " + filePath, e);
            return Collections.emptyList(); 
        }
    }

    public static void main(String[] args) {
        FileProcessor processor = new FileProcessor();
        String filePath = "example.txt";

        String summary = processor.summarizeFileContent(filePath);
        System.out.println(summary);
    }
}
```

## 결론
- 아래 계층의 예외를 예방하거나 스스로 처리할 수 없고, 그 예외를 상위 계층에 그대로 노출하기 곤란하다면 `예외 번역`을 사용하라.
- `예외 연쇄`를 이용하면 상위 계층에는 맥락에 어울리는 고수준 예외를 던지면서 **근본 원인도 함께 알려주어** 오류를 분석하기에 좋다.
