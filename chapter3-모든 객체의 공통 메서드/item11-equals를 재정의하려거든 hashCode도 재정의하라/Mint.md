# 11. equals를 재정의하려거든 hashCode도 재정의하라.

- equals를 재정의한 클래스 모두에서 hashCode도 재정의해야 한다.
    - 그렇지 않으면 HashMap이나 HashSet 같은 컬렉션의 원소로 사용할 때 문제를 일으킬 것이다.

## hashCode 재정의 규약

1. equals 비교에 사용되는 정보가 변경되지 않았다면, 애플리케이션이 실행되는 동안 **그 객체의 hashCode 메서드는 몇번을 호출해도 일관되게 항상 같은 값을 반환**해야 한다.
2. **equals(Object)가 두 객체를 같다고 판단했다면, 두 객체의 hashCode는 똑같은 값을 반환**해야 한다.
    - 논리적으로 같은 객체는 같은 해시코드를 반환해야한다.
3. **equals(Object)가** **두 객체를 다르다고 판단했더라도, 두 객체의 hashCode가 서로 다른 값을 반환할 필요는 없다**. 단, **다른 객체에 대해서는 다른 값을 반환해야 해시테이블의
   성능이 좋아진다.**
    - 다른 객체에 같은 값을 반환할 경우 여러 객체가 해시테이블의 버킷 하나에 담겨 마치 연결 리스트처럼 동작한다. (O(n)처럼 동작한다.)
    - 좋은 해시 함수라면 서로 다른 인스턴스에 다른 해시코드를 반환한다.

## 좋은 hashCode를 작성하는 요령

```java
@Override public int hashCode(){
        int result=Short.hashCode(areaCode);
        result=31*result+Short.hashCode(prefix);
        result=31*result+Short.hashCode(lineNum);
        return result;
        }
```

1. int 변수 result를 선언한 후 값 c로 초기화한다. 이때 c는 해당 객체의 첫번째 핵심 필드를 단계 2.a 방식으로 계산한 해시코드다.
2. 해당 객체의 나머지 핵심 필드 각각에 대해 다음 작업을 수행한다.
   a. 해당 필드의 해시 코드를 계산한다.
    - 기본 타입 필드 : Type.hashCode(f)
    - 참조 타입 필드면서 클래스의 equals가 필드의 equals를 재귀적으로 호출할 경우 필드의 hashCode를 재귀적으로 호출 (null이라면 0)
    - 배열이라면 핵심 원소 각각을 별도 필드처럼 다룬다 (모든 원소가 핵심 원소라면 Arrays.hashCode, 핵심 원소가 없다면 상수(0))
      b. 해시 코드 c로 result를 갱신한다.
      result = 31 * result + c
3. result를 반환한다.

> 파생 필드는 해시 코드 계산에서 제외해도 된다.
> equals에 사용하지 않는 필드는 반드시 제외해야 한다.

### Object 클래스는 임의의 개수만큼 객체를 받아 해시코드를 계산해주는 정적 메서드인 hash를 제공한다.

속도는 더 느리다.

```java
// 코드 11-3 한 줄짜리 hashCode 메서드 - 성능이 살짝 아쉽다. (71쪽)  
@Override public int hashCode(){
        return Objects.hash(lineNum,prefix,areaCode);
        }
```

### 클래스가 불변이고 해시코드 계산하는 비용이 크다면, 캐싱하는 방식을 고려해야한다.

- 해시의 키로 사용된다면 인스턴스 생성시 해시코드를 계산해두어야한다.
- 해시의 키로 사용되지 않는 경우 지연 초기화 전략을 사용해도 된다.

```java
// 해시코드를 지연 초기화하는 hashCode 메서드 - 스레드 안정성까지 고려해야 한다. (71쪽)  
private int hashCode; // 자동으로 0으로 초기화된다.  

@Override public int hashCode(){
        int result=hashCode;
        if(result==0){
        result=Short.hashCode(areaCode);
        result=31*result+Short.hashCode(prefix);
        result=31*result+Short.hashCode(lineNum);
        hashCode=result;
        }
        return result;
        }
```

### 주의사항

- 성능을 높인다고 해시코드를 계산할때 핵심 필드를 생략해서는 안된다.
    - 해시 품질이 나빠져 해시테이블의 성능을 떨어뜨린다.
- hashCode가 반환하는 값의 생성 규칙을 API 사용자에게 자세히 공표하지 말자.
    - 클라이언트가 이 값에 의지하지 않게 되고, 추후에 계산 방식을 바꿀 수도 있다.

### 결론

- equals를 재정의할때는 hashCode도 반드시 재정의해야 한다.
- 재정의한 hashCode는 Object의 API 문서에 기술된 일반 규약을 따라야 한다.
- 서로 다른 인스턴스라면 되도록 해시 코드도 서로 다르게 구현해야 한다.
- AutoValue나 IDE를 통해 equals와 hashcode를 자동으로 만들 수 있다.

