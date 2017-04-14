----CASE, used to convert row level data to column level data----

select * from sales;

select trunc(sales_date,'mon'),
product_id,
sum(sales_amount)
from sales
group by trunc(sales_date,'mon'),product_id
order by 1;

select trunc(sales_date,'mon'),
  sum(case when product_id = 100 then sales_amount else 0 end) as Prod_100,
  sum(case when product_id = 101 then sales_amount else 0 end) as Prod_101
from sales group by trunc(sales_date,'mon') order by 1;

select order_id, total_amount, 
row_number() over(order by total_amount desc) as rownm,
rank() over(order by total_amount desc) as rank,
dense_rank() over(order by total_amount desc) as denserank
from sales; 

SELECT customer_id,
  total_amount,
  salesperson_id,
  sales_date,
  row_number() over(partition by customer_id
  order by
  CASE
    WHEN salesperson_id = 2000
    THEN 1
    ELSE 2
  END, sales_date) AS priority
FROM sales;

with temp as (
SELECT customer_id,
  total_amount,
  salesperson_id,
  sales_date,
  row_number() over(partition by customer_id
  order by
  CASE salesperson_id 
    WHEN  2000
    THEN 1
    ELSE 2
  END, sales_date) AS priority
FROM sales)
select * from temp where priority = 1;

----PIVOT analytical function----

--trunc(sales_date,'mon') converts all dates to 1st of the month
select sales_date, product_id, sales_amount from sales order by 1;

select trunc(sales_date, 'mon') as month, product_id, sales_amount from sales order by 1;
select * from (
select trunc(sales_date, 'mon') as month, product_id, sales_amount from sales order by 1)
pivot (sum(sales_amount) as sales for product_id in (100,101,105,106,203,233)) 
order by month;

----LISTAGG Analytical function----

select * from customer;

select region,
listagg(last_name,',') within  group(order by last_name) as last_name
from customer
group by region;
