----Arithematic expressions on NULL values----
--Any arithematic expression on NULL values returns NULL values
select 10 + 9 from dual;
select 10 + NULL from dual;
select 10 * NULL from dual;
select 10 / NULL from dual;
select 10 - NULL from dual;

--Don't do following when NULL's appear in the column
select avg(column) from tablename;
select count(column) from tablename;

select sum(10+10+10+NULL) from dual;

select * from sales;

insert into sales values ('1-jan-2015',1334,203,14,1000,40,20,800,null,40);

select * from sales;

select avg(tax_amount) from sales; -- 161.2765

select count(*) from sales; -- 95

select sum(tax_amount) from sales; -- 15160 -> 15160/95 = 159.57. But above the average was 161.27. Above avg function has ignored row with null value. Hence, following
--method should be followed.

--Do as follow
select avg(NVL(colun, 0)) from tablename;

select avg(NVL(tax_amount, 0)) from sales; -- 159.57 which is correct

select avg(NVL(tax_amount, null)) from sales; -- 161.27. If record with null value shouldn't be considered then put null inside NVL function instead of 0.

