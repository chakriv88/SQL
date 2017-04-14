create table plch_recipes (
   recipe_id   integer      primary key
 , recipe_name varchar2(20) not null
)
/

create table plch_ingredients (
   recipe_id   integer      not null
      references plch_recipes(recipe_id)
 , ingredient  varchar2(20) not null
 , unique (recipe_id, ingredient)
)
/

insert into plch_recipes values (100, 'Cookies')
/
insert into plch_recipes values (200, 'Brownies')
/
insert into plch_recipes values (300, 'Pancakes')
/

insert into plch_ingredients values (100, 'Chocolate')
/
insert into plch_ingredients values (100, 'Eggs')
/
insert into plch_ingredients values (100, 'Flour')
/
insert into plch_ingredients values (100, 'Sugar')
/
insert into plch_ingredients values (100, 'Butter')
/

insert into plch_ingredients values (200, 'Cocoa')
/
insert into plch_ingredients values (200, 'Flour')
/
insert into plch_ingredients values (200, 'Sugar')
/
insert into plch_ingredients values (200, 'Butter')
/

insert into plch_ingredients values (300, 'Flour')
/
insert into plch_ingredients values (300, 'Eggs')
/
insert into plch_ingredients values (300, 'Milk')
/

commit;

select * from plch_ingredients;
select * from plch_recipes;

/*
In my kitchen I have the ingredients Flour, Sugar and Butter.
I wish to know which recipes use all of my available ingredients, and for each of those recipes I want to know what ingredients I am missing.

For the data shown I want to see Cookies with missing ingredients Chocolate and Eggs, I want to see Brownies with missing ingredient Cocoa, 
but I do not wish to see Pancakes because that recipe does not use Sugar or Butter.
*/

select * from plch_recipes r natural join plch_ingredients i;

--cost of below is 27
with temp as (
select recipe_name, ingredient, case when ingredient in ('Flour', 'Sugar', 'Butter') then 1
                                    else 0
                                    end as Ihave
    from plch_recipes natural join plch_ingredients
),
temp2 as (
select t.*, case sum(Ihave) over(partition by recipe_name) 
              when 3 then (case ihave when 1 then 'Not Missing'
                                    else 'Missing'
                                    end )
              else null 
              end as status
              from temp t
)
select recipe_name, ingredient as missing_ingredient
from temp2 where status in ('Missing');

--cost of below is 28
with temp as (
select recipe_name, ingredient, case when ingredient in ('Flour', 'Sugar', 'Butter') then 1
                                    else 0
                                    end as Ihave
    from plch_recipes natural join plch_ingredients
)
select recipe_name, ingredient as missing_ingredient from temp t1 
where (select sum(ihave) from temp t2 where t1.recipe_name = t2.recipe_name group by recipe_name) =3 and ihave = 0;

--below is very very costly
with kitchen as (
   select 'Flour' ingredient from dual union all
   select 'Sugar' ingredient from dual union all
   select 'Butter' ingredient from dual
)
select recipe_name
     , ingredient missing_ingredient
  from ( 
   select r.recipe_name
        , i.ingredient
        , nvl2(k.ingredient,'Y','N') is_in_kitchen
        , count(k.ingredient) over (partition by r.recipe_id) kitchen_count
     from plch_recipes r
     join plch_ingredients i
          on i.recipe_id = r.recipe_id
     left outer join kitchen k
          on k.ingredient = i.ingredient
       )
 where kitchen_count =
       (
         select count(*)
           from kitchen
       )
   and is_in_kitchen = 'N'
 order by recipe_name
        , ingredient;
        
create type plch_ingredients_type as table of varchar2(20)
/

/*
with kitchen as (
   select plch_ingredients_type(
             'Flour','Sugar','Butter'
          ) ingredients
     from dual
), recipes as (
   select r.recipe_id
        , r.recipe_name
        , cast(
             multiset(
                select i.ingredient
                  from plch_ingredients i
                 where i.recipe_id = r.recipe_id
             ) as plch_ingredients_type
          ) ingredients
     from plch_recipes r
)
select r.recipe_name
     , r.ingredients multiset except k.ingredients missing_ingredients 
  from kitchen k
  join recipes r
       on k.ingredients submultiset of r.ingredients
 order by r.recipe_name;*/