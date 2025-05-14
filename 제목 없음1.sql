SET SERVEROUTPUT ON

BEGIN
    DBMS_OUTPUT.PUT_LINE('HELLO, PL/SQL');
END;
/

-- PL/SQL의 SELECT문
-- 1) 문법
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
    INTO v_ename
    FROM employees
    WHERE department_id = &부서번호;
    -- 부서번호 10 : 정상실행
    -- 부서번호 50 : TOO_MANY_ROWS (ORA-01422: exact fetch returns more than requested number of rows)
    -- 부서번호 0 : NO_DATA_FOUND(ORA-01403: no data found)
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_ename);
END;
/
-- 2) 주의사항
-- 2.1) SELECT 결과가 Only One!
-- 2.2) SELECT절의 컬럼수 =  INTO절의 변수 갯수

DECLARE
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT employee_id, last_name
    INTO v_eid, v_ename
    -- 1) SELECT > INTO ( OBA-00947: not enough values )
    -- 2) SELECT < INTO ( OBA-00913: too many values )
    FROM employees
    WHERE employee_id = 100;
    
    DBMS_OUTPUT.PUT_LINE('사원번호 : ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('사원이름 : ' || v_ename);
END;
/
-- 2.3) INTO절의 변수 데이터타입 크기 > SELECT절의 컬럼 데이터타입

-- 예제
/*
 사원번호를 입력(치환변수) 할 경우 해당
 사원의 이름과 입사일자를 출력하는 PL/SQL을 작성하세요.
 ==> 출력 : SELECT문
 출력 : 사원이름, 입사일자 ( 테이블 : employees )
 
 SELECT 사원이름, 입사일자
 FROM employees
 WHERE 사원번호
*/
DECLARE
    v_ename employees.last_name%TYPE;
    v_hdate employees.hire_date%TYPE;
BEGIN
    SELECT last_name, hire_date
    INTO v_ename, v_hdate
    FROM employees
    WHERE employee_id = &사원번호; 

    DBMS_OUTPUT.PUT_LINE('사원이름: ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('입사일자: ' || TO_CHAR(v_hdate, 'YYYY-MM-DD'));
END;
/

/*
1.
사원번호를 입력(치환변수사용&)할 경우
사원번호, 사원이름, 부서이름  
을 출력하는 PL/SQL을 작성하시오.
-> 출력 : SELECT문
입력 : 사원번호 -> 출력 : 사원번호, 사원이름, 부서이름
( 테이블 :  employees / departments )
*/
DECLARE
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_dname departments.department_name%TYPE;
BEGIN
    SELECT e.employee_id, e.last_name, d.department_name
    INTO v_eid, v_ename, v_dname
    FROM employees e
        LEFT JOIN departments d 
        ON (e.department_id = d.department_id)
    WHERE e.employee_id = &사원번호; 

    DBMS_OUTPUT.PUT_LINE('사원번호: ' || v_eid);
    DBMS_OUTPUT.PUT_LINE('사원이름: ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('부서이름:' || v_dname);
END;
/
/*
2.
사원번호를 입력(치환변수사용&)할 경우 
사원이름, 
급여, 
연봉->(급여*12+(nvl(급여,0)*nvl(커미션퍼센트,0)*12))
을 출력하는  PL/SQL을 작성하시오.

-> 출력 : SELECT문
입력 :  사원번호 -> 출력 : 사원이름, 급여, 연봉
연봉 = (급여*12+(nvl(급여,0)*nvl(커미션퍼센트,0)*12))

1) 
SELECT 사원이름 , 급여, (급여*12+(nvl(급여,0)*nvl(커미션퍼센트,0)*12)
FROM employees
WHERE 사원번호
2)
SELECT 사원이름 , 급여, 커미션퍼센트
FROM employees
WHERE 사원번호

연봉 = (급여*12+(nvl(급여,0)*nvl(커미션퍼센트,0)*12)
*/
--첫번째 유형
DECLARE
    v_ename employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    v_annual NUMBER(15, 2);
BEGIN
    SELECT last_name, salary, salary * 12+(NVL(v_salary, 0)*NVL(commission_pct, 0) * 12)
    INTO v_ename, v_salary, v_annual
    FROM employees 
    WHERE employee_id = &사원번호; 

    DBMS_OUTPUT.PUT_LINE('사원이름: ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('급여: ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('연봉:' || v_annual);
END;
/
--두번째 유형
DECLARE
    v_ename employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    v_comm_pct employees.commission_pct%TYPE;
    v_annual NUMBER(10,0);
BEGIN
    SELECT last_name, salary, commission_pct
    INTO v_ename, v_salary, v_comm_pct
    FROM employees 
    WHERE employee_id = &사원번호; 
    v_annual := (v_salary * 12) + (NVL(v_salary, 0) * NVL(v_comm_pct, 0) * 12);

    DBMS_OUTPUT.PUT_LINE('사원이름: ' || v_ename);
    DBMS_OUTPUT.PUT_LINE('급여: ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('연봉:' || v_annual);
END;
/

-- 암시적 커서의 %ROWCOUNT 속성
BEGIN
    DELETE FROM employees
    WHERE employee_id =0;
    
    DBMS_OUTPUT.PUT_LINE('결과 : ' || SQL%ROWCOUNT ||'개 행 이(가) 삭제되었습니다.');
    COMMIT;
END;
/
BEGIN
    DELETE FROM employees
    WHERE employee_id =20121729;
    
    DBMS_OUTPUT.PUT_LINE('결과 : ' || SQL%ROWCOUNT ||'개 행 이(가) 삭제되었습니다.');
    ROLLBACK;
END;
/
/*
  <script>
    let fruits = 'Apple';
    // 한 조건식을 만족하는 경우만
    if (fruites == 'Apple') {
      console.log('사과입니다.');
    }

    // 한 조건식을 기준으로 true/false 전부
    if (fruites == 'Apple') {
      console.log('사과입니다.');
    } else {
      console.log('사과가 아닙니다.');
    }

    // 세부조건을 추가
    if (fruites == 'Apple') {
      console.log('사과입니다.');
    } else if (fruits == 'Banana') {
      console.log('바나나입니다.');
    } else if (fruits == 'Melon') {
      console.log('멜론입니다.');
    } else {
      console.log('사과가 아닙니다.');
    }
  </script>
*/
DECLARE
    v_fruits VARCHAR2(10) := 'Apple';
BEGIN
    -- 한 조건식을 만족하는 경우만 : IF문
    IF v_fruits = 'Apple' THEN
        DBMS_OUTPUT.PUT_LINE('사과입니다');
    END IF;
    
    -- 한 조건식을 기준으로 true/false 전부 :  IF ~ ELSE문
    IF v_fruits = 'Apple' THEN
        DBMS_OUTPUT.PUT_LINE('사과입니다');
    ELSE
        DBMS_OUTPUT.PUT_LINE('사과가 아닙니다');
    END IF;
    -- 세부 조건을 추가  IF ~ ELSIF ~ ELSE문
    IF v_fruits = 'Apple' THEN
        DBMS_OUTPUT.PUT_LINE('사과입니다');
    ELSIF v_fruits = 'Banana' THEN
        DBMS_OUTPUT.PUT_LINE('바나나입니다');
    ELSIF v_fruits = 'Melon' THEN
        DBMS_OUTPUT.PUT_LINE('멜론입니다');
    ELSE
        DBMS_OUTPUT.PUT_LINE('과일이 아닙니다');  
    END IF;
END;


--문법
IF 조건식 THEN
    조건식이 true인 경우 실행코드
ELSIF 추가 조건식1 THEN
    추가 조건식1이 true인 경우 실행코드
ELSIF 추가 조건식2 THEN
    추가 조건식2가 true인 경우 실행코드
ELSE
    위의 모든 조건식들이 false인 경우 실행코드
END IF:
END;
/
DECLARE
    v_score NUMBER(3,0) := &점수;
    v_grade CHAR(1);
BEGIN
    IF v_score >= 90 THEN
        v_grade := 'A';
    ELSIF v_score >= 80 THEN
        v_grade := 'B';
    ELSIF v_score >= 70 THEN
        v_grade := 'C';
    ELSIF v_score >= 60 THEN
        v_grade := 'D';
    ELSE
        v_grade := 'F';
    END IF;
    DBMS_OUTPUT.PUT_LINE(v_grade);
END;
/

DECLARE
    v_new VARCHAR2(20);
    v_hire_date employee.hire_date%TYPE;
BEGIN
    SELECT hire_date
    INTO v_hire_date
    FROM employee
    WHERE employee_id = &사원번호;
    
    IF TO_CHAR(v_hire_date, 'yyyy') >= '2015' THEN
        v_new := 'New employee';
    ELSE
        v_new := 'Career employee';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE(v_new);
END;
/

create table test01(empid, ename, hiredate)
as
  select employee_id, last_name, hire_date
  from   employees
  where  employee_id = 0;

create table test02(empid, ename, hiredate)
as
  select employee_id, last_name, hire_date
  from   employees
  where  employee_id = 0;
  
  
/*
4.
create table test01(empid, ename, hiredate)
as
  select employee_id, last_name, hire_date
  from   employees
  where  employee_id = 0;

create table test02(empid, ename, hiredate)
as
  select employee_id, last_name, hire_date
  from   employees
  where  employee_id = 0;

사원번호를 입력(치환변수사용&)할 경우
사원들 중 2015년 이후(2015년 포함)에 입사한 사원의 사원번호, 
사원이름, 입사일을 test01 테이블에 입력하고, 2015년 이전에 
입사한 사원의 사원번호,사원이름,입사일을 test02 테이블에 입력하시오.
*/  
  
DECLARE
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_hire_date employees.hire_date%TYPE;
BEGIN
    SELECT hire_date, employee_id, last_name
    INTO v_hire_date, v_eid, v_ename
    FROM employee
    WHERE employee_id = &사원번호;
    
    IF TO_CHAR(v_hire_date, 'yyyy') >= '2015' THEN
        INSERT INTO test01
        (empid, ename, hiredate)
        VALUES
        (v_eid, v_ename, v_hire_date);
    ELSE
        INSERT INTO test02
        (empid, ename, hiredate)
        VALUES
        (v_eid, v_ename, v_hire_date);
    END IF;
END;
/

/*
5.
급여가  5000이하이면 20% 인상된 급여
급여가 10000이하이면 15% 인상된 급여
급여가 15000이하이면 10% 인상된 급여
급여가 15001이상이면 급여 인상없음

사원번호를 입력(치환변수)하면 사원이름, 급여, 인상된 급여가 출력되도록 PL/SQL 블록을 생성하시오.
*/

DECLARE
    v_ename employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    SELECT salary, last_name
    INTO v_salary, v_ename
    FROM employees
    WHERE employee_id = &사원번호;
    
    IF v_salary <= 5000 THEN
    DBMS_OUTPUT.PUT_LINE(v_ename||' '||v_salary||' '||v_salary*1.2);
    ELSIF v_salary <= 10000 THEN
    DBMS_OUTPUT.PUT_LINE(v_ename||' '||v_salary||' '||v_salary*1.15);
    ELSIF v_salary <= 15000 THEN
    DBMS_OUTPUT.PUT_LINE(v_ename||' '||v_salary||' '||v_salary*1.1);
    ELSE
    DBMS_OUTPUT.PUT_LINE(v_ename||' '||v_salary||' '||v_salary*1);
    END IF;
END;
/

DECLARE
    v_ename employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    v_raise NUMBER(3,0);
    v_new v_salary%TYPE;
BEGIN
    SELECT salary, last_name
    INTO v_salary, v_ename
    FROM employees
    WHERE employee_id = &사원번호;
    
    IF v_salary <= 5000 THEN
    v_raise := 20;
    ELSIF v_salary <= 10000 THEN
    v_raise := 15;
    ELSIF v_salary <= 15000 THEN
    v_raise := 10;
    ELSE
    v_raise := 0;
    END IF;
    v_new := v_salary + (v_salary*(v_raise / 100));
    DBMS_OUTPUT.PUT_LINE(v_ename||' '||v_salary||' '||v_new);
END;
/

--LOOP 문
-- 1) 기본 LOOP문 : 무조건 반복한다를 전제로 사용
--  사용 문법 : EXIT문을 반드시 포함

BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('Hello!'); --종료안하면 무한반복 후 overflow
        EXIT;
    END LOOP;
END;
/

DECLARE
    v_count NUMBER(1) := 0; -- 반복문을 제어할 변수
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE('Hello!');
        v_count := v_count + 1;
        EXIT WHEN v_count >= 5;
    END LOOP;
END;
/

--1~10합구하기

DECLARE
    v_sum NUMBER(2,0) := 0;
    v_num NUMBER(2,0) := 1;
BEGIN
    LOOP
        v_sum := v_sum + v_num;
        v_num := v_num + 1;
        EXIT WHEN v_num >= 11;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(v_sum);
END;
/

/*

6. 다음과 같이 출력되도록 하시오.
*         
**        
***       
****     
*****    

*/
DECLARE 
    v_count NUMBER(1,0) := 0;
    v_str varchar2(20) := '*****';
BEGIN
    LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(SUBSTR(v_str,1,v_count));
        EXIT WHEN v_count >= 5;
    END LOOP;
END;
/

DECLARE
    v_tree VARCHAR2(6) := '*'; --'*'를 담을 변수
    v_count NUMBER(1,0) := 1; -- LOOP문을 제어할 변수
BEGIN
    LOOP -- 실제 반복 코드
        DBMS_OUTPUT.PUT_LINE(v_tree);
        v_tree := v_tree || '*';
        v_count := v_count + 1;
        EXIT WHEN v_count > 5;
    END LOOP;
END;
/

/*
7. 치환변수(&)를 사용하면 숫자를 입력하면 
해당 구구단이 출력되도록 하시오.
예) 2 입력시 아래와 같이 출력
2 * 1 = 2
2 * 2 = 4
...

*/

DECLARE
    v_num NUMBER(1,0) := &구구단;
    v_count NUMBER(2,0) := 1;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(v_num||'*'||v_count||'='||v_num*v_count);
        v_count := v_count + 1;
    EXIT WHEN v_count >= 10;
    END LOOP;
END;
/

/*
8. 구구단 2~9단까지 출력되도록 하시오.
*/

DECLARE
    v_num NUMBER(2,0) := 2;
    v_count NUMBER(2,0) := 1;
BEGIN
    LOOP
        LOOP
            DBMS_OUTPUT.PUT_LINE(v_num||'*'||v_count||'='||v_num*v_count);
            v_count := v_count + 1;
        EXIT WHEN v_count >= 10;
        END LOOP;
        v_count := 1;
        v_num := v_num + 1;
    EXIT WHEN v_num >= 10;    
    END LOOP;
END;
/

-- FOR LOOP문 : 횟수를 기준으로 반복
-- 문법
FOR 임시변수 IN 최소값 .. 최대값 LOOP
    --임시변수, 최소값, 최대값 전부 정수
    --임시변수는 변경 불가, Read Only
END LOOP;
--예시
BEGIN
    FOR idx IN 1 .. 10 LOOP
        DBMS_OUTPUT.PUT_LINE(idx || ' : Hello !');
    END LOOP;
END;
/

--주의사항 1)
BEGIN
    FOR idx IN -111 .. -107 LOOP
        idx := idx+1; -- 임시변수는 변경불가
        DBMS_OUTPUT.PUT_LINE(idx || ' : Hello !');
    END LOOP;
END;
/

--주의사항 2)
BEGIN
    FOR idx IN 10 .. 1 LOOP -- 최소값이 항상 최대값보다 같거나 커야함
        DBMS_OUTPUT.PUT_LINE(idx);
    END LOOP;
END;
/

BEGIN
    FOR idx IN REVERSE 1 .. 10 LOOP
        DBMS_OUTPUT.PUT_LINE(idx || ' : Hello !');
    END LOOP;
END;
/

DECLARE
    v_sum NUMBER(2,0) := 0; --총합
BEGIN
    FOR num IN REVERSE 1 .. 10 LOOP
        v_sum := v_sum + num;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(v_sum);
END;
/


/*

6. 다음과 같이 출력되도록 하시오.
*         
**        
***       
****     
*****    

*/
DECLARE
    v_star VARCHAR(6) := '*';
BEGIN
    FOR idx IN 1 .. 5 LOOP
        DBMS_OUTPUT.PUT_LINE(v_star);
        v_star := v_star || '*';
    END LOOP;
END;
/

BEGIN
    FOR idx IN 1 .. 5 LOOP
        FOR idx2 IN 1 .. idx LOOP
            DBMS_OUTPUT.PUT('*');
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/

/*
7. 치환변수(&)를 사용하면 숫자를 입력하면 
해당 구구단이 출력되도록 하시오.
예) 2 입력시 아래와 같이 출력
2 * 1 = 2
2 * 2 = 4
...

*/

DECLARE
    v_num NUMBER(1,0) := &구구단;
BEGIN
    FOR idx IN 2 .. 9 LOOP
        DBMS_OUTPUT.PUT_LINE(v_num||'*'||idx||'='||v_num*idx);
    END LOOP;
END;
/

/*
8. 구구단 2~9단까지 출력되도록 하시오.
*/

BEGIN
    FOR idx2 IN 2 .. 9 LOOP
        FOR idx IN 2 .. 9 LOOP
        DBMS_OUTPUT.PUT(idx||'*'||idx2||'='||idx*idx2||' ');
        END LOOP; 
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/

BEGIN
    FOR idx2 IN 1 .. 9 LOOP
        FOR idx IN 1 .. 9 LOOP
            IF MOD(idx,2) = 1 AND MOD(idx2,2) = 1 THEN
                DBMS_OUTPUT.PUT(idx||'*'||idx2||'='||idx*idx2||' ');
            END IF;  
        END LOOP;
        IF MOD(idx2,2) = 1 THEN
            DBMS_OUTPUT.NEW_LINE;
        END IF;
    END LOOP;
END;
/

SELECT last_name
FROM employees
ORDER BY employee_id;

-- 사용방법
DECLARE
    -- 1) RECORD 정의
    TYPE 레코드 타입 이름 IS RECORD
        (필드명1 데이터타입,
         필드명2 데이터타입 NOT NULL DEFAULT 초기값,
         필드명3 데이터타입 := 초기값,
         ... );
    -- 2) 변수 선언
    변수명1 레코드 타입 이름;
    변수명2 레코드 타입 이름;
BEGIN
    -- 3) 실제 사용
    변수명1.필드명1 := 값;
    DBMS_OUTPUT.PUT_LINE(변수명2.필드명1);
END;
/
-- 예시:회원정보(아이디, 이름, 가입일자)를 의미
DECLARE
    -- 1) RECORD 정의
    TYPE user_record_type IS RECORD
        (user_id NUMBER(6,0) := 1,
         user_name VARCHAR2(100) := '익명',
         join_date DATE NOT NULL DEFAULT sysdate);
    -- 2) 변수 선언
    first_user user_record_type;
    new_user   user_record_type;
BEGIN
    -- 3) 실제 사용 : 변수명.필드명
    DBMS_OUTPUT.PUT_LINE(first_user.user_id);
    DBMS_OUTPUT.PUT_LINE(first_user.user_name);
    DBMS_OUTPUT.PUT_LINE(first_user.join_date);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT_LINE(new_user.user_id);
    DBMS_OUTPUT.PUT_LINE(new_user.user_name);
    DBMS_OUTPUT.PUT_LINE(new_user.join_date);
END;
/

-- 특정 사원의 사원번호, 사원이름, 급여 출력
DECLARE
    v_eid employees.employee_id%TYPE,
    v_ename employees.last_name%TYPE,
    v_sal employees.salary%TYPE,
    v_new_eid employees.employee_id%TYPE,
    v_new_ename employees.last_name%TYPE,
    v_new_sal employees.salary%TYPE
BEGIN
    SELECT employee_id, last_name, salary
    INTO v_eid, v_ename, v_sal
    FROM employees
    WHERE empoyee_id = 100;
    
    SELECT employee_id, last_name, salary
    INTO v_new_eid, v_new_ename, v_new_sal
    FROM employees
    WHERE empoyee_id = 200;
END;
/

-- 특정 사원의 사원번호, 사원이름, 급여 출력
DECLARE
    -- 1) 정의
    TYPE emp_record_type IS RECORD
        (empno NUMBER(6,0),
        ename employees.last_name%TYPE,
        sal employees.salary%TYPE := 0);
        
    -- 2) 변수 선언
    v_emp_info emp_record_type;
    v_emp_rec emp_record_type;
BEGIN
    SELECT employee_id, last_name, salary
    INTO v_emp_info
    FROM employees
    WHERE employee_id = 100;
    
    SELECT employee_id, last_name, salary
    INTO v_emp_rec
    FROM employees
    WHERE employee_id = 200;
    
    DBMS_OUTPUT.PUT_LINE(v_emp_info.empno||' '||v_emp_info.ename||' '||v_emp_info.sal||' '||v_emp_rec.empno||' '||v_emp_rec.ename||' '||v_emp_rec.sal);
END;
/

-- %ROWTYPE : 단일 테이블을 기준으로 할 때 편함
DECLARE
    -- 1) RECORD 정의 => 생략
    -- 2) 변수선언
    v_emp_info employees%ROWTYPE;
BEGIN
    SELECT *
    INTO v_emp_info
    FROM employees
    Where employee_id = 100;
    
    -- 3) 변수 사용 : 변수명.컬럼명;
    DBMS_OUTPUT.PUT_LINE(v_emp_info.employee_id);
    DBMS_OUTPUT.PUT_LINE(v_emp_info.last_name);
    DBMS_OUTPUT.PUT_LINE(v_emp_info.salary);
END;
/

-- 명시적 커서 : 다중 행 SELECT문을 사용
SELECT employee_id, last_name, hire_date
FROM employees
WHERE department_id = &부서번호;

--예시
DECLARE
    -- 1) 커서 선언(정의)
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, hire_date
        FROM employees
        WHERE department_id = &부서번호;
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_hdate employees.hire_date%TYPE;
BEGIN
    -- 2) 커서 실행
    OPEN emp_cursor;
    -- 3) 데이터 확인 및 반환
    LOOP
        FETCH emp_cursor INTO v_eid, v_ename, v_hdate;
        EXIT WHEN emp_cursor%NOTFOUND;
        -- 1. LOOP문 안에서 ROWCOUT->현재 가지고 온 행의 수, 유동적
        DBMS_OUTPUT.PUT_LINE(emp_cursor%ROWCOUNT||': '||v_eid||' '||v_ename||' '||v_hdate);
    END LOOP; -- 커서의 모든 데이터를 인출했을 때
    -- 4) 커서 종료
    -- 2. LOOP문 바깥에서 ROWCOUNT->커서가 가진 총 행의 수, 고정적
    DBMS_OUTPUT.PUT_LINE(emp_cursor%ROWCOUNT||': '||v_eid||' '||v_ename||' '||v_hdate);
    CLOSE emp_cursor;
END;
/

-- 커서 FOR LOOP (더 간결한 문법)
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, salary
        FROM employees
        WHERE department_id = 50;
BEGIN
    -- 자동으로 OPEN, FETCH, CLOSE 처리해줌! (개꿀!)
    FOR emp_rec IN emp_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id || ' - ' || 
                             emp_rec.last_name || ' - $' || 
                             emp_rec.salary);
    END LOOP;
    -- 자동으로 CLOSE 됨!
END;
/

DECLARE
    --1) 커서 정의
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, hire_date
        FROM employees
        WHERE department_id = &부서번호;
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_hdate employees.hire_date%TYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        --3)데이터 확인 및 반환
        FETCH emp_cursor INTO v_eid, v_ename, v_hdate;
        EXIT WHEN emp_cursor%NOTFOUND;
        --새로운 데이터가 있는 경우 진행할 작업
        DBMS_OUTPUT.PUT_LINE(emp_cursor%ROWCOUNT||': '||v_eid||' '||v_ename||' '||v_hdate);
        -- 커서명%ROWCOUNT : 현재 몇번째 행, 유동값
    END LOOP;
    -- 4) 커서 종료
    CLOSE emp_cursor;
END;
/

DECLARE
    --1) 커서 정의
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, hire_date
        FROM employees
        WHERE job_id LIKE UPPER('&업무')||'%';
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_hdate employees.hire_date%TYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        --3)데이터 확인 및 반환
        FETCH emp_cursor INTO v_eid, v_ename, v_hdate;
        EXIT WHEN emp_cursor%NOTFOUND;
        --새로운 데이터가 있는 경우 진행할 작업
        DBMS_OUTPUT.PUT_LINE(v_eid||' '||v_ename||' '||v_hdate);
        -- 커서명%ROWCOUNT : 현재 몇번째 행, 유동값
    END LOOP;
    IF emp_cursor%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('해당 사원이 없습니다.');
    -- 4) 커서 종료
    END IF;
    CLOSE emp_cursor;
END;
/