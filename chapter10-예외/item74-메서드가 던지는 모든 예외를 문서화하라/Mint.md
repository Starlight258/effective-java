# 74. 메서드가 던지는 모든 예외를 문서화하라
- 각 메서드가 던지는 예외 하나하나를 문서화하는데 충분한 시간을 쏟아야 한다.

### 검사 예외는 항상 따로따로 선언하고, 각 예외가 발생하는 상황을 자바독의 `@throws` 태그를 사용하여 정확히 문서화하자
- 공통 상위 클래스 하나로 뭉뚱그려서 선언해서는 안된다.
    - 각 예외에 대처할 수 있는 힌트를 주지 못한다.
    - 같은 맥락에서 발생할 여지가 있는 다른 예외들까지 삼켜버릴 수 있다.

### 비검사 예외도 정성껏 문서화하는 것이 좋다
- 잘 정비된 비검사 예외 문서는 사실상 그 메서드를 성공적으로 수행하기 위한 전제조건이 된다.
- `public 메서드`라면 필요한 전제조건을 문서화해야한다.
- 특히 인터페이스 메서드는 조건이 인터페이스의 일반 규약에 속하게 되어 모든 구현체가 일관되게 동작하도록 해준다.

### 메서드가 던질 수 있는 예외를 @throws 태그로 문서화하되, 비검사 예외는 메서드 선언의 throws 목록에 넣지 말자
- 검사 예외와 비검사 예외는 사용자가 해야할 일이 달라지므로 확실히 구분하는 것이 좋다.
- javadoc은 `메서드 선언의 throws` 절과 `@throws`에 등장한 예외와 `@throws`에만 등장한 예외를 시각적으로 구분해준다.
    - 검사 예외 : `메서드 선언의 throws` 절과 `@throws`에 명시
    - 비검사 예외 :  `@throws`에 명시
- 한 클래스에 정의된 많은 메서드가 같은 이유로 같은 예외를 던진다면 그 예외를 각 메서드가 아닌 클래스 설명에 추가해도 된다.
    - ex) `NullPointerException`

#### 예시 코드
```java
import java.io.IOException;
import java.sql.SQLException;

/**
 * 사용자 데이터를 관리하는 클래스
 * 
 * <p>이 클래스의 모든 메서드는 null 파라미터를 받으면 NullPointerException을 던질 수 있습니다.</p>
 */
public class UserManager {

    /**
     * 사용자를 데이터베이스에 추가합니다.
     *
     * @param username 추가할 사용자의 이름
     * @param email 추가할 사용자의 이메일
     * @throws SQLException 데이터베이스 연결에 문제가 있거나 쿼리 실행 중 오류가 발생한 경우
     * @throws IllegalArgumentException 이메일 형식이 올바르지 않은 경우
     */
    public void addUser(String username, String email) throws SQLException {
        if (!isValidEmail(email)) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }

    /**
     * 사용자 정보를 파일로 내보냅니다.
     *
     * @param userId 내보낼 사용자의 ID
     * @param filePath 파일을 저장할 경로
     * @throws IOException 파일 쓰기 중 오류가 발생한 경우
     * @throws SQLException 데이터베이스에서 사용자 정보를 가져오는 중 오류가 발생한 경우
     * @throws UserNotFoundException 지정된 ID의 사용자가 존재하지 않는 경우
     */
    public void exportUserToFile(int userId, String filePath) throws IOException, SQLException, UserNotFoundException {
        // 사용자 정보를 파일로 내보내는 로직
    }

    /**
     * 이메일 주소의 유효성을 검사합니다.
     *
     * @param email 검사할 이메일 주소
     * @return 이메일이 유효하면 true, 그렇지 않으면 false
     */
    private boolean isValidEmail(String email) {
        // 이메일 유효성 검사 로직
        return email != null && email.contains("@");
    }
}

/**
 * 사용자를 찾을 수 없을 때 발생하는 예외입니다.
 */
class UserNotFoundException extends Exception {
    public UserNotFoundException(String message) {
        super(message);
    }
}
```

## 결론
- **메서드가 던질 가능성이 있는 모든 예외를 문서화하라.**
    - 검사 예외든, 비검사 예외든, 추상 메서드든 구체 메서드든 모두 마찬가지다.
    - 문서화에는 자바독의 `@throws` 태그를 사용하면 된다.
- **검사 예외**만 메서드 선언의 `throws` 문에 일일이 선언하고, **비검사 예외**는 메서드 선언에는 기입하지 말자.
- 발생 가능한 예외를 문서로 남기지 않으면 다른 사람이 그 클래스나 인터페이스를 효과적으로 사용하기 어렵거나 심지어 불가능할 수도 있다.

