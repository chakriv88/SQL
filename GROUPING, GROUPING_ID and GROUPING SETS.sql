----GROUPING, GROUPING_ID and GROUPING SETS functions----

select 
decode(trunc(s.sales_date,'mon'), null, 'GRAND', trunc(s.sales_date,'mon')) as sales_date,
decode(p.product_name, null, 'TOTAL',product_name) as product_name,
grouping(trunc(s.sales_date,'mon')) as flag1,
grouping(p.product_name) as flag2,
sum(sales_amount)
from sales s, product p
where p.product_id = s.product_id
group by cube( trunc(s.sales_date,'mon'), p.product_name);

select 
decode(trunc(s.sales_date,'mon'), null, 'GRAND', trunc(s.sales_date,'mon')) as sales_date,
decode(p.product_name, null, 'TOTAL',product_name) as product_name,
grouping_id(trunc(s.sales_date,'mon'), p.product_name) as flag1,
sum(sales_amount)
from sales s, product p
where p.product_id = s.product_id
group by cube( trunc(s.sales_date,'mon'), p.product_name);


  select 
    trunc(s.sales_date,'mon'),
    p.product_name,
    c.city,
    grouping_id(trunc(s.sales_date,'mon'), p.product_name, c.city) as flag1,
    sum(sales_amount)
  from sales s, product p, customer c
  where (p.product_id = s.product_id and
        c.customer_id = s.customer_id) 
  group by cube(trunc(s.sales_date,'mon'), p.product_name, c.city)
  order by 1;

select 
trunc(s.sales_date,'mon'),
p.product_name,
c.city,
grouping_id(trunc(s.sales_date,'mon'), p.product_name, c.city) as flag1,
sum(sales_amount)
from sales s, product p, customer c
where p.product_id = s.product_id and
c.customer_id = s.customer_id
group by grouping sets((trunc(s.sales_date,'mon'), p.product_name),
                      (trunc(s.sales_date,'mon'), c.city))
order by 1,2;

--Composite columns--

  select 
    trunc(s.sales_date,'mon'),
    p.product_name,
    c.city,
    grouping_id(trunc(s.sales_date,'mon'), p.product_name, c.city) as flag1,
    sum(sales_amount)
  from sales s, product p, customer c
  where (p.product_id = s.product_id and
        c.customer_id = s.customer_id) 
  group by rollup((trunc(s.sales_date,'mon'), p.product_name),
                    c.city)
  order by 1,2;
  
  SELECT TRUNC(s.sales_date,'mon'),
  p.product_name,
  c.city,
  grouping_id(TRUNC(s.sales_date,'mon'), p.product_name, c.city) AS flag1,
  SUM(sales_amount)
FROM sales s,
  product p,
  customer c
WHERE (p.product_id = s.product_id
AND c.customer_id   = s.customer_id)
GROUP BY cube(TRUNC(s.sales_date,'mon'), ( p.product_name, c.city))
ORDER BY 1,2;