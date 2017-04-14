create table plch_visits (
   country  varchar2(3)
 , month    date
 , visits   integer
)
/

insert into plch_visits values ('DK' , date '2014-10-01',  45)
/
insert into plch_visits values ('DK' , date '2014-11-01',  40)
/
insert into plch_visits values ('DK' , date '2014-12-01',  60)
/
insert into plch_visits values ('DK' , date '2015-01-01',  50)
/
insert into plch_visits values ('DK' , date '2015-02-01',  75)
/
insert into plch_visits values ('DK' , date '2015-03-01',  65)
/
insert into plch_visits values ('USA', date '2014-10-01', 100)
/
insert into plch_visits values ('USA', date '2014-11-01',  80)
/
insert into plch_visits values ('USA', date '2014-12-01',  95)
/
insert into plch_visits values ('USA', date '2015-01-01',  90)
/
insert into plch_visits values ('USA', date '2015-02-01',  70)
/
insert into plch_visits values ('USA', date '2015-03-01',  85)
/
insert into plch_visits values ('USA', date '2015-04-01',  null)
/
commit;

select * from plch_visits;

/*
I wish to see the trend of the visits as a linear regression line, so I need a way to calculate the data that will allow me to create this graph:

Linear regression graph
GRAPH NOT HERE
The grey and blue lines are the data in the table. The gold and red lines are the linear regression lines.

Which of the choices calculates the values for those linear regression lines, producing this desired output:

COU MONTH       VISITS  LINEAR
--- ------- ---------- -------
DK  2014-10         45   41.90
DK  2014-11         40   47.48
DK  2014-12         60   53.05
DK  2015-01         50   58.62
DK  2015-02         75   64.19
DK  2015-03         65   69.76
USA 2014-10        100   94.52
USA 2014-11         80   91.38
USA 2014-12         95   88.24
USA 2015-01         90   85.10
USA 2015-02         70   81.95
USA 2015-03         85   78.81
Note: Very small rounding errors in the actual value of LINEAR may be accepted as correct, 
just as long it is correct to at least two decimals so the output above is produced exactly when using SQL*Plus formatting:
*/

select country
     , month
     , visits
     , regr_intercept(visits, yearnum * 12 + monthnum) over (
          partition by country
       ) + (
          regr_slope(visits, yearnum * 12 + monthnum) over (
             partition by country
          ) * (yearnum * 12 + monthnum)
       ) linear
  from (
   select country
        , month
        , visits
        , to_number(to_char(month,'YYYY')) yearnum
        , to_number(to_char(month,'MM')) monthnum
     from plch_visits
  )
 order by country
        , month;
        
/*
select country
     , month
     , visits
     , yearnum * 12 + monthnum as mnths
     , regr_intercept(visits, yearnum * 12 + monthnum) over (
          partition by country
       ) 
        intercept
     ,  regr_slope(visits, yearnum * 12 + monthnum) over (
             partition by country
          ) * (yearnum * 12 + monthnum)
        slope
  from (
   select country
        , month
        , visits
        , to_number(to_char(month,'YYYY')) yearnum
        , to_number(to_char(month,'MM')) monthnum
     from plch_visits
  )
 order by country
        , month;
*/
/*REGR_COUNT
select country
     , month
     , visits
     , yearnum * 12 + monthnum as mnths
     , regr_intercept(visits, yearnum * 12 + monthnum) over (
          partition by country
       ) 
        intercept
     ,  regr_count(visits, yearnum * 12 + monthnum) over (
             partition by country
          )
        slope
  from (
   select country
        , month
        , visits
        , to_number(to_char(month,'YYYY')) yearnum
        , to_number(to_char(month,'MM')) monthnum
     from plch_visits
  )
 order by country
        , month;
*/

select country
     , month
     , visits
     , regr_intercept(visits, julian) over (
          partition by country
       ) + (
          regr_slope(visits, julian) over (
             partition by country
          ) * julian
       ) linear
  from (
   select country
        , month
        , visits
        , to_number(to_char(month,'J')) julian
     from plch_visits
  )
 order by country
        , month;
        
select country
     , month
     , visits
     , regr_intercept(visits, x_axis) over (
          partition by country
       ) + (
          regr_slope(visits, x_axis) over (
             partition by country
          ) * (x_axis)
       ) linear
  from (
   select country
        , month
        , visits
        , (to_number(to_char(month,'YYYY')) - 2015) * 12
            + to_number(to_char(month,'MM')) x_axis
     from plch_visits
  )
 order by country
        , month;
        
select country
     , month
     , visits
     , regr_intercept(visits, x_axis) over (
          partition by country
       ) + (
          regr_slope(visits, x_axis) over (
             partition by country
          ) * (x_axis)
       ) linear
  from (
   select country
        , month
        , visits
        , months_between(month, date '2015-01-01') x_axis
     from plch_visits
  )
 order by country
        , month;
        
