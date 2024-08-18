# 37. ordinal 인덱싱 대신 EnumMap을 사용하라
# Enum 배열, Map
- 식물을 생애주기별로 3개의 집합을 만들어 식물을 해당 집합에 넣자.
    - 2가지 방법이 있다.
```java
// 식물을 아주 단순하게 표현한 클래스 (226쪽)  
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
}
```

## 1. ordinal 인덱싱 - 비추
- 집합을 배열에 넣고 생애주기의`ordinal()` 을 배열의 인덱스로 사용하는 방법이다.
```java
// EnumMap을 사용해 열거 타입에 데이터를 연관시키기 (226-228쪽)  
public static void main(String[] args) {  
	Plant[] garden = {  
			new Plant("바질",    LifeCycle.ANNUAL),  
			new Plant("캐러웨이", LifeCycle.BIENNIAL),  
			new Plant("딜",      LifeCycle.ANNUAL),  
			new Plant("라벤더",   LifeCycle.PERENNIAL),  
			new Plant("파슬리",   LifeCycle.BIENNIAL),  
			new Plant("로즈마리", LifeCycle.PERENNIAL)  
	};  

	// 코드 37-1 ordinal()을 배열 인덱스로 사용 - 따라 하지 말 것! (226쪽)  
	Set<Plant>[] plantsByLifeCycleArr =  
			(Set<Plant>[]) new Set[Plant.LifeCycle.values().length];  
			
	for (int i = 0; i < plantsByLifeCycleArr.length; i++)  
		plantsByLifeCycleArr[i] = new HashSet<>();  
		
	// ordinal() 사용하여 저장
	for (Plant p : garden)  
		plantsByLifeCycleArr[p.lifeCycle.ordinal()].add(p);  
		
	// 결과 출력  
	for (int i = 0; i < plantsByLifeCycleArr.length; i++) {  
		System.out.printf("%s: %s%n",  
				Plant.LifeCycle.values()[i], plantsByLifeCycleArr[i]);  
	}  
}  
```
- 배열은 제네릭과 호환되지 않으므로 **비검사 형변환을 수행**해야 한다.
    - 깔끔하게 형변환되지 않는다.
    - 타입 안전하지 않다.
- 배열은 각 인덱스의 의미를 모르므로 **출력 결과에 직접 레이블을 달아야 한다.**
- **배열의 인덱스가 정확한 정수값(배열 내의 인덱스)을 사용한다는 것을 보증**하는 코드를 구현해야 한다.
    - 정수는 열거 타입과 달리 **타입 안전하지 않으므로 잘못된 인덱스값이 사용될 수 있다.**

##  2. `EnumMap` 을 사용하자 - 추천 🌟
```java
// EnumMap을 사용해 열거 타입에 데이터를 연관시키기 (226-228쪽)  
public static void main(String[] args) {  
	Plant[] garden = {  
			new Plant("바질",    LifeCycle.ANNUAL),  
			new Plant("캐러웨이", LifeCycle.BIENNIAL),  
			new Plant("딜",      LifeCycle.ANNUAL),  
			new Plant("라벤더",   LifeCycle.PERENNIAL),  
			new Plant("파슬리",   LifeCycle.BIENNIAL),  
			new Plant("로즈마리", LifeCycle.PERENNIAL)  
	};  

	// 코드 37-2 EnumMap을 사용해 데이터와 열거 타입을 매핑한다. (227쪽)  
	Map<Plant.LifeCycle, Set<Plant>> plantsByLifeCycle =  
			new EnumMap<>(Plant.LifeCycle.class);  
			
	for (Plant.LifeCycle lc : Plant.LifeCycle.values())  
		plantsByLifeCycle.put(lc, new HashSet<>());  
		
	for (Plant p : garden)  
		plantsByLifeCycle.get(p.lifeCycle).add(p);  
		
	System.out.println(plantsByLifeCycle);  
}  
```
- `EnumMap` 은 열거 타입을 키로 사용한다.
- **더 짧고, 안전하고 성능도 비슷하다.**
    - EnumMap의 성능이 `ordinal()`을 쓴 배열과 비슷한 이유는 그 내부에서 `배열`을 사용하기 때문이다.
    - 내부 구현 방식을 안으로 숨겨서 Map의 타입 안전성과 배열의 성능을 얻어낸다.
- 안전하지 않은 형변환을 쓰지 않고, 맵의 key가 열거 타입이므로 출력 결과에 레이블을 달 필요도 없다.
- 배열 인덱스를 계산하는 과정에서 오류가 날 가능성도 없다.

## 3. `스트림` 을 사용하는 방법
- 스트림을 사용해 `Map` 을 관리하면 코드를 더 줄일 수 있다.
- `EnumMap` 이 아닌 고유한 `Map` 을 사용하므로 `EnumMap` 을 써서 **얻은 공간과 성능 이점이 사라진다.**
```java
// 코드 37-3 스트림을 사용한 코드 1 - EnumMap을 사용하지 않는다! (228쪽)  
System.out.println(Arrays.stream(garden)  
		.collect(groupingBy(p -> p.lifeCycle)));  
```

### EnumMap을 사용해 매핑한 스트림 코드
```java
// 코드 37-4 스트림을 사용한 코드 2 - EnumMap을 이용해 데이터와 열거 타입을 매핑했다. (228쪽)  
System.out.println(Arrays.stream(garden)  
		.collect(groupingBy(p -> p.lifeCycle,  
				() -> new EnumMap<>(LifeCycle.class), toSet())));  
```
- 간단한 코드로 EnumMap의 공간과 성능 이점을 얻는다.

#### 스트림 + EnumMap - 추천 🌟
- 스트림을 사용하면 EnumMap만 사용했을 때와 다르게 동작한다.
- `EnumMap` : 언제나 식물의 생애주기당 하나씩의 중첩 맵을 만든다.
- **`스트림` : 해당 생애주기에 속한 식물이 있을 때만 만든다.**

# 중첩 배열, 맵
- 두 열거타입의 값들을 매핑하기
## 1. 배열들의 배열에 `ordinal()` 사용 - 비추
- 두 열거 타입을 매핑한 배열들의 배열
- `ordinal()`을 인덱스로 사용한다.
```java
// 코드 37-6 중첩 EnumMap으로 데이터와 열거 타입 쌍을 연결했다. (229-231쪽)  
public enum Phase {  
    SOLID, LIQUID, GAS;  
    
   public enum Transition {
    MELT, FREEZE, BOIL, CONDENSE, SUBLIME, DEPOSIT;

    // 행은 from의 ordinal을, 열은 to의 ordinal을 인덱스로 쓴다.
    private static final Transition[][] TRANSITIONS = {
        { null, MELT, SUBLIME }, // Solid -> solid, solid -> liquid
        { FREEZE, null, BOIL },
        { DEPOSIT, CONDENSE, null }
    };

    // 한 상태에서 다른 상태로의 전이를 반환한다.
    public static Transition from(Phase from, Phase to) {
        return TRANSITIONS[from.ordinal()][to.ordinal()];
    }
} 
```
- 컴파일러는 `ordinal()` 과 `배열 인덱스`의 관계를 알 도리가 없다.
    - 배열을 수정하거나 열거 타입을 수정할 경우 `런타임 오류`가 날 수 있다.
- 상전이 표의 크기는 상태의 가짓수가 늘어나면 제곱해서 커미며 `null` 로 채워지는 칸도 늘어날 것이다.

### 새로운 상태 추가하기
- 새로운 상태 `PLASMA` 추가
- 기체 -> 플라즈마 : 이온화
- 플라즈마 -> 기체 : 탈이온화

- 배열로 만든 코드
    - 새로운 상수를 Phase에 1개, Transition에 2개 추가
    - **원소 9개짜리 배열들의 배열을 원소 16개짜리로 교체**

## 2. `EnumMap` 사용 - 추천 🌟
```java
// 코드 37-6 중첩 EnumMap으로 데이터와 열거 타입 쌍을 연결했다. (229-231쪽)  
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
  
        // 상전이 맵을 초기화한다.  
        private static final Map<Phase, Map<Phase, Transition>>  
                m = Stream.of(values()).collect(groupingBy(t -> t.from,  
                () -> new EnumMap<>(Phase.class),  
                toMap(t -> t.to, t -> t,  
                        (x, y) -> y, () -> new EnumMap<>(Phase.class))));  
          
        public static Transition from(Phase from, Phase to) {  
            return m.get(from).get(to);  
        }  
    }  
}
```
- 맵 2개를 중첩한다.
    - 외부 맵: `Phase -> Map<Phase, Transition>`
    - 내부 맵: `Phase -> Transition`
- **m** : 이전 상태에서 이후 상태에서 전이로의 맵에 대응시키는 맵
    - `Stream.of(values())`: Transition enum의 모든 값들로 **스트림 생성**
    - `.collect(groupingBy(...))`: 이 스트림의 요소들을 **그룹화**
    - `t -> t.from`: 각 Transition의 'from' Phase를 기준으로 **그룹화** (외부 맵의 키)
    - `() -> new EnumMap<>(Phase.class)`: 외부 맵으로 EnumMap을 사용하도록 지정
    - `toMap(...)`: 내부 맵을 생성하는 부분
        - `t -> t.to`: 내부 맵의 키로 'to' Phase를 사용
        - `t -> t`: 값으로는 Transition 자체를 사용
        - `(x, y) -> y`: 같은 키에 대해 여러 값이 있을 경우 새 값을 사용
        - `() -> new EnumMap<>(Phase.class)`: 내부 맵으로도 `EnumMap` 을 사용하도록 지정

- 맵 팩토리 : `() -> new EnumMap<>(Phase.class)` EnumMap을 생성하는 팩토리
    - 일반적인 HashMap과 달리, EnumMap을 생성할 때는 어떤 Enum 타입을 키로 사용할지 명시해야 한다.
- 수집기들은 `점층적 팩토리`를 제공한다.
    - `점층적 팩토리`: 수집기가 결과를 만들어가는 과정에서 단계별로 (혹은 계층별로) 컨테이너를 생성할 수 있게 해주는 기능

### 새로운 상태 추가하기
- 새로운 상태 `PLASMA` 추가
- 기체 -> 플라즈마 : 이온화
- 플라즈마 -> 기체 : 탈이온화
- `EnumMap` 중첩 맵 사용
    - **새로운 상수를 Phase에 1개, Transition에 2개 추가햐면 끝난다.**
- 낭비되는 공간, 시간이 없이 명확하고 안전하고 유지보수하기 쉽다.

# 결론
- 배열의 인덱스를 얻기 위해 `ordinal()` 을 사용하지 말고, `EnumMap` 을 사용하자.
- 다차원 관계(중첩 맵)은 `EnumMap<..., EnumMap<...>>` 으로 표현하라.
