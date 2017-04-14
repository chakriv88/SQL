----CONNECT BY unary operator for hierarchical data----

select * from salesperson order by manager;

select first_name, job_title, manager, level
from salesperson
connect by prior
first_name = manager
start with
manager is null order by 4;

select 
concat (lpad(' ',level*3 - 3), first_name) as hierarchy, level
from salesperson
connect by prior
first_name = manager
start with
manager is null;

select 
concat (lpad(' ',level*3 - 3), first_name) as hierarchy, level
from salesperson
connect by prior
first_name = manager
start with
manager is null
order by salesperson.first_name;

--Always use order siblings clause to order hierarchical data

select 
concat (lpad(' ',level*3 - 3), first_name) as hierarchy, level
from salesperson
connect by prior
first_name = manager
start with
manager is null
order siblings by salesperson.first_name;

select 
concat (lpad(' ',level*3 - 3), first_name) as hierarchy, level
from salesperson
connect by prior
first_name = manager
start with
manager is null
order siblings by salesperson.first_name desc;

--CONNECT BY ROOT clause

select 
first_name, job_title, manager, level,
connect_by_root (first_name) as top_boss
from salesperson
connect by prior
first_name = manager
start with
manager is null;

select 
first_name, job_title, manager, level,
connect_by_root (first_name) as top_boss
from salesperson
connect by prior
first_name = manager
start with
manager = 'Jeff';

select 
first_name, job_title, manager, level,
connect_by_root (first_name) as top_boss
from salesperson
connect by prior
first_name = manager
start with
manager = 'Raj' or
manager = 'Tom';

select * from sales;
select * from salesperson;

select top_boss, sum(sales_amount) as sales from
(
select 
salesperson_id, first_name, job_title, manager, level,
connect_by_root (first_name) as top_boss
from salesperson
connect by prior
first_name = manager
start with
manager = 'Raj'
) hier, sales
where hier.salesperson_id = sales.salesperson_id
group by top_boss;

select top_boss, first_name, sum(sales_amount) as sales from
(
select 
salesperson_id, first_name, job_title, manager, level,
connect_by_root (first_name) as top_boss
from salesperson
connect by prior
first_name = manager
start with
manager = 'Raj'
) hier, sales
where hier.salesperson_id = sales.salesperson_id
group by top_boss, first_name;

