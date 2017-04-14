create table plch_ticking (
   ticking_time   date        unique
 , tick_or_tock   varchar2(4)
)
/

/* Date format for implicit conversion in INSERT statements */

alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'
/

insert into plch_ticking values ('2013-10-19 00:00:01', 'TICK')
/
insert into plch_ticking values ('2013-10-19 00:00:02', 'TICK')
/
insert into plch_ticking values ('2013-10-19 00:00:03', 'TOCK')
/
insert into plch_ticking values ('2013-10-19 00:00:04', 'TICK')
/
insert into plch_ticking values ('2013-10-19 00:00:05', 'TOCK')
/
insert into plch_ticking values ('2013-10-19 00:00:06', 'TOCK')
/
insert into plch_ticking values ('2013-10-19 00:00:07', 'TOCK')
/
insert into plch_ticking values ('2013-10-19 00:00:08', 'TOCK')
/
insert into plch_ticking values ('2013-10-19 00:00:09', 'TICK')
/
insert into plch_ticking values ('2013-10-19 00:00:10', 'TOCK')
/
commit
/

select * from plch_ticking;

--I'd like a list of ticks and tocks along with how many seconds since the last tick.

select ticking_time, tick_or_tock, case tick_or_tock when 'TICK' then 0 else 1 end tick from plch_ticking;

select to_char(t.ticking_time,'HH24:MI:SS') time
     , t.tick_or_tock
     , ceil((t.ticking_time
        -                     lag(
             case t.tick_or_tock
                when 'TICK' then t.ticking_time
                else null
             end
             ignore nulls --ignore nulls looks for previous non null value
          ) over (
             order by t.ticking_time
          )
       ) * (24*60*60)) seconds_since_last_tick
  from plch_ticking t
 order by t.ticking_time;

select lag(
             case t.tick_or_tock
                when 'TICK' then t.ticking_time
                else null
             end
          ) over (
             order by t.ticking_time
          ) "without ignore null",
      lag(
             case t.tick_or_tock
                when 'TICK' then t.ticking_time
                else null
             end
             ignore nulls
          ) over (
             order by t.ticking_time
          ) "with ignore null"
  from plch_ticking t
 order by t.ticking_time;

select to_char(t.ticking_time,'HH24:MI:SS') time
     , t.tick_or_tock
     , ceil((t.ticking_time
        -  last_value(
             case t.tick_or_tock
                when 'TICK' then t.ticking_time
                else null
             end
          ) ignore nulls over (
             order by t.ticking_time
             rows between unbounded preceding and 1 preceding
          )
       ) * (24*60*60)) seconds_since_last_tick
  from plch_ticking t
 order by t.ticking_time;
 
select last_value(
             case t.tick_or_tock
                when 'TICK' then t.ticking_time
                else null
             end
          ) ignore nulls over (
             order by t.ticking_time
             rows between unbounded preceding and 1 preceding
          )
        seconds_since_last_tick
  from plch_ticking t
 order by t.ticking_time;
 
