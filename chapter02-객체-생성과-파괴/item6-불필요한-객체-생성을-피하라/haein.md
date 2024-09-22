## ✍️ 개념의 배경

## 요약

---

```java
// 매번 String 객체 생성
String str1 = new String("Hello");

// 하나의 String 인스턴스를 재활용
String str2 = "Hello";
```

- 문자열 객체의 리터럴을 사용해 같은 객체임을 보장

```java
Boolean b = new Boolean("true");
Boolean b = Beelean.valueOf("true");
```

- 적절한 정적 팩터리를 사용해 불변 객체를 새로 생성하지 말자

```java
// 개선전
static boolean isRomanNumeral(String s) {
    return s.matches("정규표현식");
}

// 개선후
private static final Pattern ROMAN = Pattern.compile("정규표현식");
static boolean isRomanNumeral(String s) {
    return ROMAN.matcher(s).matches();
}
```

- 정규표현식은 생성 비용이 매우 비싸므로 캐싱한다

```java
private static long sum() {
    Long sum = 0L;
    for( long i = 0; i <= Integer.MAX_VALUE; i++ )
        sum += i;
    return sum;
}
```

- 오토박싱이 의도치 않은 성능 저하를 야기할 수 있다 (sum 이 2^31 번 생성되는 상황)

**거꾸로 단순히 객체 생성을 피하고자 본인만의 객체 풀을 만들지 말자**

- 최신 GC는 가벼운 객체는 금방 최적화할 수 있다

## 개념 관련 경험

## 이해되지 않았던 부분

## ⭐️ **번외: 추가 조각 지식**

## 질문