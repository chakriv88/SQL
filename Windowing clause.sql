create table plch_scores (
   player   varchar2(10)
 , score    number
)
/

insert into plch_scores values ('Albert'  , 42)
/
insert into plch_scores values ('Benjamin', 36)
/
insert into plch_scores values ('Chris'   , 55)
/
insert into plch_scores values ('Dennis'  , 36)
/
insert into plch_scores values ('Eugene'  , 42)
/
insert into plch_scores values ('Finn'    , 36)
/
commit;

select * from plch_scores;

select player, score, dense_rank() over(order by score desc) rnk
from plch_scores
order by rnk;

select player
     , score
     , count(*) over (
          partition by score
          order by score desc
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
select player
     , score
     , count(*) over (
          order by score desc
          range between 0 preceding and 0 following
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
select player
     , score
     , count(*) over (
          order by score desc
          range between current row and 0 preceding
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
select player
     , score
     , count(*) over (
          order by score desc
          range between current row and 0 following
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
select player
     , score
     , count(*) over (
          order by score desc
          range between current row and current row
       ) same_score
  from plch_scores
 order by score desc
        , player;

select player
     , score
     , count(*) over (
          order by score desc
          range between 0 preceding and current row
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
select player
     , score
     , count(*) over (
          order by score desc
          range current row
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
select player
     , score
     , count(*) over (
          order by score desc
          range 0 following
       ) same_score
  from plch_scores
 order by score desc
        , player;
        
--Even though 0 following is in fact the same as current row, following keyword cannot be used in shortcut window specification 
--without between keyword. This raises ORA-00905: missing keyword.

select player
     , score
     , count(*) over (
          order by score desc
          range between 0 following and 0 following
       ) same_score
  from plch_scores
 order by score desc
        , player;