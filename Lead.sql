create table plch_movies (
   category varchar2(10) not null
 , name     varchar2(20) not null
 , votes    integer      not null
 , constraint plch_movies_pk primary key (category, name)
)
/

insert into plch_movies values ('Sci-Fi' , 'Star Wars' , 700)
/
insert into plch_movies values ('Sci-Fi' , 'The Matrix', 500)
/
insert into plch_movies values ('Sci-Fi' , 'Aliens'    , 500)
/
insert into plch_movies values ('Western', 'Unforgiven', 600)
/
insert into plch_movies values ('Western', 'High Noon' , 400)
/
insert into plch_movies values ('Western', 'Rio Bravo' , 300)
/
commit;

select * from plch_movies;

--I want to show movies in order of category alphabetically, votes descending, and if two movies in same category has identical
--votes they should be sorted alphabetically by name.

--But the client software that will show the results of the query needs to know which is the last row within each category,
--so the software can place a big graphical divider between each category.

--So I need to include a column LAST_ROW in the output with value 'Y' for the last row in each category and value NULL for other rows. 
--For that purpose I have this incomplete query:

select category, name, votes, case lead(category,1) over(order by category, votes desc, name)
                                    when lead(category,0) over(order by category, votes desc, name) then null
                                    else 'Y'
                                    end Last_row
from plch_movies;

select category
     , name
     , votes
     , lead(null, 1, 'Y') over (
          partition by category
          order by votes desc, name
       ) last_row

  from plch_movies
 order by category
        , votes desc
        , name;
        
select category
     , name
     , votes
          , lag(null, 1, 'Y') over (
          partition by category
          order by votes, name desc
       ) last_row
  from plch_movies
 order by category
        , votes desc
        , name; 
        
select category
     , name
     , votes
          , case
          when lead(name) over (
                  partition by category
                  order by votes desc, name
               ) is null then
             'Y'
       end last_row
  from plch_movies
 order by category
        , votes desc
        , name;
        
select category
     , name
     , votes
          , nvl2(
          lead(name) over (
             partition by category
             order by votes desc, name
          )
        , null
        , 'Y'
       ) last_row
  from plch_movies
 order by category
        , votes desc
        , name;
        
select category
     , name
     , votes
              , case
          when row_number() over (
                  partition by category
                  order by votes, name desc
               ) = 1 then
             'Y'
       end last_row
  from plch_movies
 order by category
        , votes desc
        , name;
        
select category
     , name
     , votes
     , case
          when row_number() over (
                  partition by category
                  order by votes desc, name
               ) = count(*) over (
                  partition by category
               ) then
             'Y'
       end last_row
  from plch_movies
 order by category
        , votes desc
        , name;
        
