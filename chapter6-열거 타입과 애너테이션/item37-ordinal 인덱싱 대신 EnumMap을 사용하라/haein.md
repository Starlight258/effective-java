
# 요약
---

## 정원에 있는 식물들을 생애주기별로 매핑하고 싶다고 하자

```java
class Plant {
    enum LifeCycle { ANNUAL, PERENNIAL, BIENNIAL }

    final String name;
    final LifeCycle lifeCycle;

    Plant(String name, LifeCycle lifeCycle) {
        this.name = name;
        this.lifeCycle = lifeCycle;
    }

    @Override public String toString() {
        return name;
    }

    public static void main(String[] args) {
        Plant[] garden = {
            new Plant("바질",    LifeCycle.ANNUAL),
            new Plant("캐러웨이", LifeCycle.BIENNIAL),
            new Plant("딜",      LifeCycle.ANNUAL),
            new Plant("라벤더",   LifeCycle.PERENNIAL),
            new Plant("파슬리",   LifeCycle.BIENNIAL),
            new Plant("로즈마리", LifeCycle.PERENNIAL)
        };

    ```

    ```java

        // 코드 37-1 ordinal()을 배열 인덱스로 사용 - 따라 하지 말 것! (226쪽)
        Set<Plant>[] plantsByLifeCycleArr =
                (Set<Plant>[]) new Set[Plant.LifeCycle.values().length];
        for (int i = 0; i < plantsByLifeCycleArr.length; i++)
            plantsByLifeCycleArr[i] = new HashSet<>();
        for (Plant p : garden)
            plantsByLifeCycleArr[p.lifeCycle.ordinal()].add(p);
        // 결과 출력
        for (int i = 0; i < plantsByLifeCycleArr.length; i++) {
            System.out.printf("%s: %s%n",
                    Plant.LifeCycle.values()[i], plantsByLifeCycleArr[i]);
        }
```
- 배열은 제네릭과 호환되지 않으므로 비검사 경고가 발생한다.
- 배열은 각 인덱스의 의미를 모르므로 개발자가 레이블링해야 한다
- 정확한 정숫값을 사용하고 있는 지를 보증해야 한다, 타입 안전하지 않다 
-  `ArrayIndexOutOfBoundsException` 발생 가능
- 여기서 배열이 열거 타입 상수를 값으로 매핑하는 역할이라는 것에 주목하여 수정해보자 



```java

        // 코드 37-2 EnumMap을 사용해 데이터와 열거 타입을 매핑한다. (227쪽)
        Map<Plant.LifeCycle, Set<Plant>> plantsByLifeCycle =
                new EnumMap<>(Plant.LifeCycle.class);
        for (Plant.LifeCycle lc : Plant.LifeCycle.values())
            plantsByLifeCycle.put(lc, new HashSet<>());
        for (Plant p : garden)
            plantsByLifeCycle.get(p.lifeCycle).add(p);
        System.out.println(plantsByLifeCycle);
```
-  `EnumMap` 은 열거 타입을 키로 설계한 매우 빠른 Map 구현체이다
- EnumMap은 내부적으로 배열을 사용한다 
- 내부 구현 방식을 안으로 숨겨 Map의 타입 안전성과 배열의 성능을 모두 얻어내었다 


```java
        // 코드 37-3 스트림을 사용한 코드 1 - EnumMap을 사용하지 않는다! (228쪽)
        System.out.println(Arrays.stream(garden)
                .collect(groupingBy(p -> p.lifeCycle)));
```
- `EnumMap` 대신 `stream` 을 사용하여 코드를 간결하게 할 수 있다
- `EnumMap` 을 사용하여 얻은 공간과 성능 이점이 사라진다는 단점이 있다 


```java
        // 코드 37-4 스트림을 사용한 코드 2 - EnumMap을 이용해 데이터와 열거 타입을 매핑했다. (228쪽)
        System.out.println(Arrays.stream(garden)
                .collect(groupingBy(p -> p.lifeCycle,
                        () -> new EnumMap<>(LifeCycle.class), toSet())));
    }
```
- 최적화를 위해 원하는 맵 구현체를 명시해 호출할 수 있다
- Stream 버전은 해당 생애주기에 속하는 식물이 있을 때만 Map을 만든다 

## 두 열거 타입을 매핑

```java
public enum Phase {
	SOLID, LIQUID, GAS;

	public enum Transition {
		MELT, FREEZE, BOIL, CONDENSE, SUBLIME, DEPOSIT;

		private static final Transition[][] TRANSITIONS = {
				{null, MELT, SUBLIME},
				{FREEZE, null, BOIL},
				{DEPOSIT, CONDENSE, null},
		}
		private static Transition from(Phase from, Phase to){
			return TRANSITIONS[from.ordinal()][to.ordinal()];
		}
	}
}
```
- ordinal 과 배열 인덱스의 관계를 몰라 유지보수가 어렵다
- `EnumMap` 을 사용하여 코드를 간결하게 할 수 있다


```java
public enum Phase {
	SOLID, LIQUID, GAS;

	public enum Transition {
        MELT(SOLID, LIQUID), FREEZE(LIQUID, SOLID),
        BOIL(LIQUID, GAS), CONDENSE(GAS, LIQUID),
        SUBLIME(SOLID, GAS), DEPOSIT(GAS, SOLID);


		private final Phase from;
		private final Phase to;
		
		Transition(Phase from, Phase to) {
			this.from = from;
			this.to = to;
		}

		private static final Map<Phase, Map<Phase, Transition>> m = 
Stream.of(values()).collect(groupingBy(t->t.from, () ->new EnumMap<>(Phase.class),
		toMap(t -> t.to, t->t, (x, y) -> y, () -> new EnumMap<>(Phase.class))));

		private static Transition from(Phase from, Phase to) {
			return m.get(from).get(to);
		}
								
	}
}
```
- `Map<Phase, Map<Phase, Transition>` 은 '이전 상태에서 이후 상태에서 전이로의 Map 에 대응시키는 Map' 이다
- `groupingBy(t->t.from, () ->new EnumMap<>(Phase.class)`는 이전 상태를 키로 사용하는 Map 을 생성한다
- `toMap(t -> t.to, t->t, (x, y) -> y, () -> new EnumMap<>(Phase.class))`는 이후 상태를 전이에 대응시키는 `EnumMap` 을 
생성한다
- 두 번째  (x, y) -> y는 선언만 하고 실제로는 쓰이지 않는다(시그니쳐 상 필요함, 중복 키 처리)



## 새로운 상태를 추가하는 경우 

```java
public enum Phase {
    SOLID, LIQUID, GAS,
    // 신규 PLASMA 추가
    PLASMA;

    public enum Transition {
        MELT(SOLID, LIQUID), FREEZE(LIQUID, SOLID),
        BOIL(LIQUID, GAS), CONDENSE(GAS, LIQUID),
        SUBLIME(SOLID, GAS), DEPOSIT(GAS, SOLID),
        // IONIZE, DEIONIZE 추가
        IONIZE(GAS, PLASMA), DEIONIZE(PLASMA, GAS);
```