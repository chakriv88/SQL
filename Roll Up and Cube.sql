----ROLLUP and CUBE for subtotals and grand totals

select * from sales;
select * from product;

select trunc(s.sales_date,'mon') as sales_month, p.product_name, sum(sales_amount)
from sales s, product p
where p.product_id = s.product_id
group by trunc(s.sales_date,'mon'), p.product_name
order by 1;

select 
decode(trunc(s.sales_date,'mon'), null, 'GRAND', trunc(s.sales_date,'mon')) as sales_date,
decode(product_name, null, 'TOTAL',product_name) as product_name,
sum(sales_amount)
from sales s, product p
where p.product_id = s.product_id
group by rollup( trunc(s.sales_date,'mon'), p.product_name);

select 
decode(trunc(s.sales_date,'mon'), null, 'GRAND', trunc(s.sales_date,'mon')) as sales_date,
decode(product_name, null, 'TOTAL',product_name) as product_name,
sum(sales_amount)
from sales s, product p
where p.product_id = s.product_id
group by cube( trunc(s.sales_date,'mon'), p.product_name);