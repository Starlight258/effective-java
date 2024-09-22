## ✍️ 개념의 배경

try-finally 구문

—> 도중에 무슨 일이 일어나든 반드시 finally 절을 실행하라!

(시스템의 전원을 close 해야할 때  사용)

# 요약

---

- InputStream, OutputStram 과 같은 자원들은 close 메서드를 선언하여 직접 닫아줘야 한다.
- 이를 위해 try-finally 를 사용한다.

전통적인 try-finally 구문은 다음과 같다.

(자원이 하나인 경우)

```java
 	static String firstLineOfFile(String path) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(path));
        try {
            return br.readLine();
        } finally {
            br.close();
        }
    
```

(자원이 두 개 이상인 경우)

```java
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
```

여기서 발생하는 몇 가지 문제점들이 있다.

- 관리해야하는 자원이 여러개라면 가독성이 좋지 않다. (예시 코드 2)
- 디버깅 난이도가 높다. 예를 들어 readline() 메소드와 close() 메소드에서 동시에 예외가 발생한다고 하더라도,
close() 메소드에 대한 기록만 남게 된다. (예시 코드 1)

try-with-resources 구문을 활용하면 이러한 단점을 모두 극복할 수 있다. (저자는 이것이 최선책이며, 예외상황은 없다고 강조함)

- 가독성이 좋아진다.
- 여러 예외에 대한 기록을 누적하여 표시해준다. (추적 내용 supressed 라는 꼬리표를 달고 출력된다.)
- 코드의 안정성을 확보해준다.

이 구문을 사용하려면 해당 자원은 AutoClosable 인터페이스를 구현해야 한다.

이를 활용하여 위의 예제 코드를 재작성하면 다음과 같다.

```java
static String firstLineOfFile(String path) throws IOException {
        try (BufferedReader br = new BufferedReader(
                new FileReader(path))) {
            return br.readLine();
        }
    }
```

- try 내부에 자원 객체를 전달
- 자원 사용 코드 작성
- 자동으로 자원 반납(close)

```java
static void copy(String src, String dst) throws IOException {
        try (InputStream   in = new FileInputStream(src);
             OutputStream out = new FileOutputStream(dst)) {
            byte[] buf = new byte[BUFFER_SIZE];
            int n;
            while ((n = in.read(buf)) >= 0)
                out.write(buf, 0, n);
        }
    }
```

- 복수의 자원 객체도 가독성 좋게 전달 가능

## 개념 관련 경험

## 이해되지 않았던 부분

## ⭐️ **번외: 추가 조각 지식**

try-with-resources: java7부터 나왔다고 합니다.

### 객체 변수만 넣어줘도 close 자동 호출 가능

![Screenshot 2023-11-21 at 12.41.44 AM.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/71ba72f2-10bd-45e7-a578-06288fc34d9d/4463d6c9-bcdf-43c1-a678-281ff6eef723/Screenshot_2023-11-21_at_12.41.44_AM.png)