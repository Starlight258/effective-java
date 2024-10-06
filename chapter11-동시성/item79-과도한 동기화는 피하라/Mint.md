# 79. 과도한 동기화는 피하라
## 과도한 동기화
- 과도한 동기화는 성능을 떨어뜨리고, 교착상태에 빠뜨리고, 심지어 예측할 수 없는 동작을 낳는다.

### 동기화 블록 안에서 외계인 메서드를 호출하지 마라
- `외계인 메서드` (외부에서 온 메서드) 가 하는 일에 따라 동기화된 영역이 예외를 일으키거나, 교착상태에 빠지거나 데이터를 훼손할 수 있다.
- 응답 불가와 안전 실패를 피하려면 **동기화 메서드나 동기화 블록 안에서는 제어를 절대로 클라이언트에 양도하면 안된다.**
    - 동기화된 영역 안에서는 재정의할 수 있는 메서드는 호출하면 안된다.
    - 클라이언트가 넘겨준 함수 객체를 호출해서도 안된다.
```java
// 재사용할 수 있는 전달 클래스 (118쪽의 코드 18-3 재사용)  
public class ForwardingSet<E> implements Set<E> {  
    private final Set<E> s;  
    public ForwardingSet(Set<E> s) { this.s = s; }  
  
    public void clear()               { s.clear();            }  
    public boolean contains(Object o) { return s.contains(o); }  
    public boolean isEmpty()          { return s.isEmpty();   }  
    public int size()                 { return s.size();      }  
    public Iterator<E> iterator()     { return s.iterator();  }  
    public boolean add(E e)           { return s.add(e);      }  
    public boolean remove(Object o)   { return s.remove(o);   }  
    public boolean containsAll(Collection<?> c)  
    { return s.containsAll(c); }  
    public boolean addAll(Collection<? extends E> c)  
    { return s.addAll(c);      }  
    public boolean removeAll(Collection<?> c)  
    { return s.removeAll(c);   }  
    public boolean retainAll(Collection<?> c)  
    { return s.retainAll(c);   }  
    public Object[] toArray()          { return s.toArray();  }  
    public <T> T[] toArray(T[] a)      { return s.toArray(a); }  
    @Override public boolean equals(Object o)  
    { return s.equals(o);  }  
    @Override public int hashCode()    { return s.hashCode(); }  
    @Override public String toString() { return s.toString(); }  
}
```

```java
// 집합 관찰자 콜백 인터페이스 (421쪽)  
public interface SetObserver<E> {  
    // ObservableSet에 원소가 더해지면 호출된다.  
    void added(ObservableSet<E> set, E element);  
}
```

```java
public class ObservableSet<E> extends ForwardingSet<E> {  
    public ObservableSet(Set<E> set) { super(set); }  
  
// 코드 79-1 잘못된 코드. 동기화 블록 안에서 외계인 메서드를 호출한다. (420쪽)  
    private final List<SetObserver<E>> observers  
            = new ArrayList<>();  
  
    public void addObserver(SetObserver<E> observer) {  
        synchronized(observers) {  
            observers.add(observer);  
        }  
    }  
  
    public boolean removeObserver(SetObserver<E> observer) {  
        synchronized(observers) {  
            return observers.remove(observer);  
        }  
    }  
  
    private void notifyElementAdded(E element) {  
        synchronized(observers) {  
            for (SetObserver<E> observer : observers)  
                observer.added(this, element);  
        }  
    }  

    @Override
    public boolean add(E element) {
        boolean added = super.add(element);
        if (added) {
            notifyElementAdded(element);
        }
        return added;
    }
}
```

- 0~99 호출 코드 (정상 동작)
```java
// ObservableSet 동작 확인 #1 - 0부터 99까지 출력한다. (422쪽)  
public class Test1 {  
    public static void main(String[] args) {  
        ObservableSet<Integer> set =  
                new ObservableSet<>(new HashSet<>());  
  
        set.addObserver((s, e) -> System.out.println(e));  
  
        for (int i = 0; i < 100; i++)  
            set.add(i);  
    }  
}
```
- 23이면 자기 자신을 제거 (잘못 동작)
    - `ConcurrentModificationExcpetion` 발생 : notifyElementAdded에서 반복 중에 removeObserver를 호출하므로 컬렉션을 수정한다.
        - 반복 중에 컬렉션이 수정되면 이 예외를 던진다.
```java
// ObservableSet 동작 확인 #2 - 정숫값이 23이면 자신의 구독을 해지한다. (422쪽)  
public class Test2 {  
    public static void main(String[] args) {  
        ObservableSet<Integer> set =  
                new ObservableSet<>(new HashSet<>());  
  
        set.addObserver(new SetObserver<>() {  
            public void added(ObservableSet<Integer> s, Integer e) {  
                System.out.println(e);  
                if (e == 23) // 값이 23이면 자신을 구독해지한다.  
                    s.removeObserver(this);  
            }  
        });  
  
        for (int i = 0; i < 100; i++)  
            set.add(i);  
    }  
}
```
- 구독 해제시 다른 스레드에게 부탁한다면? **교착상태**에 빠진다.
    - 백그라운드 스레드가 `removeObserver`를 하려면 락을 얻어야하는데 락은 메인 스레드가 가지고 있다.
    - 실제 시스템에서도 **동기화된 영역 안에서 외계인 메서드를 호출하여 교착상태에 빠지는 경우**가 있다.
```java
// ObservableSet 동작 확인 #3public class Test3 {  
    public static void main(String[] args) {  
        ObservableSet<Integer> set =  
                new ObservableSet<>(new HashSet<>());  
  
// 코드 79-2 쓸데없이 백그라운드 스레드를 사용하는 관찰자 (423쪽)  
        set.addObserver(new SetObserver<>() {  
            public void added(ObservableSet<Integer> s, Integer e) {  
                System.out.println(e);  
                if (e == 23) {  
                    ExecutorService exec =  
                            Executors.newSingleThreadExecutor();  
                    try {  
                        exec.submit(() -> s.removeObserver(this)).get();  
                    } catch (ExecutionException | InterruptedException ex) {  
                        throw new AssertionError(ex);  
                    } finally {  
                        exec.shutdown();  
                    }  
                }  
            }  
        });  
  
        for (int i = 0; i < 100; i++)  
            set.add(i);  
    }  
}
```

#### 열린 호출 (open call)
- **열린 호출** : 동기화 영역 바깥에서 호출되는 외계인 메서드
    - 얼마나 오래 실행될지 알 수 없다.
    - 동기화 영역 안에서 호출된다면 그동안 다른 스레드는 보호 자원을 사용하지 못하고 대기해야만 한다.
    - 열린 호출은 실패 방지 효과 외에도 동시성 효율을 크게 개선해준다.

- 불변식이 임시로 깨진 상태라면?
    - 교착상태가 될 상황을 안전 실패(데이터 훼손)으로 변모시키는 문제가 있다.
- 해결 방법 : 외계인 메서드 호출을 동기화 블록 바깥으로 옮기고, **리스트 복사**만 동기화 블록에 포함한다. (**동기화 블록 최소화**)
    - `observer.added()` 메서드가 `removeObserver()`를 호출해도, 현재 순회 중인 snapshot에는 영향을 주지 않는다.
```java
// 코드 79-3 외계인 메서드를 동기화 블록 바깥으로 옮겼다. - 열린 호출 (424쪽)  
private void notifyElementAdded(E element) {  
	List<SetObserver<E>> snapshot = null;  
	synchronized(observers) {  
		snapshot = new ArrayList<>(observers);  
	}  
	for (SetObserver<E> observer : snapshot)  
		observer.added(this, element);  
}
```

#### CopyOnWriteArrayList
- `ArrayList`를 구현한 클래스
- 내부를 변경하는 작업은 항상 복사본을 만들어서 수행한다.
- 내부의 배열은 절대 수정되지 않으므로 **순회할 때 락이 필요 없어 매우 빠르다.**
- 수정할 일은 드물고 순회만 빈번히 일어나는 관찰자 리스트 용도로 최적이다.
    - 수정이 될 경우 다음 순회때 반영된다.
    - 매 쓰기 작업마다 전체 리스트를 복사하므로, 리스트가 크고 쓰기 작업이 빈번하면 성능 문제가 발생한다.
```java
// 코드 79-4 CopyOnWriteArrayList를 사용해 구현한 스레드 안전하고 관찰 가능한 집합 (425쪽)  
private final List<SetObserver<E>> observers =  
        new CopyOnWriteArrayList<>();  
  
public void addObserver(SetObserver<E> observer) {  
    observers.add(observer);  
}  
  
public boolean removeObserver(SetObserver<E> observer) {  
    return observers.remove(observer);  
}  
  
private void notifyElementAdded(E element) {  
    for (SetObserver<E> observer : observers)  
        observer.added(this, element);  
}  
  
@Override public boolean add(E element) {  
    boolean added = super.add(element);  
    if (added)  
        notifyElementAdded(element);  
    return added;  
}  
  
@Override public boolean addAll(Collection<? extends E> c) {  
    boolean result = false;  
    for (E element : c)  
        result |= add(element);  // notifyElementAdded를 호출한다.  
    return result;  
}
```
> 명시적으로 동기화하는 부분이 사라졌다.

### 동기화 영역에서는 가능한 한 일을 적게 하자
- 오래 걸리는 작업이라면 동기화 영역 바깥으로 옮기는 방법을 찾아보자.

### 과도한 동기화의 비용
- 오늘날은 **멀티코어가 일반화**되어있다.
- 과도한 동기화의 주된 비용은 락을 얻는데 드는 CPU 시간이 아니다.
- 진짜 비용은 경쟁하느라 낭비하는 시간, 즉 여러 코어가 동시에 작업을 수행할 수 있는 기회를 잃는 것이다.
    - **병렬로 실행할 기회를 잃고 모든 코어가 메모리를 일관되게 보기 위한 지연 시간**이 존재한다.
- 또한 과도한 동기화는 가상머신의 코드 최적화를 제한한다.

## 가변 클래스를 작성할 경우
- 1. 동기화를 하지 않고 클래스를 동시에 사용해야 하는 클래스가 외부에서 알아서 동기화하게 하자.
    - ex) `java.util`
- 2. 동기화를 내부에서 수행해 스레드 안전한 클래스로 만들자.
    - ex) `java.util.concurrent`
- StringBuffer는 동기화를 수행하지만 StringBuilder는 동기화를 수행하지 않는다.
- Random은 동기화를 수행하지만 ThreadLocalRandom은 동기화를 수행하지 않는다.

### 여러 스레드가 호출할 가능성이 있는 메서드가 정적 필드를 수정한다면 사용 전 동기화해야한다
- 만약 클라이언트가 여러 스레드로 복제되어 구동된다면 외부에서 동기화할 방법이 없다.
    -  ex) `nextSerialNumber(`) 예시

# 결론
- 교착 상태와 데이터 훼손을 피하려면 동기화 영역 안에서 외계인 메서드를 절대 호출하면 안된다.
    - 동기화 영역 안에서의 작업은 최소한으로 줄이자.
    - 가변 클래스를 설계할 때는 스스로 동기화해야 할지 고민하자.
- 합당한 이유가 있을 때만 내부에서 동기화하고, 동기화했는지 여부를 문서에 명확하게 밝히자.
