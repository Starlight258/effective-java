## ✍️ 개념의 배경

디폴트 메서드란?

- 인터페이스 내에서 구현 코드를 포함하는 메서드로, 해당 인터페이스를 구현하는 모든 클래스에 기본적으로 상속되는 메서드
- 자바8부터 추가 (주로 람다 활용을 위하여 — forEach, stream)

# 요약

---

### 기존 인터페이스에 디폴트 메서드 구현을 추가하는 것은 위험

1) 구현 클래스와는 무관하게 무작정 삽입됨

```java
public interface Collection<E> extends Iterable<E> {
	default boolean removeIf(Predicate<? super E> filter) {
	        Objects.requireNonNull(filter);
	        boolean removed = false;
	        final Iterator<E> each = iterator();
	        while (each.hasNext()) {
	            if (filter.test(each.next())) {
	                each.remove();
	                removed = true;
	            }
	        }
	        return removed;
	    }
	}
}
```

- 문제
    
    아파치 라이브러리의 SynchronizedCollection (클라이언트가 제공한 객체에 락을 검)
    
    —> removeif는 동기화 관련 구현 x
    
    —> 여러 스레드가 공유하는 환경에서 한 스레드가 removeIf 호출하면 ConcurrentModificationException 발생
    
    —> override 해서 재정의하는 것도 쉽지않음
    

2) 런타임 오류를 일으킬 수 있음


### 새로운 인터페이스를 만들때는 표준 구현을 제공하므로 유용

