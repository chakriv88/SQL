select * from employees;

select * from(
select employee_id, extract(year from hire_date) as hire_date from employees
)
pivot (
count(*) for hire_date in (2002, 2003, 2004)
)
order by employee_id;

create table numberr (
num number(4,5)
);

insert into numberr values (0.4564991);
insert into numberr values (0.04564991);

select * from numberr;

CREATE TABLE test (col1 NUMBER(5,2), col2 FLOAT(5));

INSERT INTO test VALUES (1.23, 1.23);
INSERT INTO test VALUES (7.89, 7.89);
INSERT INTO test VALUES (12.79, 12.79);
INSERT INTO test VALUES (123.45, 123.45);
INSERT INTO test VALUES (123.456, 123.45);
INSERT INTO test VALUES (12345, 123.45);
INSERT INTO test VALUES (999, 123.45);

SELECT * FROM test;
--In this example, the FLOAT value returned cannot exceed 5 binary digits. The largest decimal number that can be represented by 5 binary digits is 31. 
--The last row contains decimal values that exceed 31. Therefore, the FLOAT value must be truncated so that its significant digits do not require more than 5
--binary digits. Thus 123.45 is rounded to 120, which has only two significant decimal digits, requiring only 4 binary digits.

select * from employees;

select lastname,
extract(year from (sysdate - hiredate) year to month) || ' years ' || extract(month from (sysdate - hiredate) year to month) || ' months' "Interval"
from employees;

select lastname,
extract(day from (sysdate - hiredate) day to second) || ' days ' || extract(hour from (sysdate - hiredate) day to second) || ' hours' "Interval"
from employees;

select rowid, rownum, lastname from employees;


--IMPLICIT Data conversions--
--The text literal '10' has data type CHAR. Oracle implicitly converts it to the NUMBER data type if it appears in a numeric expression as in the following statement:

SELECT salary, salary + '10'
  FROM employees;
  
--When a condition compares a character value and a NUMBER value, Oracle implicitly converts the character value to a NUMBER value, 
--rather than converting the NUMBER value to a character value. In the following statement, Oracle implicitly converts '200' to 200:

SELECT lastname
  FROM employees
  WHERE employeeid = '2';
  
--In the following statement, Oracle implicitly converts '24-JUN-06' to a DATE value using the default date format 'DD-MON-YY':

SELECT last_name
  FROM employees 
  WHERE hire_date = '24-JUN-06';
  
select 'name''s' as name from dual;

--Here are some valid text literals using the alternative quoting mechanism:

select q'!name LIKE '%DBMS_%%'!' from dual;
select q'<'So,' she said, 'It's finished.'>' from dual;
select q'{SELECT * FROM employees WHERE last_name = 'Smith';}' from dual;
select nq'ï Ÿ1234 ï' from dual;
select q'"name" like '['"' from dual; --select q'"name"' like '['"' from dual; this is not correct since (quote_delimiter)" is immerdiately followed by '

SELECT 2 * 1.23, 3 * '2,34' FROM DUAL; --When converting char type to number, error occurs because of comma in 2,34

ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';

SELECT 2 * 1.23, 3 * '2,34' FROM DUAL;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';

SELECT 2 * 1.23, 3 * '2.34' FROM DUAL;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';

SELECT 2 * 1.23, 3 * '2.34' FROM DUAL; --When converting char type to number, error occurs because of . in 2.34

SELECT 2 * 1,23 FROM DUAL;

SELECT 2 * '1,23' FROM DUAL;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS='.,';

--Here are some valid NUMBER literals:

select 25,+6.34,0.5,25e-03,-1 from dual;

--Here are some valid floating-point number literals:

select 25f,+6.34F,0.5d,-1D from dual;

select * from employees;

SELECT COUNT(*) 
  FROM employees 
  WHERE TO_BINARY_FLOAT(commission_pct)
     != BINARY_FLOAT_NAN; --A value of type BINARY_FLOAT for which the condition IS NAN is true

SELECT COUNT(*) 
  FROM employees 
  WHERE salary < BINARY_FLOAT_INFINITY; --Single-precision positive infinity

SELECT COUNT(*) 
  FROM employees 
  WHERE TO_BINARY_DOUBLE(commission_pct)
     != BINARY_DOUBLE_NAN; --A value of type BINARY_DOUBLE for which the condition IS NAN is true

SELECT COUNT(*) 
  FROM employees 
  WHERE commission_pct IS NOT NULL;
  
SELECT COUNT(*) 
  FROM employees 
  WHERE salary < BINARY_DOUBLE_INFINITY; --Double-precision positive infinity

--Oracle DATE columns always contain both the date and time fields. Therefore, if you query a DATE column, then you must either specify the time 
--field in your query or ensure that the time fields in the DATE column are set to midnight. Otherwise, Oracle may not return the query results you expect. 
--You can use the TRUNC date function to set the time field to midnight, or you can include a greater-than or less-than condition in the query instead of an 
--equality or inequality condition.

--Here are some examples that assume a table my_table with a number column row_num and a DATE column datecol:

create table my_table (
row_num number,
datecol date);

insert into my_table values (1,trunc(sysdate));
insert into my_table values (2,sysdate);

select * from my_table;

select * from my_table where datecol > '02-MAR-2017';

select * from my_table where datecol > '03-MAR-2017';

select * from my_table where datecol = '03-MAR-2017';

select * from my_table where trunc(datecol) = '03-MAR-2017';

--Oracle applies the TRUNC function to each row in the query, so performance is better if you ensure the midnight value of the time fields in your data. 
--To ensure that the time fields are set to midnight, use one of the following methods during inserts and updates:

--Use the TO_DATE function to mask out the time fields:
INSERT INTO my_table
  VALUES (3, TO_DATE('03-MAR-2017','DD-MON-YYYY'));
--Use the DATE literal:
INSERT INTO my_table
  VALUES (4, '03-MAR-17');
--Use the TRUNC function:
INSERT INTO my_table
  VALUES (5, TRUNC(SYSDATE));
  
select * from my_table where datecol = '03-MAR-2017';

--Value Specified in INSERT Statement	            Value Returned by Query
--'19-FEB-2004'	                                  19-FEB-2004.00.00.000000 AM
--SYSTIMESTAMP	                                  19-FEB-04 02.54.36.497659 PM
--TO_TIMESTAMP('19-FEB-2004', 'DD-MON-YYYY')	    19-FEB-04 12.00.00.000000 AM
--SYSDATE	                                        19-FEB-04 02.55.29.000000 PM
--TO_DATE('19-FEB-2004', 'DD-MON-YYYY')	          19-FEB-04 12.00.00.000000 AM
--TIMESTAMP'2004-02-19 8:00:00 US/Pacific'	      19-FEB-04 08.00.00.000000 AM

select interval '123-2' year(3) to month from dual;
select interval '123' year(3) to month from dual;
select interval '123' year from dual; --Returns an error, because the default precision is 2, and '123' has 3 digits.
select interval '123' month(3) from dual;
select interval '13' year from dual; --if more than 2 dgits, precision should be mentioned in brackets after year. 
select interval '13' month from dual;
select interval '13' month + interval '5-4' year to month from dual;
select INTERVAL '4 5:12:10.222' DAY TO SECOND(3) from dual;
select INTERVAL '4 5:12:10.222' DAY TO SECOND from dual;
select INTERVAL '100 5:12:10.222' DAY TO SECOND from dual;--Returns an error, because the default precision is 2, and '100' has 3 digits.
select INTERVAL '100 5:12:10.222' DAY(3) TO SECOND from dual;
select INTERVAL '100 5:12' DAY(3) TO MINUTE from dual;
select INTERVAL '100 5' DAY(3) TO HOUR from dual;
select INTERVAL '5:12:10.222' HOUR(3) TO SECOND from dual;
select interval 5 day from dual; -- Return error since interval year to month/day to second take only string values but not numeric values.
--For numeric below should be used (Show me the manager_id, employee name whom the manager recruited, hire date and count of employees the maanager recruited in last
--100 days)
SELECT manager_id, last_name, hire_date,
       COUNT(*) OVER (PARTITION BY manager_id ORDER BY hire_date 
       RANGE NUMTODSINTERVAL(100, 'day') PRECEDING) AS t_count 
  FROM employees
  ORDER BY manager_id;

SELECT manager_id, last_name, hire_date,
       COUNT(*) OVER (PARTITION BY manager_id ORDER BY hire_date 
       RANGE NUMTOYMINTERVAL(1, 'year') PRECEDING) AS t_count 
  FROM employees
  ORDER BY manager_id;
  
SELECT manager_id, last_name, hire_date,
       COUNT(*) OVER (PARTITION BY manager_id ORDER BY hire_date 
       RANGE  365 PRECEDING) AS t_count --here it range always considers days. So 365 days.
  FROM employees
  ORDER BY manager_id,hire_date;
  
create table testrange as 
select 10 as dept_id, '07-JUL-04' as Hire_Date, 100000 as salary from dual
union all
select 10 as dept_id, '07-JUL-04' as Hire_Date, 40000 as salary from dual
union all
select 20 as dept_id, '07-JUL-04' as Hire_Date, 50000 as salary from dual
union all
select 20 as dept_id, '07-AUG-04' as Hire_Date, 100000 as salary from dual
union all
select 20 as dept_id, '07-AUG-04' as Hire_Date, 530000 as salary from dual;

select * from testrange;

select dept_id, hire_date, salary, 
sum(salary) over(partition by dept_id order by to_date(hire_date) range 30 preceding) as salsum
from testrange;

select TO_NUMBER('100.00', '9G999D99') from dual;

SELECT TO_CHAR(number, 'fmt')
  FROM DUAL;

SELECT TO_CHAR(100, '99999S')
  FROM DUAL;

SELECT TO_CHAR(99, '99.99')
  FROM DUAL;

select TO_CHAR(1234, 'L99,999.99') from dual;

SELECT TO_CHAR(TO_DATE('0207','MM/YY'), 'MM/YY') FROM DUAL;
SELECT TO_DATE('0207','MM/YY') FROM DUAL;
SELECT TO_CHAR(TO_DATE('27-OCT-98', 'DD-MON-RR'), 'YYYY') "Year" FROM DUAL;
SELECT TO_CHAR(TO_DATE('27-OCT-98', 'DD-MON-RR'), 'MM') "Year" FROM DUAL;

SELECT TO_CHAR(SYSDATE, 'fmDDTH') || ' of ' ||
       TO_CHAR(SYSDATE, 'fmMonth') || ', ' ||
       TO_CHAR(SYSDATE, 'YYYY') "Ides" 
  FROM DUAL; 
  
--The preceding statement also uses the FM modifier. If FM is omitted, then the month is blank-padded to nine characters:
--FM - Fill mode. Oracle uses trailing blank characters and leading zeroes to fill format elements to a constant width.
--The width is equal to the display width of the largest element for the relevant format model:
SELECT TO_CHAR(SYSDATE, 'DDTH') || ' of ' ||
   TO_CHAR(SYSDATE, 'Month') || ', ' ||
   TO_CHAR(SYSDATE, 'YYYY') "Ides"
  FROM DUAL; 

SELECT TO_CHAR(SYSDATE, 'fmDay') || '''s Special' "Menu"
  FROM DUAL; 
  
--FX - Format exact. This modifier specifies exact matching for the character argument and datetime format model of a TO_DATE function:
SELECT TO_CHAR(SYSDATE, 'fxDay') || '''s Special' "Menu"
  FROM DUAL; 

SELECT TRANSLATE('SQL*Plus User''s Guide', ' */''', '___') FROM DUAL;

SELECT TO_CHAR(avg(ESTIMATED_TOTAL_PRICE), '$99,990.99')
  FROM mpr;

SELECT translate(TO_CHAR(avg(ESTIMATED_TOTAL_PRICE), '$99,990.99'),'$,',' ')
  FROM mpr;
  
SELECT to_number(translate(TO_CHAR(avg(ESTIMATED_TOTAL_PRICE), '$99,990.99'),'$,',' '))
  FROM mpr;
   
SELECT last_name employee, TO_CHAR(hire_date,'fmMonth DD, YYYY') hiredate
  FROM employees
  WHERE department_id = 20;
  
SELECT last_name employee, TO_CHAR(hire_date,'fxMonth DD, YYYY') hiredate
  FROM employees
  WHERE department_id = 20;
  
--If there is null on either side of = or != in where clause, then  the result would be unknown.
select commission_pct from employees where commission_pct is null;
select commission_pct from employees where commission_pct = null;
select commission_pct from employees where commission_pct != null;

SELECT last_name, employee_id, salary + NVL(commission_pct, 0), --NVL: if null replace with 0.
       job_id, e.department_id
  /* Select all employees whose compensation is
  greater than that of Pataballa.*/
  FROM employees e, departments d
  /*The DEPARTMENTS table is used to get the department name.*/
  WHERE e.department_id = d.department_id
    AND salary + NVL(commission_pct,0) >   /* Subquery:       */
      (SELECT salary + NVL(commission_pct,0)
        /* total compensation is salary + commission_pct */
        FROM employees 
        WHERE last_name = 'Pataballa')
  ORDER BY last_name, employee_id;

CREATE SEQUENCE customers_seq
 START WITH     1000
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

SELECT customers_seq.nextval 
  FROM DUAL;
  
SELECT customers_seq.currval 
  FROM DUAL;
  
select level c_number from dual connect by level < 100;

--COLUMN_VALUE Pseudocolumn
SELECT *
  FROM XMLTABLE('<a>123</a>');
  
SELECT COLUMN_VALUE
  FROM (XMLTable('<a>123</a>'));

SELECT ORA_ROWSCN, last_name
  FROM employees
  WHERE employee_id = 188;

SELECT SCN_TO_TIMESTAMP(ORA_ROWSCN), last_name
  FROM employees
  WHERE employee_id = 188;
  
SELECT ROWID, last_name
  FROM employees
  WHERE department_id = 20;
  
SELECT *
  FROM (SELECT * FROM employees ORDER BY employee_id)
  WHERE ROWNUM < 11;
  
--Conditions testing for ROWNUM values greater than a positive integer are always false. For example, this query returns no rows:

SELECT *
  FROM employees
  WHERE ROWNUM > 1;

--You can also use ROWNUM to assign unique values to each row of a table, as in this example:

UPDATE my_table
  SET column1 = ROWNUM;
  
select length('chakri') + 10 from dual;

select avg(salary) from employees;

SELECT AVG(CASE WHEN e.salary > 2000 THEN e.salary
   ELSE 2000 END) "Average Salary" FROM employees e;

with temp as (
SELECT AVG(CASE WHEN e.salary > 2000 THEN e.salary
   ELSE 2000 END) as AverageSalary FROM employees e
)
select salary, round(temp.AverageSalary,2) as avgsal from employees, temp;

--below query costs less
select salary, (SELECT AVG(CASE WHEN e.salary > 2000 THEN e.salary
   ELSE 2000 END) as AverageSalary FROM employees e) avgsal from employees;

--below query costs same as temp table query
select salary, AVGSAL.AVERAGESALARY from employees, (SELECT AVG(CASE WHEN e.salary > 2000 THEN e.salary
   ELSE 2000 END) as AverageSalary FROM employees e) avgsal;
   
--CURSOR Expressions

SELECT department_name, CURSOR(SELECT salary, commission_pct 
   FROM employees e
   WHERE e.department_id = d.department_id)
   FROM departments d
   ORDER BY department_name;

select (select 1,2,3 from dual) as he, 10 from dual;

select cursor(select 1,2,3 from dual) as he, 10 from dual;

select D.DEPARTMENT_NAME,
           cursor (
               select last_name
                 from employees e
                where E.DEPARTMENT_ID = D.DEPARTMENT_ID
                order by last_name
           )
      from departments d
     order by D.DEPARTMENT_NAME;

select d.department_name, listagg(e.last_name,',') within group(order by e.last_name) 
from departments d, employees e where E.DEPARTMENT_ID = D.DEPARTMENT_ID group by d.department_name;

select d.department_name, listagg(e.last_name,',') within group(order by e.last_name) 
from departments d left join employees e on E.DEPARTMENT_ID = D.DEPARTMENT_ID group by d.department_name;

--DATE-TIME Expression

SELECT FROM_TZ(CAST(TO_DATE('1999-12-01 11:00:00', 
      'YYYY-MM-DD HH:MI:SS') AS TIMESTAMP), 'America/New_York') 
   AT TIME ZONE 'America/Los_Angeles' "West Coast Time" 
   FROM DUAL;
   
SELECT FROM_TZ(CAST(TO_DATE('1999-12-01 11:00:00', 
      'YYYY-MM-DD HH:MI:SS') AS TIMESTAMP), 'America/New_York') 
   "West Coast Time" 
   FROM DUAL;
   
SELECT orderdate from orders
   WHERE orderid = 10249;
   
--Interval Expressions
SELECT (SYSTIMESTAMP - orderdate) DAY(9) TO SECOND FROM orders
   WHERE orderid = 10249;
   
--Expression Lists
SELECT * FROM employees 
  WHERE (first_name, last_name, email) IN 
  (('Guy', 'Himuro', 'GHIMURO'),('Karen', 'Colmenares', 'KCOLMENA'));
  
SELECT department_id, MIN(salary) min, MAX(salary) max FROM employees
   GROUP BY department_id, salary
   ORDER BY department_id, min, max;

SELECT department_id, MIN(salary) min, MAX(salary) max FROM employees
   GROUP BY (department_id, salary)
   ORDER BY department_id, min, max;
   
--Comparison conditions
SELECT * FROM employees
  WHERE salary = ANY
  (SELECT salary 
   FROM employees
  WHERE department_id = 30)
  ORDER BY employee_id;

SELECT * FROM employees
  WHERE salary >=
  ALL (SELECT salary 
   FROM employees
  WHERE department_id = 30)
  ORDER BY salary;

SELECT * FROM employees
  WHERE salary >=
  ALL (SELECT max(salary) 
   FROM employees
  WHERE department_id = 30)
  ORDER BY salary;
  
SELECT * FROM employees
  WHERE salary >=
  SOME (SELECT salary
   FROM employees
  WHERE department_id = 30)
  ORDER BY salary;
  
SELECT COUNT(*) FROM employees
  WHERE commission_pct IS NOT NAN;

SELECT COUNT(*) FROM employees
  WHERE commission_pct IS NULL;

SELECT COUNT(*) FROM employees
  WHERE commission_pct IS NAN;

SELECT last_name FROM employees
  WHERE salary IS NOT INFINITE;

SELECT last_name FROM employees
  WHERE salary IS NOT INFINITE;

--Logical Conditions
SELECT *
  FROM employees
  WHERE NOT (commission_pct IS NULL)
  ORDER BY employee_id;

SELECT *
  FROM employees
  WHERE NOT 
  (salary BETWEEN 1000 AND 3000)
  ORDER BY salary;

SELECT *
  FROM employees
  WHERE job_id = 'PU_CLERK'
  AND department_id = 30
  ORDER BY employee_id;

SELECT *
  FROM employees
  WHERE job_id = 'PU_CLERK'
  OR department_id = 10
  ORDER BY employee_id;


--LIKE Condition
SELECT last_name 
   FROM employees
   WHERE last_name 
   LIKE '%A\_d%' ESCAPE '\'
   ORDER BY last_name; 
--The ESCAPE clause identifies the backslash (\) as the escape character. In the pattern, the escape character precedes the underscore (_).
--This causes Oracle to interpret the underscore literally, rather than as a special pattern matching character.

SELECT last_name 
   FROM employees
   WHERE last_name 
   LIKE '%A_d%' ESCAPE '\'
   ORDER BY last_name; 
   
--Pattern withour % Example
CREATE TABLE ducks (f CHAR(6), v VARCHAR2(6));
INSERT INTO ducks VALUES ('DUCK', 'DUCK');
SELECT '*'||f||'*' "char",
   '*'||v||'*' "varchar"
   FROM ducks;
--Because Oracle blank-pads CHAR values, the value of f is blank-padded to 6 bytes. v is not blank-padded and has length 4.

select f from ducks where f like 'DUCK';
select f from ducks where f like 'DUCK  ';

--REGEXP_LIKE
SELECT first_name, last_name
FROM employees
WHERE REGEXP_LIKE (first_name, '^Ste(v|ph)en$')
ORDER BY first_name, last_name;

--The following query returns the last name for those employees with a double
--vowel in their last name (where last_name contains two adjacent occurrences of either a, e, i, o, or u, regardless of case):
SELECT last_name
FROM employees
WHERE REGEXP_LIKE (last_name, '([aeiou])\1', 'i')
ORDER BY last_name;

--TRUE if a subquery returns at least one row.
SELECT department_id
  FROM departments d
  WHERE EXISTS
  (SELECT * FROM employees e
    WHERE d.department_id 
    = e.department_id)
   ORDER BY department_id;

SELECT department_id
  FROM departments d
  WHERE EXISTS
  (SELECT * FROM employees e
    WHERE commission_pct is NAN)
   ORDER BY department_id;
   
SELECT 'True' FROM employees
    WHERE department_id NOT IN (10, 20, NULL); 
--Because the third condition compares department_id with a null, it results in an UNKNOWN, 
--so the entire expression results in FALSE (for rows with department_id equal to 10 or 20). This behavior can easily be overlooked, 
--especially when the NOT IN operator references a subquery.

--Moreover, if a NOT IN condition references a subquery that returns no rows at all, then all rows will be returned, as shown in the following example:
SELECT 'True' FROM employees
   WHERE department_id NOT IN (SELECT 0 FROM DUAL WHERE 1=2);   

--Restriction on LEVEL in WHERE Clauses 
--In a [NOT] IN condition in a WHERE clause, if the right-hand side of the condition is a subquery, you cannot use LEVEL on the left-hand side of the condition. 
--However, you can specify LEVEL in a subquery of the FROM clause to achieve the same result. For example, the following statement is not valid:
SELECT employee_id, last_name FROM employees
   WHERE (employee_id, LEVEL) 
      IN (SELECT employee_id, 2 FROM employees)
   START WITH employee_id = 2
   CONNECT BY PRIOR employee_id = manager_id;

SELECT employee_id, last_name, LEVEL FROM employees
   WHERE LEVEL = 2
   START WITH employee_id = 100
   CONNECT BY PRIOR employee_id = manager_id;
   
SELECT v.employee_id, v.last_name, v.lev FROM
      (SELECT employee_id, last_name, LEVEL lev 
      FROM employees v
      START WITH employee_id = 100 
      CONNECT BY PRIOR employee_id = manager_id) v 
   WHERE (v.employee_id, v.lev) IN
      (SELECT employee_id, 2 FROM employees); 

--Functions
--Single-Row Functions
SELECT INITCAP('the soap') "Capitals"
  FROM DUAL; 

SELECT LPAD('the soap',14,'.') "Capitals"
  FROM DUAL; 

SELECT LPAD('the soap',14,' ') "Capitals"
  FROM DUAL; 

--following throws error  
select concat(last_name,'ID is', employee_id) from employees;

select concat(concat(last_name,' ID is '), employee_id) from employees;

select last_name || ' ID is ' || employee_id from employees;

SELECT
  REGEXP_REPLACE(phone_number,
                 '([[:digit:]]{3})\.([[:digit:]]{3})\.([[:digit:]]{4})',
                 '(\1) \2-\3') "REGEXP_REPLACE"
  FROM employees
  ORDER BY "REGEXP_REPLACE";
  
--Last Value--
SELECT last_name, salary, hire_date,
       LAST_VALUE(hire_date)
         OVER (ORDER BY salary  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
               FOLLOWING) AS lv
  FROM (SELECT * FROM employees
          WHERE department_id = 90
          ORDER BY hire_date );

SELECT last_name, salary, hire_date,
       LAST_VALUE(hire_date)
         OVER (ORDER BY salary  desc ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
               FOLLOWING) AS lv
  FROM (SELECT * FROM employees
          WHERE department_id = 90
          ORDER BY hire_date );
          
SELECT last_name, salary, hire_date,
       LAST_VALUE(hire_date)
         OVER (ORDER BY salary desc ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
               FOLLOWING) AS lv
  FROM (SELECT * FROM employees
          WHERE department_id = 90
          ORDER BY hire_date desc);
          
--First Value--
SELECT last_name, salary, hire_date,
       FIRST_VALUE(hire_date)
         OVER (ORDER BY salary  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED
               FOLLOWING) AS lv
  FROM (SELECT * FROM employees
          WHERE department_id = 90
          ORDER BY hire_date );
          
