create table plch_alarm_log (
   alarm_name  varchar2(10)
 , alarm_time  date
)
/

insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-01 12:12:12','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-01 23:45:00','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-01 23:56:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 00:01:23','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 00:02:34','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 00:05:55','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'SIDE_DOOR' , to_date('2013-01-02 05:06:07','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'SIDE_DOOR' , to_date('2013-01-02 05:11:11','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'SIDE_DOOR' , to_date('2013-01-02 05:16:27','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'SIDE_DOOR' , to_date('2013-01-02 05:26:37','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 05:33:33','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 12:01:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 12:11:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 12:21:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 12:31:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 12:41:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 12:51:30','YYYY-MM-DD HH24:MI:SS')
)
/
insert into plch_alarm_log values (
   'FRONT_DOOR', to_date('2013-01-02 13:33:33','YYYY-MM-DD HH24:MI:SS')
)
/
commit;

select ALARM_NAME, to_date(ALARM_TIME,'YYYY-MM-DD HH24:MI:SS') from plch_alarm_log;

/*
Recently boss had me develop a SQL statement to only show alarm times which are followed by at least 2 alarms on the same alarm name within a half hour. 
I made this SQL:

select alarm_name
     , alarm_time
  from (
   select alarm_name
        , alarm_time
        , count(*) over (
             partition by alarm_name
             order by alarm_time
             range between current row
                       and interval '30' minute following
          ) half_hour_count
     from plch_alarm_log
       )
 where half_hour_count >= 3
 order by alarm_time
        , alarm_name
/
But now boss says: "Look at this output, that is not what I want:"

ALARM_NAME ALARM_TIME
---------- -------------------
FRONT_DOOR 2013-01-01 23:45:00
FRONT_DOOR 2013-01-01 23:56:30
FRONT_DOOR 2013-01-02 00:01:23
SIDE_DOOR  2013-01-02 05:06:07
SIDE_DOOR  2013-01-02 05:11:11
FRONT_DOOR 2013-01-02 12:01:30
FRONT_DOOR 2013-01-02 12:11:30
FRONT_DOOR 2013-01-02 12:21:30
FRONT_DOOR 2013-01-02 12:31:30
So we came up with a new specification:

Whenever 2 alarms on the same alarm_name are within 15 minutes of each other, they are defined as belonging to the same incident. 
Even if an alarm is logged every 10 minutes for several hours, they are all the same incident. Only when there is a break in alarms of at least 15 minutes 
is it defined as a new incident.

This definition gives us this incident report for the above data:

ALARM_NAME     ALARMS INCIDENT_START      INCIDENT_STOP
---------- ---------- ------------------- -------------------
FRONT_DOOR          1 2013-01-01 12:12:12 2013-01-01 12:12:12
FRONT_DOOR          5 2013-01-01 23:45:00 2013-01-02 00:05:55
SIDE_DOOR           4 2013-01-02 05:06:07 2013-01-02 05:26:37
FRONT_DOOR          1 2013-01-02 05:33:33 2013-01-02 05:33:33
FRONT_DOOR          6 2013-01-02 12:01:30 2013-01-02 12:51:30
FRONT_DOOR          1 2013-01-02 13:33:33 2013-01-02 13:33:33
The 6 alarms on FRONT_DOOR January 2nd from 12:01:30 to 12:51:30 are all in the same 50 minute long incident, because those 6 alarms are just 10 minutes apart.
Then there is break from 12:51:30 until 13:33:33 that is longer than 15 minutes, so that is the start of a new incident.

Then what boss desires is an incident report of incidents having at least 3 alarms.

Which of the choices gives this desired output:

ALARM_NAME     ALARMS INCIDENT_START      INCIDENT_STOP
---------- ---------- ------------------- -------------------
FRONT_DOOR          5 2013-01-01 23:45:00 2013-01-02 00:05:55
SIDE_DOOR           4 2013-01-02 05:06:07 2013-01-02 05:26:37
FRONT_DOOR          6 2013-01-02 12:01:30 2013-01-02 12:51:30
*/

with temp as(
select alarm_name
     , alarm_time
     , flag
     , sum(flag) over(partition by alarm_name order by alarm_time)
       group_no
  from (
   select alarm_name
        , alarm_time
        , case when count(*) over (
             partition by alarm_name
             order by alarm_time
             range between interval '15' minute preceding
                       and current row
          ) > 1 then 0
          else 1
          end
          flag
     from plch_alarm_log
       )
  order by alarm_name
         , alarm_time
)
select alarm_name, count(*) alarms, min(alarm_time) incident_start, max(alarm_time) incident_stop
  from temp 
  group by alarm_name, group_no 
  having count(*) >= 3
  order by min(alarm_time), alarm_name;
         
select alarm_name
     , count(*) alarms
     , min(alarm_time) incident_start
     , max(alarm_time) incident_stop
  from (
   select alarm_name
        , alarm_time
        , sum(start_of_group) over (
             partition by alarm_name
             order by alarm_time
             rows between unbounded preceding and current row
          ) group_no
     from (
      select alarm_name
           , alarm_time
           , case when lag(alarm_time) over (
                          partition by alarm_name 
                          order by alarm_time
                       ) >= alarm_time - interval '15' minute
                  then 0
                  else 1
             end start_of_group
        from plch_alarm_log
          )
       )
 group by alarm_name
        , group_no
having count(*) >= 3
 order by min(alarm_time)
        , alarm_name;
        
with alarms as (
   select alarm_name
        , alarm_time
        , case
             when exists (
                     select null
                       from plch_alarm_log p2
                      where p2.alarm_name =  p1.alarm_name
                        and p2.alarm_time >= p1.alarm_time
                                              - interval '15' minute
                        and p2.alarm_time <  p1.alarm_time
                  )
             then null
             else alarm_time
          end first_in_group
     from plch_alarm_log p1
)
select alarm_name
     , count(*) alarms
     , group_time incident_start
     , max(alarm_time) incident_stop
  from (
   select alarm_name
        , alarm_time
        , nvl(
             first_in_group
           , (
                select max(first_in_group)
                  from alarms a2
                 where a2.alarm_name = a1.alarm_name
                   and a2.alarm_time < a1.alarm_time
                   and a2.first_in_group is not null
             )
          ) group_time
     from alarms a1
       )
 group by alarm_name
        , group_time
having count(*) >= 3
 order by min(alarm_time)
        , alarm_name;
        

select alarm_name
     , count(*) alarms
     , group_time incident_start
     , max(alarm_time) incident_stop
  from (
   select alarm_name
        , alarm_time
        , last_value(first_in_group ignore nulls) over (
             partition by alarm_name
             order by alarm_time
             rows between unbounded preceding and current row
          ) group_time
     from (
      select alarm_name
           , alarm_time
           , nvl2(
                last_value(alarm_time) over (
                   partition by alarm_name
                   order by alarm_time
                   range between interval '15' minute preceding
                             and interval '1' second preceding
                )
              , null
              , alarm_time
             ) first_in_group
        from plch_alarm_log
          )
       )
 group by alarm_name
        , group_time
having count(*) >= 3
 order by min(alarm_time)
        , alarm_name;
        
