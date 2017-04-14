----Rank Function----

select * from sales;
select * from salesperson;

select customer_id, sum(total_amount) as s, rank() over(order by sum(TOTAL_AMOUNT) desc) as r
from sales group by customer_id;

select trunc(sales_date,'mon') as Month,
sp.FIRST_NAME,
sum(total_amount) as total_amount
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID
group by trunc(sales_date,'mon'), sp.FIRST_NAME
order by 1;

select trunc(sales_date,'mon') as Month,
sp.FIRST_NAME,
sum(total_amount) as total_amount,
rank() over(partition by trunc(sales_date,'mon') order by sum(total_amount)  desc)
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID
group by trunc(sales_date,'mon'), sp.FIRST_NAME
order by 1;

select * from (
select trunc(sales_date,'mon') as Month,
sp.FIRST_NAME,
sum(total_amount) as total_amount,
rank() over(partition by trunc(sales_date,'mon') order by sum(total_amount)  desc) as rnk
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID 
group by trunc(sales_date,'mon'), sp.FIRST_NAME
order by 1)
where rnk <= 3;

select trunc(sales_date,'mon') as Month,
sp.FIRST_NAME,
sum(total_amount) as total_amount,
rank() over( order by sum(total_amount)  desc)
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID
group by trunc(sales_date,'mon'), sp.FIRST_NAME
order by 4;

--following throws error
select 
trunc(sales_date,'mon') as Month,
sp.FIRST_NAME,
sum(total_amount) as total_amount,
rank() over( partition by sum(total_amount)  )
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID
group by trunc(sales_date,'mon'), sp.FIRST_NAME
order by 4;

select * from employees; --HR Schema
select extract(day from to_date('23-MAR-2014' ,'dd-mm-yyyy')) as days from dual;
select to_char(to_date('1-mar-2014')-1,'dd') from dual;
select to_char(to_date('23-mar-2014'),'mmrrrr') from dual;
select last_name, salary, rank() over(order by salary desc) as rnk from employees;
select last_name, salary, dense_rank() over(order by salary desc) as rnk from employees;

select order_id, total_amount, dense_rank() over(order by TOTAL_AMOUNT desc) from sales;
select dense_rank(400) within group(order by total_amount desc) from sales;
select order_id, total_amount from sales order by total_amount fetch first 5 rows only; --new command only available from oracle 12g



