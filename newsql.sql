select e.employee_id,
       d.department_name,
       e.last_name,
       e.email
from   departments d
join   employees e on d.department_id = e.department_id
where  d.department_id = 110;


SET SERVEROUTPUT ON;
DECLARE
-- 선언부 : 변수 등을 선언하는 영역 => 선택;;
    v_ename employees.last_name%TYPE;
BEGIN
-- 실행부 : 기능을 수행하는 영역 => 필수
    SELECT last_name
    INTO v_ename
    FROM employees
    WHERE employee_id = 100;
    --where
--EXCEPTION
-- 예외처리 : PL/SQL 블록을 실행할 때 발생하는 예외처리 => 선택
-- 이름 [상수] 데이터타입 [NOT NULL] [ := | DEFAULT 표현식]
-- identifier[constant] datatype[not null] [:= | DEFAULT 표현식]
    DBMS_OUTPUT.PUT_LINE(v_ename);
END;
/


DECLARE
    v_str VARCHAR2(100);
    v_num CONSTANT NUMBER(2,0) NOT NULL DEFAULT 10;
    v_count NUMBER(1,0) NOT NULL DEFAULT 5;
    v_sum NUMBER(3,0) := ( v_num + v_count );
BEGIN
    --COSNTANT ) 상수로 선언한 변수의 값을 변경할 경우
    --v_num := 100;
    v_count := 9;
    DBMS_OUTPUT.PUT_LINE(v_count);
    --v_count := NULL;
    --v_sum := v_num + 1234;
    DBMS_OUTPUT.PUT_LINE('v_str : ' || v_str);
    DBMS_OUTPUT.PUT_LINE('v_num : ' || v_num);
    DBMS_OUTPUT.PUT_LINE('v_sum : ' || v_sum);

END;
/