create table plch_result (
   team     varchar2(10)
 , athlete  varchar2(10)
 , timer    timestamp(3)
)
/

insert into plch_result values (
   'Denmark', 'Jensen'    , timestamp '2014-05-20 10:00:00.000'
)
/
insert into plch_result values (
   'Denmark', 'Nielsen'   , timestamp '2014-05-20 10:00:51.234'
)
/
insert into plch_result values (
   'Denmark', 'Svendsen'  , timestamp '2014-05-20 10:01:39.345'
)
/
insert into plch_result values (
   'Denmark', 'Olsen'     , timestamp '2014-05-20 10:02:27.456'
)
/
insert into plch_result values (
   'Denmark', '**FINISH**', timestamp '2014-05-20 10:03:18.567'
)
/

insert into plch_result values (
   'USA'    , 'James'     , timestamp '2014-05-20 10:00:00.000'
)
/
insert into plch_result values (
   'USA'    , 'Norton'    , timestamp '2014-05-20 10:00:47.678'
)
/
insert into plch_result values (
   'USA'    , 'Smith'     , timestamp '2014-05-20 10:01:34.789'
)
/
insert into plch_result values (
   'USA'    , 'Ohare'     , timestamp '2014-05-20 10:02:21.891'
)
/
insert into plch_result values (
   'USA'    , '**FINISH**', timestamp '2014-05-20 10:03:03.912'
)
/

insert into plch_result values (
   'Russia' , 'Jakowskij' , timestamp '2014-05-20 10:00:00.000'
)
/
insert into plch_result values (
   'Russia' , 'Nivorskij' , timestamp '2014-05-20 10:00:48.123'
)
/
insert into plch_result values (
   'Russia' , 'Svlatko'   , timestamp '2014-05-20 10:01:34.234'
)
/
insert into plch_result values (
   'Russia' , 'Ogarskij'  , timestamp '2014-05-20 10:02:22.345'
)
/
insert into plch_result values (
   'Russia' , '**FINISH**', timestamp '2014-05-20 10:03:06.456'
)
/

commit;

select * from plch_result;

/*
The timer values is recorded for each athlete at the start of his split (a split is the term for each 400 meter part of the relay.) 
The end time for the athlete is the starting time of the next athlete. When the fourth and last athlete of the team reaches the finish line, 
the timer value is recorded in a row with the dummy value **FINISH** in the athlete column, so the split time of the last athlete as well as the
team total time can be calculated.

We wish a report with one row per team showing the total time, average split time, athlete and split time of the fastest split and athlete and
split time of the slowest split. The report should be ordered by team total time.

Which of the choices contain a query giving such a report with this desired output:
TEAM       AVERAGE                       TOTAL_TIME
---------- ----------------------------- -----------------------------
FAST       FAST_TIME
---------- -----------------------------
SLOW       SLOW_TIME
---------- -----------------------------
USA        +000000000 00:00:45.978000000 +000000000 00:03:03.912
Ohare      +000000000 00:00:42.021
James      +000000000 00:00:47.678

Russia     +000000000 00:00:46.614000000 +000000000 00:03:06.456
Ogarskij   +000000000 00:00:44.111
Jakowskij  +000000000 00:00:48.123

Denmark    +000000000 00:00:49.641750000 +000000000 00:03:18.567
Nielsen    +000000000 00:00:48.111
Jensen     +000000000 00:00:51.234
Note: The above output has been produced using these SQL*Plus formatting commands:
*/

WITH temp AS
  (SELECT indtime.*,
    '+00 ' ||'00:' ||'00:'
    ||AVG(extract(second FROM intrvl) + extract(minute FROM intrvl) * 60 --converting to seconds
    ) over(partition BY team) AS AVG,
    max(timer) over(partition BY team) - min(timer) over(partition BY team) AS Total_Time
  FROM
    (SELECT r.*,
      lead(timer,1) over(partition BY team order by timer) - timer AS intrvl
    FROM plch_result r
    ) indtime
  ),
  temp2 AS
  (SELECT temp.*,
    dense_rank() over(partition BY team order by intrvl, athlete) rnk
  FROM temp
  ),
  temp3 AS
  (SELECT temp.*,
    dense_rank() over(partition BY team order by intrvl DESC nulls last, athlete ) drnk
  FROM temp
  )
SELECT t1.team, t1.total_time as Total_Time, t1.avg AS average, t1.athlete AS fast, t1.intrvl AS fast_time, t2.athlete AS slow, t2.intrvl AS slow_time
  FROM temp2 t1 JOIN temp3 t2 ON t1.rnk = t2.drnk AND t1.team  = t2.team
  WHERE t1.rnk = 1 AND t2.drnk  = 1
  order by Total_Time;
  
/*
select timer, extract(second from timer), 
extract(minute from timer)* 60, 
extract(hour from timer)* 60* 60, 
extract(day from timer)* 60* 60*24 
from plch_result;
*/

select team
     , max(total_time) / count(*) average
     , max(total_time) total_time
     , min(athlete) keep (dense_rank first order by split_time) fast
     , min(split_time) fast_time
     , max(athlete) keep (dense_rank last order by split_time) slow
     , max(split_time) slow_time
  from (
   select team
        , athlete
        , lead(timer) over (
             partition by team
             order by timer
          ) - timer split_time
        , max(timer) over (
             partition by team
          ) - min(timer) over (
             partition by team
          ) total_time
     from plch_result
       )
 where athlete != '**FINISH**'
 group by team
 order by total_time;

--Below query not recommended
select team
     , max(total_time) / count(*) average
     , max(total_time) total_time
     , min(athlete) keep (dense_rank first order by split_time) fast
     , min(split_time) fast_time
     , max(athlete) keep (dense_rank last order by split_time) slow
     , max(split_time) slow_time
  from (
   select team
        , athlete
        , (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
                and p.timer > plch_result.timer
          ) - timer split_time
        , (
             select timer
               from plch_result p
              where p.team = plch_result.team
                and p.athlete = '**FINISH**'
          ) - (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
          ) total_time
     from plch_result
       )
 where athlete != '**FINISH**'
 group by team
 order by total_time;
 
/*
   select team
        , athlete
        , timer
        , (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
                and p.timer > plch_result.timer
          )  split_time
        
     from plch_result
*/    

--Below query not recommended
select team
     , (max(timer) - min(timer)) / (count(*) - 1) average
     , max(timer) - min(timer) total_time
     , min(athlete) keep (
          dense_rank first order by
          (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
                and p.timer > plch_result.timer
          ) - timer
       ) fast
     , min(
          (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
                and p.timer > plch_result.timer
          ) - timer
       ) fast_time
     , max(athlete) keep (
          dense_rank last order by
          (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
                and p.timer > plch_result.timer
          ) - timer NULLS FIRST
       ) slow
     , max(
          (
             select min(timer)
               from plch_result p
              where p.team = plch_result.team
                and p.timer > plch_result.timer
          ) - timer
       ) slow_time
  from plch_result
 group by team
 order by total_time;
 
