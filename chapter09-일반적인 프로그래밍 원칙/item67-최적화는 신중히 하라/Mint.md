# 67. 최적화는 신중히 하라
## 최적화 격언
- 그 어떤 핑계보다 효율성이라는 이름 아래 행해진 컴퓨팅 죄악이 더 많다.
- 섣부른 최적화가 만악의 근원이다.
- 최적화를 할 때는 두 규칙을 따르라.
    - 1. 하지 마라
    - 2. (전문가 한정) 아직 하지마라. 완전히 명백하고 최적화되지 않은 해법을 찾을 때까지는 하지 마라

> 최적화는 좋은 결과보다는 해로운 결과로 이어지기 쉽다.
> 빠르지도 않고 제대로 동작하지 않으면서 수정하기는 어려운 소프트웨어가 탄생된다.

### 빠른 프로그램보다는 좋은 프로그램을 작성하라
- 좋은 프로그램이지만 성능이 나오지 않는다면 아키텍처 자체가 최적화할 수 있는 길을 열어준다.
    - **정보 은닉 규칙**을 따르므로 시스템의 나머지에 영향을 주지 않고 **각 요소를 재설계**할 수 있다.
- **성능을 제한하는 설계를 피하라**
    - 컴포넌트나 외부 시스템과의 소통 방식은 후에 변경하기가 아주 어렵다.
- **API를 설계할 때 성능에 영향을 주는 영향을 고려하라**
    - public 타입을 `가변`으로 만들면 방어적 복사를 계속 유발할 수 있다.
    - **컴포지션**으로 해결할 수 있음에도 상속으로 설계하면 public 클래스는 상위 클래스에 영원히 종속된다.
    - **인터페이스**가 있는데 구현 타입을 사용하는 것은 좋지 않다.
        - 특정 구현체에 종속되어 다른 구현체로 바꾸기 쉽지 않다.
> 성능을 위해 API를 왜곡하는 것은 좋지 않다.

### 최적화 시도 전후로 성능을 측정하라
- **시도한 최적화 기법이 오히려 성능을 나빠지게 할 때도 있다.**
- 90%의 시간은 10%의 코드에서 사용된다.
    - `프로파일링 도구`를 통해 최적화할 부분을 찾을 수 있다.
    - 시스템 규모가 커질 수록 프로파일링은 중요해진다.
- **최적화 시도 전후의 성능 측정은 성능 모델이 정교하지 않은 java에서 중요성이 더 크다.**
    - 프로그래머가 작성한 코드와 CPU에서 수행하는 명령 사이의 추상화 격차가 커서 최적화로 인한 성능 변화를 예측하기 어렵다.

## 결론
- **좋은 프로그램을 작성하다보면 성능은 따라오기 마련이다.**
- 시스템을 설계할 때, 특히 `API`, `네트워크 프로토콜`, `영구 저장용 데이터 포맷`을 설계할 때는 성능을 염두에 두어야 한다.
- **시스템 구현을 완료했다면 성능을 측정해 보라.**
    - 빠르지 않다면 `프로파일러`를 사용해 문제의 원인이 되는 지점을 찾아 최적화를 수행하라.
    - 먼저 어떤 알고리즘을 사용했는지 살펴보자.
- **모든 변경 후에는 성능을 측정하자.**
