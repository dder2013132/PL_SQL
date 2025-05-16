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


/*
1.
사원(employees) 테이블에서
사원의 사원번호, 사원이름, 입사연도를 
다음 기준에 맞게 각각 test01, test02에 입력하시오.

입사년도가 2005년(포함) 이전 입사한 사원은 test01 테이블에 입력
입사년도가 2005년 이후 입사한 사원은 test02 테이블에 입력
*/

DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id,last_name,hire_date
        FROM employees;
    v_eid employees.employee_id%TYPE;
    v_ename employees.last_name%TYPE;
    v_hdate employees.hire_date%TYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_eid, v_ename, v_hdate;
        IF TO_CHAR(v_hdate, 'yyyy') <= '2005' THEN
            INSERT INTO test01
            (empid, ename, hiredate)
            VALUES
            (v_eid, v_ename, v_hdate);
        ELSE
            INSERT INTO test02
            (empid, ename, hiredate)
            VALUES
            (v_eid, v_ename, v_hdate);
        END IF;
        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;
    CLOSE emp_cursor;
END;
/

/*
2.
부서번호를 입력할 경우(&치환변수 사용)
해당하는 부서의 사원이름, 입사일자, 부서명을 출력하시오.
*/

DECLARE
    CURSOR emp_cursor IS
        SELECT last_name,hire_date,job_id
        FROM employees
        WHERE department_id = &부서번호;
    v_eid employees.last_name%TYPE;
    v_ename employees.hire_date%TYPE;
    v_hdate employees.job_id%TYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_eid, v_ename, v_hdate;
        EXIT WHEN emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_eid||' '||v_ename||' '||v_hdate);
    END LOOP;
    CLOSE emp_cursor;
END;
/
/*
3.
부서번호를 입력(&사용)할 경우 
사원이름, 급여, 연봉->(급여*12+(급여*nvl(커미션퍼센트,0)*12))
을 출력하는  PL/SQL을 작성하시오.
*/

DECLARE
    CURSOR emp_cursor IS
        SELECT last_name,salary,commission_pct
        FROM employees
        WHERE department_id = &부서번호;
    v_ename employees.last_name%TYPE;
    v_salary employees.salary%TYPE;
    v_cpct employees.commission_pct%TYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_ename,v_salary,v_cpct;
        DBMS_OUTPUT.PUT_LINE('연봉->'||' '||(v_salary*12+(v_salary*nvl(v_cpct,0)*12)));
        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;
    CLOSE emp_cursor;
END;
/

DECLARE
    CURSOR emp_cursor IS
        SELECT last_name,salary,commission_pct
        FROM employees
        WHERE department_id = &부서번호;
    v_emp_info emp_cursor%ROWTYPE;
    v_annual NUMBER(15, 2);
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_emp_info;
        v_annual := (v_emp_info.salary*12+(v_emp_info.salary*nvl(v_emp_info.commission_pct,0)*12));
        DBMS_OUTPUT.PUT_LINE('연봉->'||' '||v_annual);
        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;
    CLOSE emp_cursor;
END;
/

DECLARE
    CURSOR emp_cursor IS
        SELECT salary*12+(salary*nvl(commission_pct,0)*12) AS ann
        FROM employees
        WHERE department_id = &부서번호;
    v_emp_info emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_emp_info;
        DBMS_OUTPUT.PUT_LINE('연봉->'||' '||v_emp_info.ann);
        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;
    CLOSE emp_cursor;
END;
/

--커서 FOR LOOP : 명시적 커서 단축방법
SELECT employee_id, last_name, hire_date
FROM employees
WHERE department_id = &부서번호;

DECLARE
    --커서 정의
    CURSOR emp_cursor IS
        SELECT employee_id, last_name, hire_date
        FROM employees
        WHERE department_id = &부서번호;
BEGIN
    -- 명령어 사용 VS 커서 FOR LOOP
    FOR emp_rec IN emp_cursor LOOP -- 암묵적으로 OPEN, FETCH
        -- 데이터가 존재하는 경우
        -- 명시적 커서의 속성에 접근 가능
        DBMS_OUTPUT.PUT(emp_cursor%ROWCOUNT || ' : ');
        DBMS_OUTPUT.PUT(emp_rec.employee_id|| ', ');
        DBMS_OUTPUT.PUT(emp_rec.last_name|| ', ');
        DBMS_OUTPUT.PUT(emp_rec.hire_date);
        DBMS_OUTPUT.NEW_LINE;
    END LOOP; -- 암묵적으로 CLOSE
    --DBMS_OUTPUT.PUT_LINE(emp_cursor%ROWCOUNT);
    CLOSE emp_cursor;
END;
/

--사용방법 정리
DECLARE
    -- 1) 커서 정의
    CURSOR 커서명 IS
        커서가 실행할 SELECT문;
BEGIN
    -- 2) 커서 실행
    -- 3) 데이터 확인 및 반환
    FOR 임시변수(레코드타입) IN 커서명 LOOP
        -- 데이터가 존재하는 경우에만 실행
        -- => 커서 FOR LOOP는 반드시 데이터가 있는 경우만
        -- 명시적 커서의 속성에 접근 가능
    END LOOP; -- 4) 커서 종료
END;
/

DECLARE
    CURSOR emp_cursor IS
        SELECT last_name,hire_date,job_id
        FROM employees
        WHERE department_id = &부서번호;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        DBMS_OUTPUT.PUT_LINE(emp_rec.last_name||' '||emp_rec.hire_date||' '||emp_rec.job_id);
    END LOOP;
END;
/

--예외처리
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
    INTO v_ename
    FROM employees
    WHERE employees_id = &사원번호;
    DBMS_OUTPUT.PUT_LINE(v_ename);
END;
/

--문법
DECLARE
    -- 변수, 커서, 레코드 타입 등 선언부
BEGIN
    -- 실행
EXCEPTION
    -- 예외처리
    WHEN 예외이름1 THEN
        예외가 발생했을 때 실행할 코드;
    WHEN 예외이름2 THEN
        예외가 발생했을 때 실행할 코드;
    WHEN OTHERS THEN
        위에 선언되지 않은 예외가 발생한 경우 실행할 코드;
END;
/
-- 1) 예외유형 : 이미 정의되어 있고 이름도 존재하는 예외사항
-- 1. 이미 정의되어 있고 이름도 있는 예외
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
    INTO   v_ename
    FROM   employees
    WHERE  department_id = &부서번호;
    
    -- 부서번호 10 : 정상 실행
    -- 부서번호 50 : TOO_MANY_ROWS / ORA-01422
    -- 부서번호  0 : NO_DATA_FOUND / ORA-01403
    DBMS_OUTPUT.PUT_LINE(v_ename);
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE('여러 행이 반환되었습니다');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('기타 예외가 반환되었습니다');
END;
/
-- 2) 예외유형 : 이미 정의는 되어있지만 이름이 존재하지 않는 예외 
DECLARE
    -- 2-1) 예외이름 선언
    e_emps_remaining EXCEPTION;
    -- 2-2) 예외이름과 에러코드 연결
    RPAGMA EXCEPTION_INIT(e_emps_remaining,-02292);
BEGIN
    DELETE FROM departments
    WHERE department_id = &부서번호;
EXCEPTION
    WHEN e_emps_remaining THEN
        DBMS_OUTPUT.PUT_LINE('참조 데이터가 있습니다.');
END;
/
--3)
DECLARE
    e_dept_del_fail EXCEPTION;
BEGIN
    DELETE FROM departments
    WHERE department_id = 0;
    -- 3-2) 예외가 되는 상황을 설정
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_dept_del_fail;
    END IF;
    DBMS_OUTPUT.PUT_LINE('정상적으로 삭제되었습니다.');
EXCEPTION
    WHEN e_dept_del_fail THEN
        DBMS_OUTPUT.PUT_LINE('해당 부서는 존재하지 않습니다.');
        DBMS_OUTPUT.PUT_LINE('부서번호를 확인해주세요.');
END;
/

-- 1) 예외유형 : 이미 정의되어 있고 이름도 존재하는 예외사항
-- 예시
DECLARE
    v_ename employees.last_name%TYPE;
BEGIN
    SELECT last_name
    INTO   v_ename
    FROM   employees
    WHERE  department_id = &부서번호;
    -- 부서번호 10 : 정상실행
    -- 부서번호 50 : TOO_MANY_ROWS / ORA-01422
    -- 부서번호 0  : NO_DATA_FOUND / ORA-01403
    DBMS_OUTPUT.PUT_LINE(v_ename);
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('여러 행이 반환됐습니다');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('기타 예외 발생');
        DBMS_OUTPUT.PUT_LINE('ORA-' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

/*
1.
drop table emp_test;

create table emp_test
as
  select employee_id, last_name
  from   employees
  where  employee_id < 200;

emp_test 테이블에서 사원번호를 사용(&치환변수 사용)하여 
사원을 삭제하는 PL/SQL을 작성하시오.
(단, 사용자 정의 예외사항 사용)
(단, 사원이 없으면 "해당사원이 없습니다.'라는 오류메시지 발생)
*/

drop table emp_test;

create table emp_test
as
  select employee_id, last_name
  from   employees
  where  employee_id < 200;
  
INSERT INTO emp_test(
    employee_id,
    last_name)
VALUES(
    22,
    'last');
  
/*
emp_test 테이블에서 사원번호를 사용(&치환변수 사용)하여 
사원을 삭제하는 PL/SQL을 작성하시오.
(단, 사용자 정의 예외사항 사용)
(단, 사원이 없으면 "해당사원이 없습니다.'라는 오류메시지 발생)
*/
DECLARE
    e_emp_del_fail EXCEPTION;
BEGIN
    DELETE FROM emp_test
    WHERE employee_id = &사원번호;
    -- 3-2) 예외가 되는 상황을 설정
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_emp_del_fail;
    END IF;
    DBMS_OUTPUT.PUT_LINE('정상적으로 삭제되었습니다.');
EXCEPTION
    WHEN e_emp_del_fail THEN
        DBMS_OUTPUT.PUT_LINE('해당사원이 없습니다.');
END;
/

-- PROCEDURE : 독립된 기능을 구현하는 PL/SQL의 객체 중 하나
CREATE PROCEDURE test_pro_01 (p_msg IN VARCHAR2)
-- 매개변수로 선언할 경우 데이터 타입의 크기는 지정하지 않음
IS
    -- 선언부 : 변수, 커서, 예외 등
    v_msg VARCHAR2(1000) := 'Hello! ';
BEGIN
    -- 실행
    DBMS_OUTPUT.PUT_LINE(v_msg || p_msg);
    EXCEPTION
    -- 예외처리
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('데이터가 존재하지 않습니다.');
END;
/

--실행
BEGIN
    test_pro_01('hihi');
END;
/

--실행
DECLARE
    v_result VARCHAR2(1000);
BEGIN
    -- v_result := test_pro_01('hihi2');
    -- 오라클은 프로시저와 함수를 호출하는 방식으로 구분
    -- => 프로시저를 호출할 때 왼쪽에 변수가 존재하면 안됨.
    -- 프로시저는 함수처럼 값을 반환해서 
    -- 변수에 할당하는 방식으로 호출할 수 없다는 뜻 
    test_pro_01('hihi2');
END;
/

EXECUTE test_pro_01('hihi3');

DROP PROCEDURE test_pro_01;


-- IN 모드 : 호출환경 -> 프로시저
-- IN 모드 : 호출환경 -> 프로시저
drop PROCEDURE raise_salary;
CREATE PROCEDURE raise_salary
(p_eid IN employees.employee_id%TYPE)
IS

BEGIN
    -- IN모드 : 상수로 인식
    -- p_eid := NVL(p_eid, 100);
    
    UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = p_eid;
END;
/

DECLARE
    v_first NUMBER(3,0) := 100;
BEGIN
    raise_salary(149);          --리터럴
    raise_salary(2 * v_first);  --표현식(계산식)
    raise_salary(v_first);      --값을 가진 변수
END;
/

SELECT employee_id, salary
FROM employees
WHERE employee_id IN (100, 149, 200);

-- OUT 모드 : 프로시저 -> 호출환경
-- 1) 매개변수로 전달되는 것이 있어도 무조건 null로 값을 가짐
-- 2) OUT 모드의 매개변수가 가진 최종 값을 호출환경으로 반환
CREATE PROCEDURE test_p_out
(p_num IN NUMBER,
 p_out OUT NUMBER)
 IS

BEGIN
    DBMS_OUTPUT.PUT_LINE('IN : ' || p_num);
    DBMS_OUTPUT.PUT_LINE('OUT : ' || p_out);
END;
/

DECLARE
    v_result NUMBER(4,0) := 1234;
BEGIN
    DBMS_OUTPUT.PUT_LINE('1) result : ' || v_result);
    test_p_out(1000,v_result);
    DBMS_OUTPUT.PUT_LINE('2) result : ' || v_result);
END;
/

-- 더하기
CREATE PROCEDURE plus
(p_x IN NUMBER, 
 p_y IN NUMBER,
 p_result OUT NUMBER)
IS

BEGIN
    -- return ( x + y ); -> 함수방식
    p_result := (p_x + p_y);
END;
/

DECLARE
    v_total NUMBER(10,0);
BEGIN
    plus(10, 25, v_total);
    DBMS_OUTPUT.PUT_LINE(v_total);
END;
/
drop procedure format_phone;
-- IN OUT 모드 : 호출환경 <-> 프로시저
-- '01012341234' => '010-1234-1234'
CREATE OR REPLACE PROCEDURE format_phone
(p_phone_no IN OUT VARCHAR2)
IS
BEGIN
    -- 1) OUT 모드와 달리 호출환경에서 전달받은 값을 가질 수 있음
    DBMS_OUTPUT.PUT_LINE('before : ' || p_phone_no);
    -- 2) IN 모드와 달리 값을 변경할 수 있음
    p_phone_no := SUBSTR(p_phone_no, 1, 3)
                || '-' || SUBSTR(p_phone_no, 4, 4)
                || '-' || SUBSTR(p_phone_no, 8);
    -- 3) OUT 모드처럼 최종 값을 호출환경으로 반환
    DBMS_OUTPUT.PUT_LINE('after : ' || p_phone_no);
END;
/

DECLARE
    v_no VARCHAR2(100) := '01012341234';
BEGIN
    format_phone(v_no);
    DBMS_OUTPUT.PUT_LINE(v_no);
END;
/

/*
1.
주민등록번호를 입력하면 
다음과 같이 출력되도록 yedam_ju 프로시저를 작성하시오.

EXECUTE yedam_ju('9501011667777');
950101-1******
EXECUTE yedam_ju('1511013689977');
151101-3******

*/

CREATE PROCEDURE pnum
(p_id IN VARCHAR2);
IS
    v_result VARCHAR2(20);
BEGIN
    v_result := SUBSTR(p_id, 1, 6) 
    --|| '-' || SUBSTR(p_id, 7, 1) || '******';
    || '-' || RPAD(SUBSTR(p_id, 7, 1), 7, '*');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

SELECT last_name
    ,RPAD(last_name,10,'-')
    ,LPAD(last_name,10,'-')
FROM employees;

/*
2.
다음과 같이 PL/SQL 블록을 실행할 경우 
사원번호를 입력할 경우 사원의 이름(last_name)의 첫번째 글자를 제외하고는
'*'가 출력되도록 yedam_emp 프로시저를 생성하시오.

실행) EXECUTE yedam_emp(176);
실행결과) TAYLOR -> T*****  <- 이름 크기만큼 별표(*) 출력
*/

CREATE PROCEDURE yedam_emp
(p_id IN employees.employee_id%TYPE)
IS
  v_masked_name VARCHAR2(100);
BEGIN
    SELECT RPAD(SUBSTR(last_name, 1, 1), LENGTH(last_name)-1, '*')
    INTO v_masked_name
    FROM employees
    WHERE employee_id = p_id;
    DBMS_OUTPUT.PUT_LINE(v_masked_name);
END;
/
drop procedure yedam_emp;
EXECUTE yedam_emp(176);

/*
3.
부서번호를 입력할 경우 
해당부서에 근무하는 사원의 사원번호, 사원이름(last_name), 
연차를 출력하는 get_emp 프로시저를 생성하시오. 
(cursor 사용해야 함)
단, 사원이 없을 경우 "해당 부서에는 사원이 없습니다."라고 
출력(exception 사용)
실행) EXECUTE get_emp(30);
*/

CREATE PROCEDURE get_emp
    (d_id IN employees.hire_date%TYPE)
IS
    v_date NUMBER(20);
    v_months NUMBER(20);
BEGIN
    v_date := TRUNC(MONTHS_BETWEEN(SYSDATE, d_id) / 12);
    v_months := FLOOR(MOD(MONTHS_BETWEEN(sysdate, d_id),12));
    DBMS_OUTPUT.PUT(v_date||'년 '||v_months||'개월');
    DBMS_OUTPUT.NEW_LINE;
END;
/
drop procedure get_emp;

DECLARE
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
        FETCH emp_cursor INTO v_eid, v_ename, v_hdate;
        EXIT WHEN emp_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT(v_eid||' '||v_ename||' ');
        get_emp(v_hdate);
    END LOOP;
    IF emp_cursor%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('해당 부서에는 사원이 없습니다.');
    CLOSE emp_cursor;
    END IF;
END;
/

/*
4.
직원들의 사번, 급여 증가치만 입력하면 
Employees테이블에 쉽게 사원의 급여를 갱신할 수 있는 
y_update 프로시저를 작성하세요. 
만약 입력한 사원이 없는 경우에는 ‘No search employee!!’라는 
메시지를 출력하세요.(예외처리)
실행) EXECUTE y_update(200, 10);
*/

CREATE PROCEDURE y_update
    (d_id IN employees.employee_id%TYPE,
     d_inc IN NUMBER)
IS
BEGIN
    UPDATE employees
    SET salary = salary + (salary * (d_inc/100))
    WHERE employee_id = d_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_emp;
    END IF;
EXCEPTION
    WHEN e_no_emp THEN
        DBMS_OUTPUT.PUT_LINE('No search employee!!');
END;
/

drop procedure y_update;

EXECUTE y_update(104,10);

-- FUNCTION : 독립된 기능을 구현하는 PL/SQL의 객체 중 하나, 계산용
CREATE FUNCTION test_func
(p_msg VARCHAR2)
RETURN VARCHAR2
IS
    -- 선언부 : 변수, 커서, 타입, 예외 등 선언
    v_msg VARCHAR2(1000) := 'Hello!';
BEGIN
    -- 실행
    -- DBMS_OUTPUT.PUT_LINE(v_msg || p_msg);
    RETURN (v_msg || p_msg);
EXCEPTION
    -- 예외철
    WHEN NO_DATA_FOUND THEN
        RETURN '데이터가 존재하지 않습니다.';
END;
/

-- 실행 방법
DECLARE
    v_result VARCHAR2(1000);
BEGIN
    v_result := test_func('PL/SQL');
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

SELECT test_func('PL/SQL')
FROM dual;

CREATE FUNCTION plus_func
(p_x IN NUMBER,
p_y IN NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN (p_x + p_y);
END;
/

-- 내부 DML 없음 + RETURN 숫자 => SQL문에서 사용가능
SELECT plus_func(20,15)
FROM employees;

-- 해당 사원의 직속상사 이름을 출력 => 함수
SELECT e2.last_name
FROM employees e1 
JOIN employees e2 
ON e1.manager_id = e2.employee_id
WHERE e1.employee_id = 101;

CREATE FUNCTION find_it
(p_eid IN employees.employee_id%TYPE)
RETURN VARCHAR2
IS
    m_name employees.last_name%TYPE;
BEGIN
    SELECT e2.last_name
    INTO m_name
    FROM employees e1 
        JOIN employees e2 
        ON e1.manager_id = e2.employee_id
    WHERE e1.employee_id = p_eid;
    RETURN m_name;
END;
/

drop function find_it;

SELECT employee_id
      ,last_name
      ,find_it(employee_id) e2
FROM employees;


/*
1.
사원번호를 입력하면 
last_name + first_name 이 출력되는 
y_yedam 함수를 생성하시오.

실행) EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174))
출력 예)  Abel Ellen

SELECT employee_id, y_yedam(employee_id)
FROM   employees;
*/

CREATE FUNCTION y_yedam
(p_eid IN employees.employee_id%TYPE)
RETURN VARCHAR2
IS
    m_fname employees.last_name%TYPE;
    m_lname employees.last_name%TYPE;
    m_full employees.last_name%TYPE;
BEGIN
    SELECT first_name, last_name
    INTO m_fname, m_lname
    FROM employees
    WHERE employee_id = p_eid;
    
    m_full := m_lname||' '||m_fname;
    RETURN m_full;
END;
/
drop function y_yedam;
EXECUTE DBMS_OUTPUT.PUT_LINE(y_yedam(174));

SELECT employee_id, y_yedam(employee_id)
FROM   employees;

/*
2.
사원번호를 입력할 경우 다음 조건을 만족하는 결과가 출력되는 ydinc 함수를 생성하시오.
- 급여가 5000 이하이면 20% 인상된 급여 출력
- 급여가 10000 이하이면 15% 인상된 급여 출력
- 급여가 20000 이하이면 10% 인상된 급여 출력
- 급여가 20000 초과이면 급여 그대로 출력
실행) SELECT last_name, salary, YDINC(employee_id)
     FROM   employees; 
*/

CREATE FUNCTION ydinc
(p_eid IN employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_salary employees.salary%TYPE;
    v_new employees.salary%TYPE;
BEGIN
    SELECT salary
    INTO v_salary
    FROM employees
    WHERE employee_id = p_eid;
    
    IF v_salary <= 5000 THEN
    v_new := v_salary*1.2;
    ELSIF v_salary <= 10000 THEN
    v_new := v_salary*1.15;
    ELSIF v_salary <= 20000 THEN
    v_new := v_salary*1.1;
    ELSE
    v_new := v_salary*1;
    END IF;
    
    RETURN v_new;
END;
/
drop function ydinc;

SELECT last_name, salary, YDINC(employee_id)
FROM   employees;

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
    
CREATE FUNCTION ydinc2
(p_eid IN employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_salary employees.salary%TYPE;
    v_raise NUMBER(10);
    v_new employees.salary%TYPE;
BEGIN
    SELECT salary
    INTO v_salary
    FROM employees
    WHERE employee_id = p_eid;
    
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
    
    RETURN v_new;
END;
/
drop function ydinc2;

SELECT last_name, salary, YDINC2(employee_id)
FROM   employees;

-- 2번
DECLARE
    v_dptn departments.department_name%TYPE;
    v_jid employees.job_id%TYPE;
    v_sal employees.salary%TYPE;
BEGIN
    SELECT d.department_name,
           e.job_id,
           NVL(e.salary*12, 0)
    INTO v_dptn, v_jid, v_sal
    FROM employee e 
    LEFT JOIN departments d
    ON e.department_id = d.department_id
    WHERE e.employee_id = &사원번호;
    DBMS_OUTPUT.PUT('부서이름: '||v_dptn||' 업무명: '||v_jid||' 연간 총수입: '||v_sal);
    DBMS_OUTPUT.NEW_LINE;
END;
/

-- 3번
DECLARE
    v_str VARCHAR2(20);
    v_hdate employee.hire_date%TYPE;
BEGIN
    SELECT hire_date
    INTO v_hdate
    FROM employees
    WHERE employee_id = &사원번호;
    
    IF TO_CHAR(v_hdate, 'yyyy') >= '2005' THEN
        v_str := 'New employee';
    ELSE
        v_str := 'Career employee';
    END IF;
    DBMS_OUTPUT.PUT_LINE(v_str);
END;
/

-- 4번
BEGIN
    FOR idx2 IN 1 .. 9 LOOP
        FOR idx IN 1 .. 9 LOOP
            IF MOD(idx,2) != 0 THEN
                DBMS_OUTPUT.PUT(idx||'*'||idx2||'='||idx*idx2||' ');
            END IF;  
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END LOOP;
END;
/

-- 5번
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id,
           last_name,
           salary
           FROM employees
           WHERE department_id = &부서번호;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('사번: '||emp_rec.employee_id||' 이름: '||emp_rec.last_name||' 급여: '||emp_rec.salary);
    END LOOP;
END;
/

-- 6번
CREATE PROCEDURE update_sal
(p_id employees.salary%TYPE,
 p_new NUMBER)
IS
no_result EXCEPTION;
BEGIN
    UPDATE employees
    SET salary = salary + (salary*(p_new/100))
    WHERE employee_id = p_id;
    
    IF SQL%ROWCOUNT = 0 THEN
    RAISE no_result;
    END IF;
    EXCEPTION
        WHEN no_result THEN
        DBMS_OUTPUT.PUT_LINE('No search employee!!');
END;
/

-- 7번
CREATE PROCEDURE pnum
(p_id IN VARCHAR2)
IS
    v_fid DATE;
    v_chkmf VARCHAR2(20);
    v_chkage VARCHAR2(20);
BEGIN
    v_fid := SUBSTR(p_id, 1, 6);
    v_chkmf := SUBSTR(p_id, 7, 1);
    IF MOD(SUBSTR(p_id, 7, 1), 2) = 0 THEN
        IF v_chkmf = 2 THEN
           v_fid := '19'||v_fid;       
        ELSE
           v_fid := '20'||v_fid;
        END IF;
    v_chkage := TRUNC(MONTHS_BETWEEN(TRUNC(sysdate), v_fid)/12);
    DBMS_OUTPUT.PUT('만 '||v_chkage||'세'||' 성별: '||'여성');
    ELSE
        IF v_chkmf = 1 THEN
           v_fid := '19'||v_fid;       
        ELSE
           v_fid := '20'||v_fid;
        END IF;
    v_chkage := TRUNC(MONTHS_BETWEEN(TRUNC(sysdate), v_fid)/12);
    DBMS_OUTPUT.PUT('만 '||v_chkage||'세'||' 성별: '||'남성');
    END IF;
    DBMS_OUTPUT.NEW_LINE;
END;
/

-- 8번
CREATE FUNCTION prntyear
(p_id NUMBER)
RETURN NUMBER
IS
    v_hdate NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12)
    INTO v_hdate
    FROM employees
    WHERE employee_id = p_id;
    RETURN v_hdate;
END;
/

-- 9번
CREATE FUNCTION prntmgr
(d_nm departments.department_name%TYPE)
RETURN VARCHAR2
IS
    v_mgrname VARCHAR2(30);
BEGIN
    SELECT last_name
    INTO v_mgrname
    FROM employees
    WHERE employee_id = (SELECT manager_id
                          FROM departments
                          WHERE department_name = d_nm);
    RETURN v_mgrname;
END;
/

-- 10번
SELECT name, text
FROM user_source
WHERE type
IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY');

-- 11번
DECLARE 
    v_count NUMBER(1,0) := 0;
    v_str varchar2(20) := '**********';
BEGIN
    LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(LPAD(SUBSTR(v_str,1,v_count),10,'-'));
        EXIT WHEN v_count >= 9;
    END LOOP;
END;
/
