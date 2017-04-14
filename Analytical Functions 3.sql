create table plch_children (
   name     varchar2(10) primary key
 , address  varchar2(20) not null
)
/
create table plch_route (
   leg      integer      primary key
 , address  varchar2(20) not null
 , distance integer      not null
)
/

insert into plch_children values ('Caroline' , '1 Santa Drive')
/
insert into plch_children values ('Christina', '7 Advent Circle')
/
insert into plch_children values ('Claudia'  , '2 Christmas Avenue')
/
insert into plch_children values ('Colleen'  , '4 Elf Lane')
/
insert into plch_children values ('Cameron'  , '6 Claus Causeway')
/
insert into plch_children values ('Chester'  , '3 Rudolph Street')
/
insert into plch_children values ('Clifford' , '8 Xmas Way')
/
insert into plch_children values ('Connor'   , '5 Reindeer Route')
/

insert into plch_route values (1, '1 Santa Drive'     , 75)
/                              
insert into plch_route values (2, '2 Christmas Avenue', 25)
/                              
insert into plch_route values (3, '3 Rudolph Street'  , 40)
/                              
insert into plch_route values (4, '4 Elf Lane'        , 10)
/                              
insert into plch_route values (5, '5 Reindeer Route'  , 85)
/
insert into plch_route values (6, '6 Claus Causeway'  , 35)
/                              
insert into plch_route values (7, '7 Advent Circle'   , 50)
/                              
insert into plch_route values (8, '8 Xmas Way'        , 90)
/                              
insert into plch_route values (9, 'North Pole'        , 45)
/                              

commit
/
/*
The first leg in the route table is from Santas home on the North Pole to the first child, and the last (9th) leg is from the last child and back home.

The Reindeer Union requires that the reindeer get a break for every 200 miles traveled, so the flight plan must show the necessary breaks along the way.

Which of the choices make a flight plan following Santas planned route including the breaks for the reindeer giving this desired output:

      STOP ADDRESS              NAME            MILES
---------- -------------------- ---------- ----------
         1 1 Santa Drive        Caroline           75
         2 2 Christmas Avenue   Claudia           100
         3 3 Rudolph Street     Chester           140
         4 4 Elf Lane           Colleen           150
         5 BREAK                                  200
         6 5 Reindeer Route     Connor            235
         7 6 Claus Causeway     Cameron           270
         8 7 Advent Circle      Christina         320
         9 BREAK                                  400
        10 8 Xmas Way           Clifford          410
        11 North Pole                             455
*/

select * from plch_children;

select * from plch_route;


with temp as (
select c.address, c.name, sum(distance) over(order by r.leg) sum from plch_children c, plch_route r where c.address = r.address
) select * from temp 
union all
select r.address, ' ', r.distance + (select max(sum) from temp) sum from plch_route r where leg = 9;

select c.address, c.name, sum(distance) over(order by r.leg) sum, level 
from plch_children c, plch_route r 
where c.address = r.address
start with leg = 1
connect by prior r.leg = r.leg - 1;

select row_number() over (
          order by rt.miles
       ) stop
     , rt.address
     , c.name
     , rt.miles
  from (
   select r.address
        , sum(r.distance) over (
             order by r.leg
             rows between unbounded preceding and current row
          ) miles
     from plch_route r
    union all
   select 'BREAK' address
        , level * 200 miles
     from dual
   connect by level < (select sum(distance) / 200 from plch_route)
  ) rt
  left outer join plch_children c
      on c.address = rt.address
 order by rt.miles;
 
 select level 
     from dual
   connect by level < 2.5;
   
select row_number() over (
          order by rt.miles, dummy.num
       ) stop
     , case dummy.num
          when 1 then rt.address
                 else 'BREAK'
       end address
     , c.name
     , case dummy.num
          when 1 then rt.miles
                 else (ceil(rt.miles / 200) + dummy.num - 2) * 200
       end miles
  from (
   select r.address
        , sum(r.distance) over (
             order by r.leg
             rows between unbounded preceding and current row
          ) miles
        , sum(r.distance) over (
             order by r.leg
             rows between unbounded preceding and 1 following
          ) miles_next
     from plch_route r
  ) rt cross join lateral (
   select level num
     from dual
   connect by level <= 1 + ceil(rt.miles_next / 200)
                         - ceil(rt.miles / 200)
  ) dummy
  left outer join plch_children c
      on c.address = rt.address
      and dummy.num = 1
 order by miles;