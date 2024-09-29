# 76. 가능한 한 실패 원자적으로 만들라
## 실패 원자적(failture-atomic)
- 호출된 메서드가 실패하더라도 해당 객체는 메서드 호출 전 상태를 유지해야한다.

### 실패 원자적으로 만들기 - 1. 불변 객체로 설계하기
- 불변 객체는 태생적으로 실패 원자적이다.
- 메서드가 실패하면 새로운 객체가 만들어지지는 않을 수 있으나 기존 객체가 불안정한 상태에 빠지지 않는다.
    - 불변 객체의 상태는 생성 시점에 고정되어 절대 변하지 않는다.

### 실패 원자적으로 만들기 - 2. 매개변수의 유효성을 검사한다
- 객체의 내부 상태를 변경하기 전에 잠재적 예외의 가능성 대부분을 걸러낼 수 있다.
- 실패할 가능성이 있는 모든 코드를 객체의 상태를 바꾸는 코드보다 먼저 배치하라.
```java
public Object pop(){
	if (size ==0) 
		throw new EmptyStackException();
	Object result = elements[--size];
	elements[size] = null;
	return result;
}
```

### 실패 원자적으로 만들기 - 3. 객체의 임시 복사본에서 작업을 수행한 다음, 작업이 성공적으로 완료되면 원래 객체와 교체한다
- 데이터를 `임시 자료구조`에 저장해 작업하는게 더 빠를때 적용하기 좋다.
    - ex) 어떤 정렬 메서드에서는 원소들을 배열에 옮겨 담는데, 이는 배열이 훨씬 빠르게 접근할 수 있기 때문이다.
```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class FailureAtomicExamples {

    /**
     * 3. 객체의 임시 복사본에서 작업을 수행한 다음, 작업이 성공적으로 완료되면 원래 객체와 교체하는 방법
     */
    public static class ImmutableList<E> {
        private final List<E> elements;

        public ImmutableList(List<E> elements) {
            this.elements = new ArrayList<>(elements);
        }

        public ImmutableList<E> sort() {
            List<E> temp = new ArrayList<>(elements);
            try {
                Collections.sort((List<E>)temp);
                return new ImmutableList<>(temp);
            } catch (Exception e) {
                // 정렬 중 예외가 발생하면 원본 리스트는 변경되지 않음
                throw new RuntimeException("정렬 중 오류 발생", e);
            }
        }

        public List<E> getElements() {
            return Collections.unmodifiableList(elements);
        }
    }

    public static void main(String[] args) {
        // ImmutableList 예제
        List<Integer> numbers = new ArrayList<>(List.of(3, 1, 4, 1, 5, 9, 2, 6, 5, 3));
        ImmutableList<Integer> immutableList = new ImmutableList<>(numbers);
        System.out.println("정렬 전: " + immutableList.getElements());
        ImmutableList<Integer> sortedList = immutableList.sort();
        System.out.println("정렬 후: " + sortedList.getElements());
        System.out.println("원본 리스트: " + immutableList.getElements());
    }
}
```

### 실패 원자적으로 만들기 - 4. 작업 도중 발생하는 실패를 가로채는 복구 코드를 작성하여 작업 전 상태로 되돌리는 방법
- 내구성을 보장해야 하는 자료구조에 쓰인다.
    - 자주 쓰이지는 않는다.
```java
public class FailureAtomicExamples {
    /**
     * 4. 작업 도중 발생하는 실패를 가로채는 복구 코드를 작성하여 작업 전 상태로 되돌리는 방법
     */
    public static class DurableLinkedList<E> {
        private final CopyOnWriteArrayList<E> elements = new CopyOnWriteArrayList<>();
        private final List<Runnable> undoActions = new ArrayList<>();

        public void addElement(E element) {
            elements.add(element);
            undoActions.add(() -> elements.remove(elements.size() - 1));
        }

        public void removeElement(E element) {
            int index = elements.indexOf(element);
            if (index != -1) {
                elements.remove(index);
                E removedElement = element;
                undoActions.add(() -> elements.add(index, removedElement));
            }
        }

        public void performComplexOperation() {
            try {
                // 복잡한 작업 수행
                addElement((E)"A");
                removeElement((E)"B");
                // 여기서 예외가 발생한다고 가정
                if (true) throw new RuntimeException("작업 중 오류 발생");
                addElement((E)"C");
            } catch (Exception e) {
                // 실패 시 undo 작업 수행
                System.out.println("오류 발생. 작업 전 상태로 되돌립니다.");
                for (int i = undoActions.size() - 1; i >= 0; i--) {
                    undoActions.get(i).run();
                }
                undoActions.clear();
                throw new RuntimeException("작업 실패, 상태 복구됨", e);
            }
            // 작업이 성공적으로 완료되면 undo 작업 목록 초기화
            undoActions.clear();
        }

        public List<E> getElements() {
            return new ArrayList<>(elements);
        }

    public static void main(String[] args) {
        // DurableLinkedList 예제
        DurableLinkedList<String> durableList = new DurableLinkedList<>();
        durableList.addElement("X");
        durableList.addElement("Y");
        System.out.println("초기 상태: " + durableList.getElements());
        
        try {
            durableList.performComplexOperation();
        } catch (Exception e) {
            System.out.println("예외 발생: " + e.getMessage());
        }
        
        System.out.println("최종 상태: " + durableList.getElements());
    }
}
```

### 실패 원자성을 항상 달성할 수 있는 것은 아니다
- ex) 두 스레드가 동기화 없이 같은 객체를 동시에 수정한다면 그 객체의 일관성이 깨질 수 있다.
    - `ConcurrentModificationException`을 잡아냈다고 해서 그 객체가 여전히 쓸 수 있는 상태라고 가정해서는 안된다.
- `Error`는 복구할 수 없으므로 `AssertionError`에 대해서는 실패 원자적으로 만들려는 시도조차 할 필요가 없다.
- 실패 원자성을 달성하기 위한 비용이나 복잡도가 아주 큰 연산의 경우 실패 원자적으로 꼭 만들지 않아도 된다.
    - 문제가 무엇인지 알고 나면 실패 원자성을 공짜로 얻을 수 있는 경우가 더 많다.
- 만약 실패 원자성을 지키지 못한다면 API 설명에 명시해야 한다.

