----Column level data to row level data----

create table sales_pivot as 
select * from (
select trunc(sales_date, 'mon') as month, product_id, sales_amount from sales order by 1)
pivot (sum(sales_amount) as sales for product_id in (100,101,105,106,203,233)) 
order by month;

select * from sales_pivot;

select month, 100 as product_id, "100_SALES" as sales_amount from sales_pivot;

select month, 100 as product_id, "100_SALES" as sales_amount from sales_pivot
union all
select month, 101 as product_id, "101_SALES" as sales_amount from sales_pivot
union all
select month, 105 as product_id, "105_SALES" as sales_amount from sales_pivot
union all
select month, 106 as product_id, "106_SALES" as sales_amount from sales_pivot;

-----UNPIVOT analytical function----
select "100_SALES" from sales_pivot;
select month, product_id, sales_amount from sales_pivot
unpivot(sales_amount for product_id in(
        "100_SALES" as 100,
        "101_SALES" as 101,
        "105_SALES" as 105,
        "106_SALES" as 106,
        "203_SALES" as 203,
        "233_SALES" as 233));
--in above query, column name "233_SALES" is case sensitive. Query wont work if we write "233_sales".
--if sales_pivot table consists null values, unpivot recognises and wont return those rows. Instead if it contains
--zeros, then it returns that row.

select * from sales_pivot
unpivot include nulls(any_name for product_id in(
        "100_SALES" as 100,
        "101_SALES" as 101,
        "105_SALES" as 105,
        "106_SALES" as 106,
        "203_SALES" as 203,
        "233_SALES" as 233));

select * from sales_pivot
unpivot include nulls((any_name1,any_name2) for product_id in(
        ("100_SALES","101_SALES") as 100101,
        ("105_SALES","106_SALES") as 105106,
        ("203_SALES","233_SALES") as 203233));

select * from sales_pivot
unpivot include nulls((any_name1,any_name2) for product_id in(
        ("100_SALES","101_SALES") as 100101,
        ("105_SALES","106_SALES") as 105106,
        ("203_SALES","233_SALES") as 203233)
        )
pivot(
max(any_name1) as m1,max(any_name2) as m2 for product_id in (100101,105106,203233)
);

SELECT *
FROM pivoted_employee
UNPIVOT (
  (employees, salaries) 
  FOR TYPE IN 
  (
    (total_employees,total_salaries) AS 'ALL', 
    (employees_3000,salaries_3000) AS 'EARN LESS THAN 3000'
  )
)
PIVOT (
  MAX(salaries) AS sal, 
  MAX(employees) AS emp 
  FOR department_id 
    IN (1 AS d1,2 AS d2,3 AS d3,4 AS d4)
);

select  * from sales;

SELECT department_id, COUNT(
    CASE TO_CHAR(hire_date, 'YYYY')
      WHEN '2014'
      THEN 1
    END) AS "2014", COUNT(
    CASE TO_CHAR(hire_date, 'YYYY')
      WHEN '2015'
      THEN 1
    END) AS "2015"
FROM employee
GROUP BY department_id
ORDER BY department_id;

select product_id, count(
case when salesperson_id = 1000 then 1
end
) as "1000",
count(
case when salesperson_id = 2000 then 1
end
) as "2000",
count(
case when salesperson_id = 3000 then 1
end
) as "3000",
count(
case when salesperson_id = 4000 then 1
end
) as "4000"
from sales
group by product_id;

select product_id, salesperson_id from sales where product_id = 100 order by salesperson_id;
select * from sales;
select * from (select product_id,customer_id, salesperson_id from sales)
pivot (count(*) for salesperson_id in (1000,2000,3000,4000))
order by product_id, customer_id;

select * from (select PRODUCT_ID, SALESPERSON_ID, TOTAL_AMOUNT from sales)
pivot (count(*) as count,sum(TOTAL_AMOUNT) as total for salesperson_id in (1000,2000,3000,4000))
order by product_id;

select * from (select PRODUCT_ID, SALESPERSON_ID,customer_id, TOTAL_AMOUNT from sales)
pivot (count(*) as count,sum(TOTAL_AMOUNT) as total for (salesperson_id,customer_id) in ((1000,12),(2000,12),(3000,12),(4000,12)))
order by product_id;

