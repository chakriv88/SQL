create table plch_regions (
   id          varchar2(4) primary key
 , name        varchar2(30)
)
/

create table plch_countries (
   id          varchar2(3) primary key
 , name        varchar2(30)
 , region_id   varchar2(4) not null references plch_regions
)
/

create table plch_players (
   id          integer     primary key
 , name        varchar2(30)
 , country_id  varchar2(3) not null references plch_countries
 , score       number
)
/

insert into plch_regions values ('AMER', 'North-/South America')
/
insert into plch_regions values ('ASOC', 'Asia/Oceania')
/
insert into plch_regions values ('EMEA', 'Europe/Middle East/Africa')
/

insert into plch_countries values ('CHL', 'Chile'      , 'AMER')
/
insert into plch_countries values ('USA', 'USA'        , 'AMER')
/
insert into plch_countries values ('IDN', 'Indonesia'  , 'ASOC')
/
insert into plch_countries values ('NZL', 'New Zealand', 'ASOC')
/
insert into plch_countries values ('DNK', 'Denmark'    , 'EMEA')
/
insert into plch_countries values ('TCD', 'Chad'       , 'EMEA')
/

insert into plch_players values (11, 'Noelle Barahona', 'CHL', 440)
/
insert into plch_players values (12, 'Michael Phelps' , 'USA', 440)
/
insert into plch_players values (13, 'Liliyana Natsir', 'IDN', 450)
/
insert into plch_players values (14, 'Hamish Bond'    , 'NZL', 410)
/
insert into plch_players values (15, 'Joachim Olsen'  , 'DNK', 460)
/
insert into plch_players values (16, 'Paul Ngadjadoum', 'TCD', 420)
/

commit;

select * from plch_regions;
select * from PLCH_COUNTRIES;
select * from plch_players;

--I'd like to see a list of players and their regions with a total score by region, ranking of the region within the grand total,
--score of the player, and ranking of the player within each region.
--For ranking I want to use the olympic method, so if there are two at rank 1, then rank 2 is skipped and the next get rank 3.

with temp1 as (
select p.name as plname, r.name as regname, sum(score) over(partition by r.name) as total_score,
p.score, rank() over(partition by r.name order by p.score desc) rank_in_region
from plch_players p join plch_countries c on p.country_id = C.id
join PLCH_REGIONS r on C.REGION_ID = R.id
),
temp2 as (
select distinct(regname), rank() over(order by max(total_score) desc)as regrank, max(total_score)
from temp1 group by regname
) 
select temp1.*, temp2.regrank
from temp1 join temp2 on TEMP1.REGNAME = temp2.regname;

select r.name region
     , sum(p.score) over (
          partition by r.id
       ) region_score
     , rank() over (
          order by sum(p.score) over (
                      partition by r.id
                   ) desc
       ) region_rank
     , p.name player
     , p.score
     , rank() over (
          partition by r.id
          order by p.score desc
       ) rank_in_region
  from plch_players p
  join plch_countries c
      on c.id = p.country_id
  join plch_regions r
      on r.id = c.region_id
 order by region_rank
        , r.id
        , rank_in_region
        , p.id;
        
select r.name region
     , sum(p.score) over (
          partition by r.id
       ) region_score
     , rank() over (
          order by ( select sum(p2.score)
                       from plch_countries c2
                       join plch_players p2
                           on p2.country_id = c2.id
                      where c2.region_id = r.id
                   ) desc
       ) region_rank
     , p.name player
     , p.score
     , rank() over (
          partition by r.id
          order by p.score desc
       ) rank_in_region
  from plch_players p
  join plch_countries c
      on c.id = p.country_id
  join plch_regions r
      on r.id = c.region_id
 order by region_rank
        , r.id
        , rank_in_region
        , p.id;

--below is correct        
select r.name region
     , sum(p.score) over (
          partition by r.id
       ) region_score
     , (
         select r2.region_rank
           from (
            select r3.id
                 , rank() over (
                      order by sum(p.score) desc
                   ) region_rank
              from plch_players p
              join plch_countries c
                  on c.id = p.country_id
              join plch_regions r3
                  on r3.id = c.region_id
             group by r3.id
           ) r2
          where r2.id = r.id
       ) region_rank
     , p.name player
     , p.score
     , rank() over (
          partition by r.id
          order by p.score desc
       ) rank_in_region
  from plch_players p
  join plch_countries c
      on c.id = p.country_id
  join plch_regions r
      on r.id = c.region_id
 order by region_rank
        , r.id
        , rank_in_region
        , p.id;
        
with region_scores as (
   select r.id
        , max(r.name) region
        , sum(p.score) region_score
        , rank() over (
             order by sum(p.score) desc
          ) region_rank
     from plch_players p
     join plch_countries c
         on c.id = p.country_id
     join plch_regions r
         on r.id = c.region_id
    group by r.id
)
select rs.region
     , rs.region_score
     , rs.region_rank
     , p.name player
     , p.score
     , rank() over (
          partition by rs.id
          order by p.score desc
       ) rank_in_region
  from plch_players p
  join plch_countries c
      on c.id = p.country_id
  join region_scores rs
      on rs.id = c.region_id
 order by rs.region_rank
        , rs.id
        , rank_in_region
        , p.id;
        
select region, region_score
     , first_value(region_rank ignore nulls) over (
          partition by region_id
          order by rn
       ) region_rank
     , player, score, rank_in_region
  from (
   select region, region_score, rn
        , case rn when 1 then rank() over (
                   partition by rn
                   order by region_score desc
                )
          end region_rank, player, score, rank_in_region, region_id, player_id
     from (
      select r.name region
           , sum(p.score) over (
                partition by r.id
             ) region_score
           , row_number() over (
                partition by r.id
                order by p.score desc
             ) rn, p.name player, p.score
           , rank() over (
                partition by r.id
                order by p.score desc
             ) rank_in_region, r.id region_id, p.id player_id
        from plch_players p
        join plch_countries c
            on c.id = p.country_id
        join plch_regions r
            on r.id = c.region_id
     )
  )
 order by region_rank, region_id, rank_in_region, player_id;
        
select r.name region
     , sum(p.score) over (
          partition by r.id
       ) region_score
     , first_value(
          case when row_number() over (
                  partition by r.id
                  order by p.score desc
               ) = 1 then
                rank() over (
                   partition by row_number() over (
                                   partition by r.id
                                   order by p.score desc
                                )
                   order by region_score desc
                )
          end
          ignore nulls
       ) over (
          partition by region_id
          order by row_number() over (
                      partition by r.id
                      order by p.score desc
                   )
       ) region_rank
     , p.name player
     , p.score
     , rank() over (
          partition by r.id
          order by p.score desc
       ) rank_in_region
  from plch_players p
  join plch_countries c
      on c.id = p.country_id
  join plch_regions r
      on r.id = c.region_id
 order by region_rank
        , rs.id
        , rank_in_region
        , p.id;