create table plch_reindeer (
   name        varchar2(10) primary key
 , horsepower  number not null unique
)
/
insert into plch_reindeer values ('Dasher'  , 1.5)
/
insert into plch_reindeer values ('Dancer'  , 1.1)
/
insert into plch_reindeer values ('Prancer' , 1.4)
/
insert into plch_reindeer values ('Vixen'   , 1.0)
/
insert into plch_reindeer values ('Comet'   , 1.3)
/
insert into plch_reindeer values ('Cupid'   , 0.9)
/
insert into plch_reindeer values ('Dunder'  , 1.2)
/
insert into plch_reindeer values ('Blixem'  , 0.8)
/
commit
/

select * from plch_reindeer;

--transform this into following output
/*
ROW_IDX LEFT_NAME  LEFT_HP RIGHT_NAME RIGHT_HP
------- --------- -------- ---------- --------
      1 Dasher         1.5 Prancer         1.4
      2 Dunder         1.2 Comet           1.3
      3 Dancer         1.1 Vixen           1.0
      4 Blixem          .8 Cupid            .9
*/

with temp as(
select r.*, floor((rank() over(order by horsepower desc) +1)/2) ROW_IDX,  
            case mod(ceil((rank() over(order by horsepower desc) + 1)/2),2)
                when 1 then 1
                else 2
                end
ceil
from plch_reindeer r
)
select * from temp
pivot (
max(name) as NAME, max(horsepower) as HP
for ceil in (1 as Left,
             2 as Right)
)
order by ROW_IDX;

with temp as(
select r.*, ntile(6) over(order by horsepower desc) ROW_IDX,  
            case mod(ceil((rank() over(order by horsepower desc) + 1)/2),2)
                when 1 then 1
                else 2
                end
ceil
from plch_reindeer r
)
select * from temp
pivot (
max(name) as NAME, max(horsepower) as HP
for ceil in (1 as Left,
             2 as Right)
)
order by ROW_IDX;

select row_idx, left_name, left_hp, right_name, right_hp
  from (
   select name, horsepower
        , ceil(rn / 2) row_idx
        , case mod(ceil(rn / 2), 2)
             when 1 then mod(rn - 1, 2) + 1
             when 0 then mod(rn, 2) + 1
          end col_idx
     from (
      select name, horsepower
           , row_number() over (order by horsepower desc) rn
        from plch_reindeer
          )
       )
 pivot (
    max(name) as name
  , max(horsepower) as hp
    for (col_idx) in (
       1 as left
     , 2 as right
    )
 );
 
--create or replace view with above output
create or replace view plch_reindeer_rows
as
select row_idx, left_name, left_hp, right_name, right_hp
  from (
   select name, horsepower
        , ceil(rn / 2) row_idx
        , case mod(ceil(rn / 2), 2)
             when 1 then mod(rn - 1, 2) + 1
             when 0 then mod(rn, 2) + 1
          end col_idx
     from (
      select name, horsepower
           , row_number() over (order by horsepower desc) rn
        from plch_reindeer
          )
       )
 pivot (
    max(name) as name
  , max(horsepower) as hp
    for (col_idx) in (
       1 as left
     , 2 as right
    )
 );
 
select row_idx, left_name, left_hp, right_name, right_hp
  from plch_reindeer_rows
 order by row_idx;
 
/*
Now Santa has found out that those reindeer that have another reindeer pulling in front of them will actually perform at a boosted strength.
He has found a formula for calculating the boosted horsepower value for each reindeer:

The boosted HP is the reindeer's own HP plus 10 percent of the boosted HP of the reindeer directly in front.
Write a code for returning this desired output:

ROW_IDX LEFT_NAME  LEFT_HP LEFT_BOOST RIGHT_NAME RIGHT_HP RIGHT_BOOST
------- --------- -------- ---------- ---------- -------- -----------
      1 Dasher         1.5     1.5000 Prancer         1.4      1.4000
      2 Dunder         1.2     1.3500 Comet           1.3      1.4400
      3 Dancer         1.1     1.2350 Vixen           1.0      1.1440
      4 Blixem          .8      .9235 Cupid            .9      1.0144
*/

select row_idx, left_name, left_hp, 
       case 
            when (sum(LEFT_HP) over(order by ROW_IDX rows between unbounded preceding and 1 preceding)) is null then left_hp
            else (sum(LEFT_HP) over(order by ROW_IDX rows between unbounded preceding and 1 preceding))*0.1 + left_hp
            end as prev,
       right_name, right_hp
  from plch_reindeer_rows
 order by row_idx;
 
(lag(left_hp,level) over(order by row_idx))*level*0.1;

select row_idx
     , left_name
     , left_hp
     , left_hp + 0.1 * prior left_hp as left_boost
     , right_name
     , right_hp
     , right_hp + 0.1 * prior right_hp as right_boost
     , level
  from plch_reindeer_rows
start with row_idx = 1
connect by row_idx = prior row_idx + 1
 order by row_idx;

select row_idx
     , left_name, left_hp, left_boost
     , right_name, right_hp, right_boost
  from plch_reindeer_rows
 model
   dimension by (
      row_idx
   )
   measures (
      left_name
    , left_hp
    , left_hp as left_boost
    , right_name
    , right_hp
    , right_hp as right_boost
   )
   rules AUTOMATIC ORDER (
      left_boost[row_idx between 2 and 4]
       = left_hp[cv()] + 0.1 * left_boost[cv() - 1]
    , right_boost[row_idx between 2 and 4]
       = right_hp[cv()] + 0.1 * right_boost[cv() - 1]
   )
 order by row_idx;
 
select row_idx
     , left_name, left_hp, left_boost
     , right_name, right_hp, right_boost
  from plch_reindeer_rows
 model
   dimension by (
      row_idx
   )
   measures (
      left_name
    , left_hp
    , left_hp as left_boost
    , right_name
    , right_hp
    , right_hp as right_boost
   )
   rules ITERATE (3) (
      left_boost[iteration_number + 2]
       = left_hp[iteration_number + 2]
          + 0.1 * left_boost[iteration_number + 1]
    , right_boost[iteration_number + 2]
       = right_hp[iteration_number + 2]
          + 0.1 * right_boost[iteration_number + 1]
   )
 order by row_idx;
 
 select row_idx
     , left_name, left_hp, left_boost
     , right_name, right_hp, right_boost
  from plch_reindeer_rows
 model
   dimension by (
      row_idx
   )
   measures (
      left_name
    , left_hp
    , left_hp as left_boost
    , right_name
    , right_hp
    , right_hp as right_boost
   )
   rules (
      left_boost[row_idx between 2 and 4] ORDER BY row_idx
       = left_hp[cv()] + 0.1 * left_boost[cv() - 1]
    , right_boost[row_idx between 2 and 4] ORDER BY row_idx
       = right_hp[cv()] + 0.1 * right_boost[cv() - 1]
   )
 order by row_idx;
 
with rr (
   row_idx
 , left_name, left_hp, left_boost
 , right_name, right_hp, right_boost
) as (
   select row_idx
        , left_name, left_hp, left_hp as left_boost
        , right_name, right_hp, right_hp as right_boost
     from plch_reindeer_rows
    where row_idx = 1
   union all
   select nxt.row_idx as row_idx
        , nxt.left_name as left_name
        , nxt.left_hp as left_hp
        , nxt.left_hp + 0.1 * rr.left_boost as left_boost
        , nxt.right_name as right_name
        , nxt.right_hp as right_hp
        , nxt.right_hp + 0.1 * rr.right_boost as right_boost
     from rr
     join plch_reindeer_rows nxt
            on nxt.row_idx = rr.row_idx + 1
)
select row_idx
     , left_name, left_hp, left_boost
     , right_name, right_hp, right_boost
  from rr
 order by row_idx;
 
 select * from plch_reindeer_rows;
 