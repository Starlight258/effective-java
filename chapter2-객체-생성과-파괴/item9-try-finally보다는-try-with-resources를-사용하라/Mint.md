- 자원 닫기는 클라이언트가 놓치기 쉬워서 예측할 수 없는 성능 문제로 이어질 수 있다.
- 상당수가 안전망으로 finalizer를 사용하지만 finalizer는 그리 믿을만 하지 않다.

### try-finally
- 전통적으로 쓰이는 방법이다.
#### 코드가 지저분하다.
```java
package effectivejava.chapter2.item9.tryfinally;  
  
import java.io.*;  
  
public class Copy {  
    private static final int BUFFER_SIZE = 8 * 1024;  
  
    // 코드 9-2 자원이 둘 이상이면 try-finally 방식은 너무 지저분하다! (47쪽)  
    static void copy(String src, String dst) throws IOException {  
        InputStream in = new FileInputStream(src);  
        try {  
            OutputStream out = new FileOutputStream(dst);  
            try {  
                byte[] buf = new byte[BUFFER_SIZE];  
                int n;  
                while ((n = in.read(buf)) >= 0)  
                    out.write(buf, 0, n);  
            } finally {  
                out.close();  
            }  
        } finally {  
            in.close();  
        }  
    }  
  
    public static void main(String[] args) throws IOException {  
        String src = args[0];  
        String dst = args[1];  
        copy(src, dst);  
    }  
}
```

#### 예외가 숨겨져 디버깅이 어렵다.
```java
package effectivejava.chapter2.item9.tryfinally;  
  
import java.io.BufferedReader;  
import java.io.FileReader;  
import java.io.IOException;  
  
public class TopLine {  
    // 코드 9-1 try-finally - 더 이상 자원을 회수하는 최선의 방책이 아니다! (47쪽)  
    static String firstLineOfFile(String path) throws IOException {  
        BufferedReader br = new BufferedReader(new FileReader(path));  
        try {  
            return br.readLine();  
        } finally {  
            br.close();  
        }  
    }  
  
    public static void main(String[] args) throws IOException {  
        String path = args[0];  
        System.out.println(firstLineOfFile(path));  
    }  
}
```
- readLine()과 close()에서 예외 발생시 close() 예외만 표시되어 디버깅이 어렵다.

### try-with-resources 🌟
- 이 구조를 사용하려면 AutoClosable 인터페이스를 구현해야한다.

#### 단순하고 짧다.
```java
package effectivejava.chapter2.item9.trywithresources;  
  
import java.io.*;  
  
public class Copy {  
    private static final int BUFFER_SIZE = 8 * 1024;  
  
    // 코드 9-4 복수의 자원을 처리하는 try-with-resources - 짧고 매혹적이다! (49쪽)  
    static void copy(String src, String dst) throws IOException {  
        try (InputStream   in = new FileInputStream(src);  
             OutputStream out = new FileOutputStream(dst)) {  
            byte[] buf = new byte[BUFFER_SIZE];  
            int n;  
            while ((n = in.read(buf)) >= 0)  
                out.write(buf, 0, n);  
        }  
    }  
  
    public static void main(String[] args) throws IOException {  
        String src = args[0];  
        String dst = args[1];  
        copy(src, dst);  
    }  
}
```

#### 디버깅하기 편하다.
- 숨겨진 예외도 스택 추적 내역에 숨겨졌다는 꼬리표를 달고 출력되며 Throwable의 getSuppressed 메서드를 이용해 예외를 가져올 수 있다.
- catch로 다수의 예외를 처리할 수 있다.
```java
package effectivejava.chapter2.item9.trywithresources;  
  
import java.io.BufferedReader;  
import java.io.FileReader;  
import java.io.IOException;  
  
public class TopLineWithDefault {  
    // 코드 9-5 try-with-resources를 catch 절과 함께 쓰는 모습 (49쪽)  
    static String firstLineOfFile(String path, String defaultVal) {  
        try (BufferedReader br = new BufferedReader(  
                new FileReader(path))) {  
            return br.readLine();  
        } catch (IOException e) {  
            return defaultVal;  
        }  
    }  
  
    public static void main(String[] args) throws IOException {  
        String path = args[0];  
        System.out.println(firstLineOfFile(path, "Toppy McTopFace"));  
    }  
}
```

### 결론
- 꼭 회수해야하는 지원을 다룰 때는 try-finally 말고 try-with-resources를 사용하자.
- 코드는 더 짧고 분명해지고, 만들어지는 예외 정보도 훨씬 유용하다.
