create table plch_worldcup (
   nation   varchar2(20)   primary key
 , qscore   number         unique
)
/

insert into plch_worldcup values ('Argentina'   , 101)
/
insert into plch_worldcup values ('Belgium'     , 204)
/
insert into plch_worldcup values ('Canada'      , 306)
/
insert into plch_worldcup values ('Denmark'     , 396)
/
insert into plch_worldcup values ('Estonia'     , 123)
/
insert into plch_worldcup values ('Finland'     , 226)
/
insert into plch_worldcup values ('Germany'     , 329)
/
insert into plch_worldcup values ('Honduras'    , 432)
/
insert into plch_worldcup values ('Indonesia'   , 148)
/
insert into plch_worldcup values ('Jamaica'     , 256)
/
insert into plch_worldcup values ('Korea'       , 364)
/
insert into plch_worldcup values ('Luxembourg'  , 472)
/
insert into plch_worldcup values ('Morocco'     , 161)
/
insert into plch_worldcup values ('Nigeria'     , 301)
/
insert into plch_worldcup values ('Oman'        , 383)
/
insert into plch_worldcup values ('Portugal'    , 494)
/
commit;

select * from plch_worldcup;

with temp as (
select nation, qscore, ntile(4) over(order by qscore desc) seedlayer from plch_worldcup
)
select temp.nation, temp.seedlayer, row_number() over(partition by seedlayer order by nation) rown
from temp
order by rown, seedlayer;

select nation
     , row_number() over (
          partition by seed_layer
          order by dbms_random.value()
       ) group_number
     , seed_layer
  from (
   select nation
        , 5 - width_bucket(qscore, 100, 499.9999999, 4) seed_layer
     from plch_worldcup
  )
 order by group_number, seed_layer;
 
select qscore,width_bucket(qscore, 100, 500, 4) from plch_worldcup order by qscore;
--divides into 4 buckets between 100 to 500 with 100 interval

select nation
     , row_number() over (
          partition by seed_layer
          order by dbms_random.value()
       ) group_number
     , seed_layer
  from (
   select nation
        , trunc( (row_number() over (order by qscore desc) - 1) / 4 ) + 1 seed_layer
     from plch_worldcup
  )
 order by group_number, seed_layer;
 
select nation
     , row_number() over (
          partition by seed_layer
          order by dbms_random.value()
       ) group_number
     , seed_layer
  from (
   select nation
        , ceil(row_number() over (order by qscore desc) / 4 ) seed_layer
     from plch_worldcup
  )
 order by group_number, seed_layer;
 
--below is not correct
/*select nation
     , row_number() over (
          partition by seed_layer
          order by dbms_random.value()
       ) group_number
     , seed_layer
  from (
   select nation
        , ceil( 4 * percent_rank() over (order by qscore desc) )
 seed_layer
     from plch_worldcup
  )
 order by group_number, seed_layer;*/
 
select percent_rank() over (order by qscore desc) as perc
from plch_worldcup
order by perc;

select ceil(4* cume_dist() over (order by qscore desc)) cume
from plch_worldcup
order by cume;