# 59. 라이브러리를 익히고 사용하라
## 무작위 정수 생성하기
### Random을 사용한 메서드 생성
```java
// 무작위 수 생성은 쉽지 않다.  
public class RandomBug {  
    // 코드 59-1 흔하지만 문제가 심각한 코드! (351쪽)  
    static Random rnd = new Random();  
  
    static int random(int n) {  
        return Math.abs(rnd.nextInt()) % n;  
    }
}
```
#### 문제점
1. n이 그리 크지 않은 2의 제곱수라면 같은 수열이 반복된다.
    -  `rnd.nextInt()`는 -2^31에서 2^31-1 사이의 값을 반환하는데,  `Math.abs()`를 사용하면 양수 범위는 0에서 2^31-1이 된다.
    - n이 2의 제곱수(예: 2^k)라면, 모듈로 연산(`% n`)의 결과는 0에서 2^k-1 사이의 값만 나오게 되어, 가능한 모든 값들이 사용되지 않고 같은 수열이 반복될 수 있다.
2. n이 2의 제곱수가 아니라면 몇몇 숫자가 평균적으로 더 자주 반환된다.
    - 모듈로 연산의 특성상, 일부 숫자가 다른 숫자보다 더 자주 나올 수 있다.

### 중간값보다 낮은 쪽으로 쏠리는 무작위 정수
```java
// 무작위 수 생성은 쉽지 않다.  
public class RandomBug {  
    static Random rnd = new Random();  
  
    static int random(int n) {  
        return Math.abs(rnd.nextInt()) % n;  
    }
    // 무작위 수 1백만 개 생성 후, 중간 값보다 작은 수의 개수 출력 (351쪽)  
    public static void main(String[] args) {  
        int n = 2 * (Integer.MAX_VALUE / 3);  
        int low = 0;  
        for (int i = 0; i < 1000000; i++)  
            if (random(n) < n/2)  
                low++;  
        System.out.println(low);  
    }  
}
```
#### 문제점
- 무작위로 생성된 수 중에서 2/3 가량이 중간값보다 낮은 쪽으로 쏠린다.
    - 모듈러 연산 : `x % n`에서 x가 n보다 클 때, 결과는 항상 0에서 n-1 사이이지만,  x가 n의 배수에 가까울수록 결과는 작은 값에 치우치게 된다.
- `rnd.nextInt()`에 `Math.abs()`와 `모듈러 연산`을 통해 분포를 왜곡시킨다.


### Random 라이브러리의 nextInt() 직접 사용하기
```java
// 무작위 수 생성은 쉽지 않다.  
public class RandomSolved {  
    static Random rnd = new Random();  
  
    static int random(int n) {
	    return rnd.nextInt(n);
	}
	
    public static void main(String[] args) {  
        int n = 2 * (Integer.MAX_VALUE / 3);  
        System.out.println(random(n));  
    }  
}
```
- Random 라이브러리의 메서드는 알고리즘에 능통한 개발자와 전문가가 잘 동작함을 검증한 메서드이다.
    - 릴리스된 후 20여년 가까이 버그가 보고된 적이 없다.

### Random 대신 ThreadLocalRandom 을 사용하자
- java 7부터는 `ThreadLocalRandom`은 `Random`보다 더 고품질의 무작위 수를 생성하며 더 빠르다.


## 표준 라이브러리 이점
### 표준 라이브러리를 사용하면 그 코드를 작성한 전문가의 지식와 앞서 사용한 다른 프로그래머의 경험을 활용할 수 있다.
- Random 예시를 이유를 들어 설명 가능하다.

### 핵심적인 일에만 집중할 수 있다.

### 표준 라이브러리는 성능이 지속적으로 개선된다.
- 사용자가 많고 업계 표준 벤치마크를 사용해 성능을 확인한다.

### 기능이 점점 많아진다.
- 다음 릴리즈에 기능이 추가된다.

### 작성한 코드가 많은 사람에게 낯익은 코드가 된다.
- 다른 개발자가 더 일기 좋고, 유지보수하기 좋고, 재활용하기 쉬운 코드가 된다.

## 라이브러리를 익히자
### 많은 개발자가 직접 구현해 사용하는 이유
- 라이브러리에 그런 기능이 있는지 모르기 때문이다.
- 메이저 릴리즈마다 주목할 만한 수많은 기능이 라이브러리에 추가된다.

#### 지정한 URL의 내용 가져오기
```java
// 코드 59-2 transferTo 메서드를 이용해 URL의 내용 가져오기 - 자바 9부터 가능하다. (353쪽)  
public class Curl {  
    public static void main(String[] args) throws IOException {  
        try (InputStream in = new URL(args[0]).openStream()) {  
            in.transferTo(System.out);  
        }  
    }  
}
```

### 자바 프로그래머라면 익혀야할 라이브러리
- `java.lang`, `java.util`, `java.io` 와 그 하위 패키지들
    - 특히 `컬렉션 프레임워크`와 `스트림 라이브러리`, `java.util.concurrent`의 동시성 기능
- 다른 라이브러리들은 필요할 때마다 익히자.
- 자바 표준 라이브러리에서 원하는 기능을 찾지 못하면 고품질의 서드 파티 라이브러리를 찾아보자.
    - ex)구글의 구아바 라이브러리
    - 없다면 직접 구현하자

#### 자주 사용되는 메서드
### java.lang 패키지

| 클래스 | 메서드 | 설명 |
|--------|--------|------|
| String | `length()` | 문자열의 길이를 반환 |
| | `charAt(int index)` | 지정된 인덱스의 문자를 반환 |
| | `substring(int beginIndex, int endIndex)` | 지정된 범위의 부분 문자열을 반환 |
| | `equals(Object obj)` | 문자열 비교 |
| | `toLowerCase()` / `toUpperCase()` | 소문자/대문자로 변환 |
| Integer | `parseInt(String s)` | 문자열을 정수로 변환 |
| | `valueOf(int i)` | int를 Integer 객체로 변환 |
| Math | `max(int a, int b)` / `min(int a, int b)` | 최대값/최소값 반환 |
| | `abs(int a)` | 절대값 반환 |
| | `random()` | 0.0 이상 1.0 미만의 난수 반환 |

### java.util 패키지

| 클래스/인터페이스 | 메서드 | 설명 |
|-------------------|--------|------|
| List | `add(E e)` | 요소 추가 |
| | `get(int index)` | 지정된 인덱스의 요소 반환 |
| | `remove(int index)` | 지정된 인덱스의 요소 제거 |
| | `size()` | 리스트의 크기 반환 |
| Map | `put(K key, V value)` | 키-값 쌍 추가 |
| | `get(Object key)` | 지정된 키에 대한 값 반환 |
| | `remove(Object key)` | 지정된 키에 대한 매핑 제거 |
| | `containsKey(Object key)` | 지정된 키가 존재하는지 확인 |
| Set | `add(E e)` | 요소 추가 |
| | `remove(Object o)` | 요소 제거 |
| | `contains(Object o)` | 요소 포함 여부 확인 |
| Collections | `sort(List<T> list)` | 리스트 정렬 |
| | `reverse(List<?> list)` | 리스트 역순 정렬 |
| | `shuffle(List<?> list)` | 리스트 요소를 무작위로 섞음 |
| Arrays | `sort(int[] a)` | 배열 정렬 |
| | `binarySearch(int[] a, int key)` | 이진 검색 수행 |

### java.io 패키지

| 클래스 | 메서드 | 설명 |
|--------|--------|------|
| File | `exists()` | 파일 존재 여부 확인 |
| | `createNewFile()` | 새 파일 생성 |
| | `delete()` | 파일 삭제 |
| FileInputStream | `read()` | 바이트 단위로 읽기 |
| | `close()` | 스트림 닫기 |
| FileOutputStream | `write(int b)` | 바이트 단위로 쓰기 |
| | `close()` | 스트림 닫기 |
| BufferedReader | `readLine()` | 한 줄씩 읽기 |
| BufferedWriter | `write(String s)` | 문자열 쓰기 |
| | `newLine()` | 새 줄 추가 |

### java.util.concurrent 패키지

| 클래스/인터페이스 | 메서드 | 설명 |
|-------------------|--------|------|
| ExecutorService | `submit(Callable<T> task)` | 작업 제출 |
| | `shutdown()` | 실행자 종료 |
| Future | `get()` | 결과 가져오기 |
| | `isDone()` | 작업 완료 여부 확인 |
| CountDownLatch | `await()` | 래치가 0이 될 때까지 대기 |
| | `countDown()` | 래치 카운트 감소 |
| ConcurrentHashMap | `putIfAbsent(K key, V value)` | 키가 없을 때만 값 추가 |
| | `computeIfAbsent(K key, Function<? super K, ? extends V> mappingFunction)` | 키가 없을 때 함수 적용 후 값 추가 |


# 결론
- 바퀴를 다시 발명하지 말자.
    - 아주 특별한 나만의 기능이 아니라면 누군가 이미 라이브러리 형태로 구현해놓앗을 가능성이 크다.
- **라이브러리가 있으면 쓰면 된다.**
    - 있는지 모르겠다면 **찾아보라.**
- 라이브러리 코드는 개발자 각자가 작성한 것보다 주목을 많이 받으므로 코드 품질도 높아진다.\
    - 코드에도 규모의 경제가 적용된다.
    - 직접 작성한 것보다 품질이 좋고 개선될 가능성이 크다.

