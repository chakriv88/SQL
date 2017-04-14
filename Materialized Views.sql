----MATERIALISED VIEWS----

create materialized view sales_c_mv
build immediate --another build option is deffered
refresh force -- another refresh options are fast and complete
on commit -- another option is on demand. Unless the data is to be immediately replicated in view, don't use commit option since it can be very costly.
as
select 
s.sales_date, s.sales_amount, p.product_name
from sales$remote_db s, product@remote_db p -- @remote_db is accessing another db which is at remote server using the link remote_db.
where s.product_id = p.product_id;

select * from sales;
select * from product;

create materialized view sales_c_mv
build immediate --another build option is deffered
refresh force -- another refresh options are fast and complete
on commit -- another option is on demand
as
select 
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id;

select * from SALES_C_MV;

insert into sales values('15-JAN-16',	1589,	200,	12,	1000,	20,	20,	400,	40,	440);

select * from sales;

select * from SALES_C_MV; -- Not updated in view since this is not committed.

commit;

select * from SALES_C_MV; -- View is refreshed with new insert after commit operation.

create materialized view sales_c_mv2
build immediate --another build option is deffered
refresh force -- another refresh options are fast and complete
on demand -- another option is on commit. You can refresh when ever you want on demand manually like every morning, evening etc.
--on demand is most commonly used than on commit.
as
select 
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id;

select * from SALES_C_MV2;

insert into sales values('15-FEB-16',	1598,	100,	12,	1000,	20,	20,	400,	40,	440);

select * from sales;

select * from SALES_C_MV2; -- Not updated in view since this is not refreshed on demand.

commit;

select * from SALES_C_MV2; -- Not updated in view even after commit since this is not refreshed on demand.

exec dbms_mview.refresh('sales_c_mv2');

select * from SALES_C_MV2; -- Now it is refreshed.

--Refresh fast--
--Based on the If materialized view logs, an incremental refresh happens.
--Fast refreshable materialized views can be created based on master tables and master materialized views only.
--Materialized view based on a synonym or a view must be complete refreshed
--Materialized view are not eligible for fast refresh if the defined subquery contains an analytical function.

--Step 1: First create a materialized view log
create materialized view log on sales
with primary key
including new values;
--or ROWID if base table doesn't have primary key
create materialized view log on sales
with rowid
including new values;

--Step 2: Then create a materialized view with fast refresh.
create materialized view sales_c_mv2
build immediate --another build option is deffered
refresh fast -- another refresh options are force and complete
on demand -- another option is on commit. You can refresh when ever you want on demand manually like every morning, evening etc.
--on demand is most commonly used than on commit.
as
select s.rowid as s_rowid, p.rowid as p_rowid, --if in step 1, we use rowid in materialized log, then rowid must be included here. Very important point.
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id;

--Timing the refresh--

create materialized view sales_c_mv3
build immediate --another build option is deffered
refresh fast -- another refresh options are force and complete
on demand -- another option is on commit. You can refresh when ever you want on demand manually like every morning, evening etc.
--on demand is most commonly used than on commit.
start with sysdate next sysdate + 7 --this automatically does a refresh when created and next refresh will be after 7 days
as
select s.rowid as s_rowid, p.rowid as p_rowid, --if in step 1, we use rowid in materialized log, then rowid must be included here. Very important point.
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id;

create materialized view sales_c_mv3
build immediate --another build option is deffered
refresh fast -- another refresh options are force and complete
on demand -- another option is on commit. You can refresh when ever you want on demand manually like every morning, evening etc.
--on demand is most commonly used than on commit.
start with sysdate next sysdate + 30/(24*60) --this automatically does a refresh when created and next refresh will be after 30 minutes
as
select s.rowid as s_rowid, p.rowid as p_rowid, --if in step 1, we use rowid in materialized log, then rowid must be included here. Very important point.
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id;

--Query rewrite--

create materialized view sales_c_mv3
build immediate --another build option is deffered
refresh force -- another refresh options are fast and complete
on demand -- another option is on commit. You can refresh when ever you want on demand manually like every morning, evening etc.
--on demand is most commonly used than on commit.
enable query rewrite --When ever possible, a new query takes data from this m_view instead of going through all the data from dbms
as
select 
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id;

--execute following query
select 
s.sales_date, s.sales_amount, p.product_name
from sales s, product p 
where s.product_id = p.product_id; 
--if rewrite query is not enabled, above query would have retreived data from original tables. But since materialized view uses same query, above  query retreives
--data from that m_view. We can check this from explain plan as well.

--There is no need to write the exact query. Even following query will work
select 
s.sales_date, p.product_name
from sales s, product p 
where s.product_id = p.product_id; 