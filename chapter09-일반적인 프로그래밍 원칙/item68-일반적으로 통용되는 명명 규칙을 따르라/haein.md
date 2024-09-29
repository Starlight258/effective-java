## 요약

> 자바 플랫폼은 명명 규칙이 잘 정립되어 있으며, 그중 많은 것이 [자바 언어 명세](https://docs.oracle.com/javase/specs/jls/se7/html/jls-6.html) 에 기술되어 있다. 자바의 명명 규칙은 크게 철자와 문법, 두 범주로 나뉜다 


### 패키지와 모듈

- 이름은 각 요소를 점(.)으로 구분하여 계층적으로 짓는다.
- 요소들은 모두 소문자 알파벳 혹은 (드물게) 숫자로 이뤄진다.
- 조직의 인터넷 도메인 이름을 역순으로 사용한다.
    - org.junit.jupiter
    - com.google
- 예외적으로 표준 라이브러리와 선택적 패키지들은 각각 java와 javax로 시작한다.
    - java.util.Objects;
- 각 요소는 일반적으로 8자 이하의 짧은 단어
    - utilities —> util
    - 여러 단어로 구성된 이름은 첫글자만 따서 씀 —> awt (Abstract Window Toolkit)
- 도메인 이름 뒤에 요소 하나만 붙인 경우가 많지만 많은 기능을 제공하는 경우 계층을 나눠 더 많은 요소로 구성해도 좋다
    - java.util.concurrent.atomic

### 클래스와 인터페이스

- 이름은 하나 이상의 단어로 이뤄지며, 각 단어는 대문자로 시작한다.
    - List, FutherTask
- 여러 단어의 첫 글자만 딴 약자나 max , min 처럼 널리 통용되는 줄임말을 제외하고는 단어를 줄여 쓰지 않도록 한다
- 약자의 경우 첫 글자만 대문자로 하는 쪽이 훨씬 많다 ex : HttpUrl 과 HTTPURL

### 메서드와 필드

- 첫 글자를 소문자로 쓴다는 점만 빼면 클래스 명명 규칙과 같다 (remove, ensureCapacity)
- 첫 단어가 약자라면 단어 전체가 소문자여야 한다
- 단, 상수 필드는 예외이다 단어는 모두 대문자로 쓰며, 단어 사이는 밑줄로 구분


### 지역변수
- 다른 멤버와 비슷한 명명 규칙이 적용된다
- 약어를 사용해도 좋다
- 약어를 사용해도 그 변수가 사용되는 문맥에서 의미를 쉽게 유추할 수 있다(i, demon, houseNum)
- 입력 매개변수는 메서드 설명 문서에도 등장하는 만큼 일반 지역변수보다는 신경을 써야 한다 

### 타입 매개변수

- 타입 매개변수 이름은 보통 한 문자로 표현한다.
- T: 임의의 타입
- E: 컬렉션 원소의 타입
- K: 맵의 키, V: 맵의 값
- X: 예외
- R: 메서드의 반환
- T, U, V 혹은 T1, T2, T3 : 그외 임의 타입의 시퀀스

### 문법

- 객체를 생성할 수 있는 클래스(열거 타입 포함)의 이름은 보통 단수 명사나 명사구를 사용한다  (`Thread`, `PriorityQueue`)
- 객체를 생성할 수 없는 클래스의 이름은 보통 복수형 명사로 짓는다  `Collectors`, `Collections`)
- 인터페이스 이름은 클래스와 동일하거나 able 혹은 ible로 끝나는 형용사로 짓는다 (`Runnable`, `Iterable`, `Accessible`)
- 애너테이션은 지배적인 규칙 없이 명사, 동사, 전치사, 형용사가 두루 쓰인다(`BindngAnnotation`, `Inject`, `ImplementedBy`, `Singleton`)
- 어떤 동작을 수행하는 메서드의 이름은 동사나 목적어를 포함한 동사구로 짓는다 `append` `drawImage`
- boolean 값을 반환하는 메서드는 보통 is나 (드물게) has로 시작하고 명사, 명사구, 형용사로 기능하는 아무 단어나 구로 끝나도록 짓는다 `isDigit`, `isEmpty`, `isEnabled`
- 반환 타입이 boolean이 아니거나 해당 인스턴스의 속성을 반환하는 메서드의 이름은 보통 명사, 명사구, get으로 시작하는 동사구로 짓는다
- get 으로 시작하는 형태는 주로 자바빈즈 명세에 뿌리를 두고 있다 
    

### 특별한 메서드 이름

- 객체의 타입을 바꿔서, 다른 타입의 또 다른 객체를 반환하는 메서드는 보통 toType 형태로 짓는다 (`toString`, `toArray`)
- 객체의 내용을 다른 뷰로 보여주는 메서드는 asType 형태로 짓는다 (`asList`)
- 객체의 값을 기본 타입 값으로 변환하는 메서드의 이름은 보통 typeValue 형태로 짓는다 (`intValue`)
- 정적 팩터리의 이름은 아이템 1참고 (from, of, valueOf, instance, getInstance, newInstance, getType, newType 등)

### 필드 이름

- 필드 이름은 API 설계를 잘 했다면, 직접 노출될 일이 거의 없기 때문에 덜 명확하고 덜 중요하다
- boolean 타입의 필드 이름은 boolean 접근자 메서드에서 앞 단어를 뺀다 (`initialized`, `composite`)
- 다른 타입은 명사나 명사구를 사용한다 (`height`, `digits`, `bodyStyle`)