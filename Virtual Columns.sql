----VIRTUAL COLUMNS----
--Virtual columns just appear like normal table columns, but their values are derived at run time rather than 
--being stored on disc. Hence, you can't insert any data into virtual columns.
--Advantage: Saves disk space. Need not update data if formula changes.

CREATE TABLE SALES1 (
SALES_DATE DATE,
ORDERID NUMBER,
TOTAL_AMOUNT NUMBER,
COMMISSION NUMBER GENERATED ALWAYS AS (TOTAL_AMOUNT*0.01) VIRTUAL
);

INSERT INTO SALES1(SALES_DATE,ORDERID,TOTAL_AMOUNT) VALUES (to_date('24-02-2017','dd-mm-yyyy'),1,345);

select * from sales1;

ALTER TABLE SALES1 ADD COMMISSION2 AS (TOTAL_AMOUNT*0.02); --Another way of creating virtual column

select * from sales1;

--Another method is
CREATE TABLE SALES2 (
SALES_DATE DATE,
ORDERID NUMBER,
TOTAL_AMOUNT NUMBER,
COMMISSION AS (TOTAL_AMOUNT*0.01) 
);

select * from sales2;

INSERT INTO SALES2(SALES_DATE,ORDERID,TOTAL_AMOUNT) VALUES (to_date('24-02-2017','dd-mm-yyyy'),1,345);

select * from sales2;

drop table sales1;

drop table sales2;