----LAG/LEAD example----

select trunc(sales_date, 'mon') as sales_month,
sum(total_amount) as total_amount
from sales s
group by trunc(sales_date, 'mon');

SELECT TRUNC(sales_date, 'mon')                                      AS sales_month,
  SUM(sales_amount)                                                  AS sales_amount,
  lag(SUM(sales_amount),1,0) over(ORDER by TRUNC(sales_date,'mon'))  AS prev_month,
  lead(SUM(sales_amount),1,0) over(order by TRUNC(sales_date,'mon')) AS nxt_month
FROM sales
GROUP BY TRUNC(sales_date, 'mon');

select inn.*, round((sales_amount -prev_month)*100/prev_month,2) as growth from(
select trunc(sales_date, 'mon') as sales_month,
sum(sales_amount) as sales_amount,
lag(sum(sales_amount),1) over(order by trunc(sales_date,'mon')) as prev_month,
lead(sum(sales_amount),1) over(order by trunc(sales_date,'mon')) as nxt_month
from sales 
group by trunc(sales_date, 'mon')) inn;

select inn.*, round((sales_amount -prev_month)*100/prev_month,2) as growth from(
select trunc(sales_date, 'mon') as sales_month,
sum(sales_amount) as sales_amount,
lag(sum(sales_amount),1) over(order by trunc(sales_date,'mon')) as prev_month,
lead(sum(sales_amount),1,0) over(order by trunc(sales_date,'mon')) as nxt_month
from sales 
group by trunc(sales_date, 'mon')) inn;