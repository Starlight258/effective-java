


# 요약
---

### 정보은닉의 장점

- 시스템 개발 속도를 높일 수 있음 —> 여러 컴포넌트를 병렬 개발
- 시스템 관리 비용을 낮춤 —> 컴포넌트를 더 빨리 파악
- 성능 최적화를 하는 데에 도움 —> 다른 컴포넌트에 영향을 주지않고 해당 컴포넌트만 최적화 할수 있음
- 재사용성을 높임
- 개발 난이도를 낮춰줌

### 클래스 접근권한의 원칙

- 모든 클래스와 멤버의 접근성을 가능한 한 좁혀야 함
- 탑레벨 클래스와 인터페이스에는 package-private 또는 public을 쓸 수 있음
    - public —> API (영원히 관리해야 함)
    - package-private —> 내부구현체 (외부에서 쓰지않으면)
    - **private / [protected](https://www.notion.so/eeb4a2f87927444186a696f32bb3b5db?pvs=21)는 사용 xxx**
- 한 클래스에서만 사용하는 package-private는 [**private static](https://www.notion.so/eeb4a2f87927444186a696f32bb3b5db?pvs=21)으로 중첩해라**
    
    ```java
    public class Animal {
        private String name = "cat";
        private Age age = new Age();
    
        public void test() {
            age.method();
        }
    
        private static class Age {
            private int age = 10;
    
            public void method() {
                Animal animal = new Animal();
                System.out.println(animal.name); // 바깥 클래스인 Animal의 private 멤버 접근
            }
        }
    }
    ```
    

### 멤버 접근권한의 원칙

- private, package-private은 내부 구현
- Public과 protected는 공개 API → 영원히 관리해야함. 따라서 공개 API는 적을수록 좋음
    - 주의점 — 상위 클래스 재정의할때는 상위 클래스보다 좁게 재정의 할 수 없음 (리스코프 치환 원칙)
- 테스트 목적으로 private → package-private으로 풀어주는 것은 허용. 하지만 공개 API로 푸는 것은 X
- public 클래스의 인스턴스 필드는 되도록 public이 아니어야 함 (private, final)
—> 객체 제한 힘을 잃음 / 스레드 안전 x
- 클래스에서 public static final 배열 필드를 두거나 이 필드를 반환하는 접근자 메서드를 제공해서는 안됨
    - 상수만
    - 불변 리스트
        
        ```java
        // 불변 리스트 
        private static final Thing[] PRIVATE_VALUES = {,,,};
        public static final List<Thing> VALUES = 
        				Collections.unmodifableList(Arrays.asList(PRIVATE_VALUES));
        
        // 방어적 복사
        private static final Thing[] PRIVATE_VALUES = {,,,};
        public static final Thing[] values() {
        		return PRIVATE_VALUES.clone();
        }
        ```
        

