## ✍️ 개념의 배경

얕은 복사 : '주소 값'을 복사

깊은 복사 : '실제 값'을 새로운 메모리 공간에 복사하는 것

# 요약

---

**clone() 이란?**

- Object 클래스에 정의되어 있으며, 객체의 필드값을 복사하여 새로운 객체를 만들어 주는 메서드
- 기본적으로 얕은 복사

**clone 사용법**

- 일반 규약을 지켜야함

- **불변 객체**
    
    cloneable → clone 메서드 재정의 (public, super.clone())
    
    ```java
    public final class Item implement Cloneable {
    	private String name;
    
    	@Override public Item clone() {
    		try {
    			return (Item) super.clone();
    		} catch (CloneNotSupportedException e) {
    			throw new AssertionError();
    		}
    	}
    }
    ```
    
    1. 외부에서 사용하기 위해서는 protected → **public** 으로 오버라이드
    2. **Cloneable 인터페이스**를 구현해줘야함 (그렇지 않으면, **`CloneNotSupportedException`**)

**관례를 지키지 않는다면? (super.clone()을 사용하지 않는다면?)**

```java
public final class Item implement Cloneable {
	private String name;

	@Override public Item clone() {
			Item item = new Item();
			item.name = this.name;
			return item;
}

public final class SubItem extends Item implement Cloneable {
	private String name;

	@Override public SubItem clone() {
			return (SubItem) super.clone();
	}

	public static void main(String[] args) {
		SubItem item = new SubItem();
		SubItem clone = item.clone(); // xxxx

		Item item = new SubItem();
		SubItem clone = item.clone(); // oooo
	}
}

```

- **가변 객체 (규약만 지키면 안됨!)**
    
    <얕은 복사>  
    stack, copy —> 같은 elements
    
    ```java
    public class Stack implements Cloneable {
    	private Object[] elements;
    	private int size = 0;
    	private static final int CAPACITY = 16;
    
    	public Stack() {
    			this.elements = new Object[CAPACITY];
    	}
    
    	// push, pop 메서드
    
    	@Override public Stack clone() {
    			try {
    				Stack result = (Stack) super.clone();
    				result.elemnets = elements.clone();
    				return result;
    			}
    	}
    }
    
    public static void main(String[] args) {
    	Object[] values = new Object[2];
    	values[0] = ~~
    	values[1] = ~~
    
    	Stack stack = new Stack();
    	for (Object arg : values)
    		stack.push(arg);
    
    	Stack copy = stack.clone();
    
    	// stack을 모두 pop
    
    	// copy 내부 값 출력 --> 비어있음!
    }
    ```
    
    - `result.elemnets = elements.clone()` 의 문제
        - elements 필드가 final이면 x  
        ↔ *‘가변 객체를 참조하는 필드는 final로 선언하라’* [Cloneable 아키텍처 일반 용법]
        - 배열만 복사되고 배열안의 인스턴스들은 동일한 곳 참조
            
            <얕은 복사>
            stack —> s_elements / copy —> c_elements (배열만 복사)
            
            stack —> s_elements[0] == c_elements[0] (배열안의 인스턴스들은 동일하게 참조)
            
        

**그래서 깊은 복사 하려면 어떻게???**

**대안**

- 배열 내부를 일일이 복사

    ```java
    
        public Entry deepCopy() {
        return new Entry(key, value, next == null ? null : next.deepCopy());
    }
    ```

    ```java
    @Override
    public CustomHashTable clone() {
        try {
            CustomHashTable result = (CustomHashTable) super.clone();
            result.buckets = new Entry[buckets.length];

            for (int i = 0; i < buckets.length; i++) {
                if (buckets[i] != null)
                    result.buckets[i] = buckets[i].deepCopy();
            }

            return result;
        } catch (final CloneNotSupportedException e) {
            throw new AssertionError();
        }
    }
    ```

    

**++ 주의 할점**

- 고수준 메서드들을 호출
    
    put, get 을 통해서 데이터 넣어주기 —> 성능 문제 / Cloneable 아키텍처x
    
- clone 내에서는 하위 클래스에서 재정의할수있는 메서드 사용 x
- 추상 클래스에서는 Cloneable 지양
- 멀티 스레드에 안전한 환경에서 만들어져야한다면 synchronized

**현실적인 대안**

- 생성자를 사용해서 카피
    
- copy전용 팩토리 메서드를 만드는것
    


**결론!!**

clone사용은 지양하자!



[covariant return type](https://velog.io/@woogiekim/Covariant-return-type) 설명 
    
