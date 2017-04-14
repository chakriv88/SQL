create table plch_competitions (
   competition_id    integer  primary key
 , question_id       integer
)
/

create table plch_comp_answers (
   user_id           integer
 , competition_id    integer  references plch_competitions
 , played            date
 , score             integer
 , constraint user_comp_played_unique unique (
      user_id, competition_id, played
   )
)
/

insert into plch_competitions values (1, 123)
/
insert into plch_competitions values (2, 234)
/
insert into plch_competitions values (3, 345)
/
insert into plch_competitions values (4, 123)
/

insert into plch_comp_answers values (51, 1, date '2014-01-11', 270)
/
insert into plch_comp_answers values (51, 1, date '2014-01-12', 220)
/
insert into plch_comp_answers values (51, 2, date '2014-01-13', 180)
/
insert into plch_comp_answers values (51, 3, date '2014-01-14', 310)
/
insert into plch_comp_answers values (51, 4, date '2014-01-15', 245)
/

commit;

select * from plch_competitions;
select * from plch_comp_answers;

/*
The same question may appear in multiple competitions (question_id is foreign key to a table plch_questions not shown here.) 
A player may play the same competition multiple times (though not at the exact same second.)

A colleague of mine has written a view intending to enable developers to easily select data that always shows the time and score of the latest 
time a player has played a given competition. For that purpose he has written this view:

create or replace view plch_latest_answers
as
select a.user_id
     , a.competition_id
     , q.question_id
     , a.played
     , a.score
  from plch_comp_answers a
  join plch_competitions q
         on q.competition_id = a.competition_id
 where (a.user_id, q.question_id, a.played) in (
         select a2.user_id
              , q2.question_id
              , max(a2.played)
           from plch_comp_answers a2
           join plch_competitions q2
                  on q2.competition_id = a2.competition_id
          group by a2.user_id
                 , q2.question_id
       )
/
And he tests it with this test select statement:

select l.user_id
     , l.competition_id
     , l.question_id
     , l.played
     , l.score
  from plch_latest_answers l
 order by l.user_id
        , l.competition_id
/
It gives him this output, which troubles him a lot:

   USER_ID COMPETITION_ID QUESTION_ID PLAYED         SCORE
---------- -------------- ----------- --------- ----------
        51              2         234 13-JAN-14        180
        51              3         345 14-JAN-14        310
        51              4         123 15-JAN-14        245
Where is competition 1 that the player has played twice? My colleague was expecting this output instead:

   USER_ID COMPETITION_ID QUESTION_ID PLAYED         SCORE
---------- -------------- ----------- --------- ----------
        51              1         123 12-JAN-14        220
        51              2         234 13-JAN-14        180
        51              3         345 14-JAN-14        310
        51              4         123 15-JAN-14        245
We need to help him find the bug in his view and rewrite it to work as intended.

Which of the choices will create a correct view that makes the above test select statement return the expected output (the second output shown with 4 rows.)
*/

select * from plch_comp_answers a join plch_competitions c on c.COMPETITION_ID = A.COMPETITION_ID;

--cost 34
select a.user_id
     , a.competition_id
     , q.question_id
     , a.played
     , a.score
  from plch_comp_answers a
  join plch_competitions q
         on q.competition_id = a.competition_id
 where (a.user_id, q.question_id, a.played) in (
         select a2.user_id
              , q2.question_id
              , max(a2.played)
           from plch_comp_answers a2
           join plch_competitions q2
                  on q2.competition_id = a2.competition_id
          group by a2.user_id
                 , a2.COMPETITION_ID
                 , q2.question_id
       );
       
--cost 21   
select a.user_id
     , a.competition_id
     , q.question_id
     , max(a.played) played
     , max(a.score) keep(DENSE_RANK last order by played) score
     from plch_comp_answers a join plch_competitions q on a.COMPETITION_ID = q.COMPETITION_ID
     group by a.user_id
                 , a.COMPETITION_ID
                 , q.question_id;
                 
select a.user_id
     , a.competition_id
     , max(q.question_id) question_id
     , max(a.played) played
     , max(a.score) keep (dense_rank last order by a.played) score
  from plch_comp_answers a
  join plch_competitions q
         on q.competition_id = a.competition_id
 group by a.user_id
        , a.competition_id;
        
--cost 22        
select a2.user_id
     , a2.competition_id
     , q.question_id
     , a2.played
     , a2.score
  from (
   select a.user_id
        , a.competition_id
        , max(a.played) played
        , max(a.score) keep (dense_rank last order by a.played) score
     from plch_comp_answers a
    group by a.user_id
           , a.competition_id
       ) a2
  join plch_competitions q
         on q.competition_id = a2.competition_id;
         
select user_id
     , competition_id
     , question_id
     , played
     , score
  from (
   select a.user_id
        , a.competition_id
        , q.question_id
        , a.played
        , a.score
        , row_number() over (
             partition by a.user_id, q.competition_id
             order by a.played desc
          ) rn
     from plch_comp_answers a
     join plch_competitions q
            on q.competition_id = a.competition_id
       )
 where rn = 1;