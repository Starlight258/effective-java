가변인수 : 

- 명시한 타입의 인수를 임의의 개수만큼 받을 때 키워드 `…` 을 사용하여 표현
- 가변인수 개수 만큼의 길이를 가진 배열이 만들어지고 이를 이용해 메서드 구현
- 가변인수 길이는 0 이상
- 메서드 선언에서 가변인수는 가변인수가 아닌 파라미터 뒤에 작성

예시코드

```java
static int sum(int... args) {
        int sum = 0;
        for (int arg : args)
            sum += arg;
        return sum;
    }
```

# 요약

---

## 가변인수 외에 매개변수

인수가 1개 이상이어야 하는 가변인수 메서드

```java
// 원래코드
static int min(int... args) {
    if (args.length == 0)
       throw new IllegalArgumentException("인수가 1개 이상 필요합니다.");
    int min = args[0];
   for (int i = 1; i < args.length; i++)
        if (args[i] < min)
           min = args[i];
    return min;
}

//개선코드
static int min(int firstArg, int... remainingArgs) {
        int min = firstArg;
        for (int arg : remainingArgs)
            if (arg < min)
                min = arg;
        return min;
    }
```

- 인수가 0개일 때 런타임 실패하는 코드
- args 유효성 검사를 명시적으로 수행해야 하고, for-each 구문을 쓰고싶으면 min의 초깃값도 특별하게 정해줘야 해서 코드 지저분함
- 가변인수가 아닌 매개변수를 받도록 하여 이를 개선
- 가변인수 덕의 `printf` 와 핵심 리플렉션 기능에 많은 도움을 주었다 

## 가변인수와 성능

- 가변인수 메서드는 호출 시 새로운 배열을 할당하고 초기화한다
- 이 비용을 감당할 수 없으나, 유연성이 필요할 때 다중정의를 사용할 수 있음
- 예시 : 메서드의 95% 가 인수 3개이하로 호출

```java
public void foo() { }
public void foo(int a1) { }
public void foo(int a1, int a2) { }
public void foo(int a1, int a2, int a3) { }
public void foo(int a1, int a2, int a3, int... rest) { }
```