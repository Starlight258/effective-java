## 요약

### 응답 불가와 안전 실패를 피하려면 동기화 메서드나 동기화 블록 안에서는 제어를 절대로 클라이언트에 양도하면 안 된다
- 동기화된 영역 안에서는 재정의할 수 있는 메서드를 호출해선 안 된다
- 클라이언트가 넘겨준 함수 객체를 호출해서도 안 된다
- 이런 객체들은 무슨 일을 할지도 모르고, 통제할 수도 없는 외계인 메서드(alien method)이다

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

    @Override public boolean add(E element) {
    boolean added = super.add(element);
    if (added)
        notifyElementAdded(element);
    return added;
}

    @Override public boolean addAll(Collection<? extends E> c) {
        boolean result = false;
        for (E element : c)
            result |= add(element);   notifyElementAdded를 호출한다.
        return result;
    }
}


public interface SetObserver<E> {
// ObservableSet에 원소가 더해지면 호출된다.
void added(ObservableSet<E> set, E element);
}


public static void main(String[] args) {
	ObservableSet<Integer> set = new ObservableSet<>(new HashSet<>());
	
	set.addObserver((s, e) -> System.out.println(e));
	
	for(int i = 0; i < 100; i++)
		set.add(i);
}
```
- 집합에 원소가 추가되면 알림을 받는 옵저버 패턴 구현 

```java
public class Test2 {
    public static void main(String[] args) {
        ObservableSet<Integer> set =
                new ObservableSet<>(new HashSet<>());

        set.addObserver(new SetObserver<>() {
            public void added(ObservableSet<Integer> s, Integer e) {
                System.out.println(e);
                if (e == 23)  값이 23이면 자신을 구독해지한다.
                    s.removeObserver(this);
            }
        });

        for (int i = 0; i < 100; i++)
            set.add(i);
    }
}
```
- 그런데 관찰자 자신을 구독해지하는 경우 `ConcurrentModificationException` 발생한다
- 이유는 `added` 메서드가 `ObservableSet.removeObserver()` 메서드를 호출하고 이 메서드가 다시 `observers.remove()` 를 호출하는데 
지금은 사실 `notifyElementAdded` 가 리스트를 순회하는 도중이다
- 리스트를 순회하는 중에 원소를 제거하므로 허용되지 않은 동작이다 


```java
public class Test3 {
    public static void main(String[] args) {
        ObservableSet<Integer> set =
                new ObservableSet<>(new HashSet<>());

 코드 79-2 쓸데없이 백그라운드 스레드를 사용하는 관찰자 (423쪽)
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
- 다른 스레드가 구독해지를 대신 하는 경우 예외는 발생하지 않지만 데드락이 발생한다
- 왜냐하면 메인 스레드가 락을 얻은 시점이고, 백그라운드 스레드가 이를 기다리고 있다
- 실제 시스템에서도 동기화된 영역 안에서 외계인 메서드를 호출하여 교착상태에 빠지는 사례는 자주 있다 

```java
//   코드 79-3 외계인 메서드를 동기화 블록 바깥으로 옮겼다. - 열린 호출 (424쪽)
    private void notifyElementAdded(E element) {
        List<SetObserver<E>> snapshot = null;
        synchronized(observers) {
            snapshot = new ArrayList<>(observers);
        }
        for (SetObserver<E> observer : snapshot)
            observer.added(this, element);
    }
```
- 외계인 메서드 호출을 동기화 블록 바깥으로 옮기면 해결할 수 있다 (열린 호출)
- `notifyElementAdded` 에서 관찰자 리스트를 복사해서 쓰면 락 없이도 안전하게 순회할 수 있다 

```java
private final List<SetObserser<E>> observers = new CopyOnWriteArrayList<>();

public void addObserver(SetObserver<E> observer) {
    observers.add(observer);
}

public boolean removeObserver(SetObserver<E> observer) {
    return observers.remove(observer);
}

public void notifyElementAdded(E element) {
    for (SetObserver<E> observer : observers) {
         observers.added(this, element);
    }
}
```
- 같은 결과를 자바의 `CopyOnWriteArrayList` 클래스를 사용하면 좋다 
- 내부를 변경하는 작업을 항상 깨끗한 복사본을 만들어 수행하도록 구현했고, 내부 배열이 절대 수정되지 않으니 순회할 때 락이 필요 없어 매우 빠르다

 결론:  동기화 영역에서는 가능한 한 일을 적게 하자

 ### 동기화와 성능
 - 과도한 동기화가 초래하는 진짜 비용은 락을 얻는 데 쓰는 CPU 시간이 아니라, 경쟁하느라 낭비하는 시간이다
 - 가상머신의 코드 최적화를 제한하기도 한다
 - 가변 클래스를 다룰 때에는 외부에서 알아서 동기화되도록 하거나 동서싱을 월등히 개선할 수 있을 때면 내부에서 동기화를 수행하여 스레드 안전하게 만들자 