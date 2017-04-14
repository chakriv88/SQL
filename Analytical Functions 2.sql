create table plch_gas_price_log (
   logged_date    date     unique
 , logged_price   number   not null
)
/
insert into plch_gas_price_log values (date '2014-09-01', 7.50)
/
insert into plch_gas_price_log values (date '2014-09-02', 7.61)
/
insert into plch_gas_price_log values (date '2014-09-03', 7.72)
/
insert into plch_gas_price_log values (date '2014-09-04', 7.89)
/
insert into plch_gas_price_log values (date '2014-09-05', 7.89)
/
insert into plch_gas_price_log values (date '2014-09-06', 7.83)
/
insert into plch_gas_price_log values (date '2014-09-07', 7.55)
/
insert into plch_gas_price_log values (date '2014-09-08', 7.55)
/
insert into plch_gas_price_log values (date '2014-09-09', 7.72)
/
insert into plch_gas_price_log values (date '2014-09-10', 7.89)
/
insert into plch_gas_price_log values (date '2014-09-11', 7.61)
/
insert into plch_gas_price_log values (date '2014-09-12', 7.61)
/
insert into plch_gas_price_log values (date '2014-09-13', 7.61)
/
insert into plch_gas_price_log values (date '2014-09-14', 7.72)
/
commit;

select * from PLCH_GAS_PRICE_LOG;

--Our analytical department wishes to assign a consecutive group id to the logged prices in such a manner,
--that when the same price is repeated on consecutive days, the same group id should be used.

with temp as (
select logged_date, 
case when max(logged_price) over(order by logged_date rows between 1 preceding and 1 preceding) = 
          max(logged_price) over(order by logged_date rows current row)
     then 0
     else 1
     end as score,
LOGGED_PRICE
from PLCH_GAS_PRICE_LOG
)
select temp.*, sum(score) over(order by logged_date) as rnk from temp;
     
select logged_date
     , logged_price
     , dense_rank() over (
          order by period_group
       ) logged_group_id
  from (
   select logged_date
        , logged_price
        , last_value(period_start ignore nulls) over (
             order by logged_date
             rows between unbounded preceding and current row
          ) period_group
     from (
      select logged_date
           , logged_price
           , case lag(logged_price) over (order by logged_date)
                when logged_price then null
                                  else logged_date
             end period_start
        from plch_gas_price_log
     )
  )
 order by logged_date;
     
select logged_date
     , logged_price
     , sum(period_start) over (
          order by logged_date
          rows between unbounded preceding and current row
       ) logged_group_id
  from (
   select logged_date
        , logged_price
        , case lag(logged_price) over (order by logged_date)
             when logged_price then 0
                               else 1
          end period_start
     from plch_gas_price_log
  )
 order by logged_date;
 
select logged_date
     , logged_price
     , (
          select count(*)
            from plch_gas_price_log g2
            join plch_gas_price_log g3
                 on g3.logged_date = g2.logged_date - 1
           where g3.logged_price != g2.logged_price
             and g2.logged_date <= g1.logged_date
       ) + 1 logged_group_id
  from plch_gas_price_log g1
 order by logged_date;
 
select logged_date
     , logged_price
     , row_number() over (
          order by logged_date
       ) - sum(identical) over (
          order by logged_date
          rows between unbounded preceding and current row
       ) logged_group_id
  from (
   select logged_date
        , logged_price
        , decode(
             lag(logged_price) over (order by logged_date) - logged_price
           , 0, 1
           , 0
          ) identical
     from plch_gas_price_log
  )
 order by logged_date;
 
select logged_date
     , logged_price
     , dense_rank() over (
          order by logged_price
       ) logged_group_id
  from plch_gas_price_log
 order by logged_date; --wrong one
 
select logged_date
     , logged_price
     , row_number() over (
          partition by logged_price
          order by logged_price
       ) logged_group_id
  from plch_gas_price_log
 order by logged_date; --wrong one