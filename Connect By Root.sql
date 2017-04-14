create table plch_tree (
   id     integer  primary key
 , name   varchar2(10)
 , parent integer references plch_tree
)
/

insert into plch_tree values (100, 'Master'   , null)
/
insert into plch_tree values (101, 'Project1' , null)
/
insert into plch_tree values (211, 'Customers', 100)
/
insert into plch_tree values (212, 'Employees', 100)
/
insert into plch_tree values (321, 'Working'  , 211)
/
insert into plch_tree values (322, 'Finished' , 211)
/
insert into plch_tree values (431, 'Minor'    , 321)
/
insert into plch_tree values (432, 'Major'    , 321)
/
insert into plch_tree values (511, 'Customers', 101)
/
insert into plch_tree values (521, 'Finished' , 511)
/
insert into plch_tree values (531, 'Major'    , 521)
/
insert into plch_tree values (541, 'European' , 531)
/
commit;

select * from plch_tree;

select SYS_CONNECT_BY_PATH(name,'/'), id, prior name as pname 
from plch_tree
connect by prior id = parent
start with parent is null;

select case when length(SYS_CONNECT_BY_PATH(name,'/')) > 30 then '/'|| connect_by_root(name) || '/../../' || name 
            else SYS_CONNECT_BY_PATH(name,'/')
            end path,
            id
  from plch_tree
  start with parent is null
  connect by prior id = parent
  order siblings by  id;
  
select case
          when length(SYS_CONNECT_BY_PATH(name, '/')) <= 30
          then SYS_CONNECT_BY_PATH(name, '/')
          else '/' || CONNECT_BY_ROOT name
               || rpad('/', (level - 2) * 3 + 1, '../') || name
       end path
     , id
  from plch_tree
 start with parent is null
connect by parent = prior id
 order siblings by id;
 
select rpad('/', 3, '../') from dual;

