----NTILE Example----
-- divides group of data into buckets or bands
select 
sp.FIRST_NAME,
sum(total_amount) as total_amount
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID 
group by sp.FIRST_NAME;

select 
sp.FIRST_NAME,
sum(total_amount) as total_amount,
NTILE(3) OVER (ORDER BY sum(total_amount) DESC) as band
from sales s, salesperson sp
where s.SALESPERSON_ID = sp.SALESPERSON_ID 
group by sp.FIRST_NAME;