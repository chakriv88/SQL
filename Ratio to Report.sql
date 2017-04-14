----Ration to report example----

select * from sales;

select trunc(sales_date,'mon') as Month,
sum(total_amount) as total_amount,
RATIO_TO_REPORT(sum(total_amount)) OVER ()*100 as ratioPerc
from sales 
group by trunc(sales_date,'mon') order by 1;

select trunc(sales_date,'mon') as Month,
sum(total_amount) over(partition by trunc(sales_date,'mon')) as total_amount
from sales;

--following throws error
select trunc(sales_date,'mon') as Month,
sum(total_amount) over(partition by trunc(sales_date,'mon')) as total_amount,
RATIO_TO_REPORT(sum(total_amount)) OVER ()*100 as ratioPerc
from sales;

select sales_date,
sum(total_amount) as total_amount,
RATIO_TO_REPORT(sum(total_amount)) OVER (partition by trunc(sales_date,'mon'))*100 as ratioByMonth_Perc
from sales 
group by sales_date order by 1;

select trunc(sales_date,'mon') as Month,
sum(total_amount) as total_amount,
RATIO_TO_REPORT(sum(sales_amount)) OVER ()*100 as ratioPerc_on_salesamount
from sales 
group by trunc(sales_date,'mon') order by 1;

select trunc(sales_date,'mon') as Month,
sum(total_amount) as total_amount,
sum(sales_amount) as sales_amount,
RATIO_TO_REPORT(sum(total_amount)) OVER ()*100 as ratioPerc_on_totalamount,
RATIO_TO_REPORT(sum(sales_amount)) OVER ()*100 as ratioPerc_on_salesamount
from sales 
group by trunc(sales_date,'mon') order by 1;