create table plch_payments (
   id       integer primary key
 , amount   number
 , result   varchar2(60)
)
/

insert into plch_payments values (101, 149.95, 'CA:49.95,GC:100')
/
insert into plch_payments values (102, 299.00, 'CA:200,CC:99')
/
insert into plch_payments values (103,  39.95, 'CA:10,CC:10,GC:20')
/
insert into plch_payments values (105, 279.50, 'G:300')
/
commit;

select * from plch_payments;

select id
     , amount
     ,   substr(
            result
          , instr(result,':') + 1
          , nvl(
               nullif(instr(result, ','), 0)
             , length(result) + 1
            ) - instr(result, ':') - 1
         )
       + nvl(substr(
            result
          , nullif(instr(result, ':', 1, 2), 0) + 1
          , nvl(
               nullif(instr(result, ',' ,1 ,2), 0)
             , length(result) + 1
            ) - instr(result, ':' ,1 ,2) - 1
         ), 0)
       + nvl(substr(
            result
          , nullif(instr(result, ':', 1, 3), 0) + 1
          , nvl(
               nullif(instr(result, ',', 1, 3), 0)
             , length(result) + 1
            ) - instr(result, ':', 1, 3) - 1
         ), 0)
       pay_sum
  from plch_payments
 order by id;
 
select id
     , amount
     ,   regexp_substr(
            result
          , '[[:alpha:]]{2}:([[:digit:].]+)'
          , 1, 1, null, 1
         )
       + nvl(regexp_substr(
            result
          , '[[:alpha:]]{2}:([[:digit:].]+)'
          , 1, 2, null, 1
         ), 0)
       + nvl(regexp_substr(
            result
          , '[[:alpha:]]{2}:([[:digit:].]+)'
          , 1, 3, null, 1
         ), 0)
       pay_sum
  from plch_payments
 order by id;
 
select id
     , max(amount) amount
     , sum(
          regexp_substr(
             result
           , '[[:alpha:]]{2}:([[:digit:].]+)'
           , 1, level, null, 1
          )
       ) pay_sum
  from plch_payments
 connect by id = prior id
        and instr(result, ',' , 1, level-1) > 0
        and prior dbms_random.value is not null
 group by id
 order by id;