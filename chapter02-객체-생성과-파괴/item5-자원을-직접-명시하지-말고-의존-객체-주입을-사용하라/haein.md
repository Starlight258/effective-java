## ✍️ 개념의 배경

객체 내부에 의존성을 직접 작성하는 경우 곤란한 경우에 대해 설명함

## 요약

---

정적 유틸리티 클래스

```java
public class SpellChecker {
	**private static final Lexicon dictionary = ...;**
	**private** SpellChecker() {}
	
	public static ...
}
```

싱글턴 객체

```java
public class SpellChecker {
	**private static final Lexicon dictionary = ...;
	private SpellChecker(...){}**
	public static SpellChecker **INSTANCE** = new SpellChecker(...);
	
	public static ...
}
```

맞춤법 검사기가 여러 타입의 사전을 지원해야 하는 경우(사용하는 자원에 따라 동작이 달라지는 경우) 싱글턴이나 정적 유틸리티 클래스는 적절하지 않다

이런 경우 의존 객체 주입을 활용할 수 있다

```java
public class SpellChecker {
	**private static final Lexicon dictionary**;
	public SpellChecker(Lexicon dictionary){
		**this.dictionary = Objects.requireNonNull(dictionary); // 생성자에서 직접 자원 주입**
	}
}
```

이제 클라이언트가 의존 객체들을 안심하고 공유할 수 있다

의존 객체 주입은 필요한 객체가 많아진다면 관리하기 어려울 수 있지만

Spring 과 같은 프레임워크의 도움을 받는다면 적절하게 관리할 수 있다 

## 개념 관련 경험

spring-core 에서 가장 강조하는 개념으로 solid중 개방-폐쇄 원칙을 지키기 위해 사용하는 것으로 알고 있음 

## 이해되지 않았던 부분

## ⭐️ **번외: 추가 조각 지식**

## 질문