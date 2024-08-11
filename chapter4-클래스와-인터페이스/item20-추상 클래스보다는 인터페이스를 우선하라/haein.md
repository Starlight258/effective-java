
 인터페이스는 추상 클래스에 비해 다양한 장점이 있다.

1. 기존 클래스에 손쉽게 새로운 인터페이스를 구현해넣을 수 있다.
    - Comparable, Iterable, AutoCloseable 인터페이스가 새롭게 추가 되었을 때 표준 라이브러리의 기존 클래스가 이 인터페이스를 구현한 채로 릴리즈 됐다. 
2. 인터페이스는 믹스인mixin 정의에 안성맞춤이다. 
    - 혼합이라는 뜻을 가지고 있는 믹스인은, 믹스인을 구현할 클래스에 원래의 ‘주 타입’ 외에 특정 선택적 행위를 제공한다고 선언하는 효과를 줄 수 있다.
3. 계층구조 없는 타입 프레임워크를 만들 수 있다.
    - 물론 계층이 적절한 개념도 존재하지만, 현실에는 계층을 엄격히 구분하기 어려운 개념도 있다. 

```java
public interface Singer {
	AudioClip sing(Song s);
}

public interface Songwriter {
	Song compose(int chartPosition);
}
```

현실에는 싱어송라이터도 있으므로, 해당 개념을 구현하려면 다음처럼 새로운 계층을 만들면 된다.

```java
public interface SingerSongwriter extends Singer, Songwriter {
	AudioClip strum();
	void actSensitive();
}
```

위의 세 사례 모두 추상클래스에선 구현하기 어려운 부분이다.

## 디폴트 메서드

 - 인터페이스의 메서드 중 구현 방법이 명백한 것이 있다면, 그 구현을 디폴트 메서드로 제공할 수 있다. 디폴트 메서드는 상속하려는 사람을 위해 @implSpec 자바독 태그를 활용하면 좋다. 

- equals 와 hashcode 메서드는 디폴트 메서드로 제공하면 안됨 (골격 구현 클래스에 구현)

## 추상 골격 구현 클래스
- 디폴트 메서드가 가지고 있는 단점을 극복하기 위해, 인터페이스와 추상 골격 구현 클래스를 함께 제공하는 방식으로 인터페이스와 추상 클래스의 장점을 모두 취할 수 도 있다. 

- 인터페이스로는 타입을 정의하고, 골격 구현 클래스는 나머지 메서드를 구현한다(템플릿 메서드 패턴)

- 인터페이스 이름은 interface 라고 할 때, 골격 구현 클래스 이름은 AbstractInterface 이라고 짓는다.

```java
public class IntArrays {
    static List<Integer> intArrayAsList(int[] a) {
        Objects.requireNonNull(a);

        // 다이아몬드 연산자를 이렇게 사용하는 건 자바 9부터 가능하다.
        // 더 낮은 버전을 사용한다면 <Integer>로 수정하자.
        return new AbstractList<>() {
            @Override public Integer get(int i) {
                return a[i];  // 오토박싱(아이템 6)
            }

            @Override public Integer set(int i, Integer val) {
                int oldVal = a[i];
                a[i] = val;     // 오토언박싱
                return oldVal;  // 오토박싱
            }

            @Override public int size() {
                return a.length;
            }
        };
    }

    public static void main(String[] args) {
        int[] a = new int[10];
        for (int i = 0; i < a.length; i++)
            a[i] = i;

        List<Integer> list = intArrayAsList(a);
        Collections.shuffle(list);
        System.out.println(list);
    }
}
```

```java
// 코드 20-2 골격 구현 클래스 (134-135쪽)
public abstract class AbstractMapEntry<K,V>
        implements Map.Entry<K,V> {
    // 변경 가능한 엔트리는 이 메서드를 반드시 재정의해야 한다.
    @Override public V setValue(V value) {
        throw new UnsupportedOperationException();
    }
    
    // Map.Entry.equals의 일반 규약을 구현한다.
    @Override public boolean equals(Object o) {
        if (o == this)
            return true;
        if (!(o instanceof Map.Entry))
            return false;
        Map.Entry<?,?> e = (Map.Entry) o;
        return Objects.equals(e.getKey(),   getKey())
                && Objects.equals(e.getValue(), getValue());
    }

    // Map.Entry.hashCode의 일반 규약을 구현한다.
    @Override public int hashCode() {
        return Objects.hashCode(getKey())
                ^ Objects.hashCode(getValue());
    }

    @Override public String toString() {
        return getKey() + "=" + getValue();
    }
}
```


## 단순 구현
- 골격 구현의 작은 변종
- 추상 클래스가 아니지만, 상속을 위해 인터페이스를 구현
- 동작하는 가장 단순한 구현 (예 : AbstractMap.SimpleEntry)




https://inpa.tistory.com/entry/JAVA-%E2%98%95-%EC%9D%B8%ED%84%B0%ED%8E%98%EC%9D%B4%EC%8A%A4-vs-%EC%B6%94%EC%83%81%ED%81%B4%EB%9E%98%EC%8A%A4-%EC%B0%A8%EC%9D%B4%EC%A0%90-%EC%99%84%EB%B2%BD-%EC%9D%B4%ED%95%B4%ED%95%98%EA%B8%B0


