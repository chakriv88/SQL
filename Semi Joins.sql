create table plch_production_flow (
   production_id  integer
 , flow_order     integer
 , job_process    varchar2(10)
 , constraint plch_production_flow_pq
      primary key (production_id, flow_order)
)
/

create table plch_certifications (
   job_process    varchar2(10)
 , employee       varchar2(20)
 , certified      varchar2(1)
)
/

insert into plch_production_flow values (100, 1, 'CONSTRUCT')
/
insert into plch_production_flow values (100, 2, 'QA')
/
insert into plch_production_flow values (100, 3, 'PAINT')
/
insert into plch_production_flow values (100, 4, 'QA')
/
insert into plch_production_flow values (100, 5, 'PACK')
/
insert into plch_production_flow values (200, 1, 'CONSTRUCT')
/
insert into plch_production_flow values (200, 2, 'QA')
/
insert into plch_production_flow values (200, 3, 'PACK')
/

insert into plch_certifications values ('CONSTRUCT', 'JAMES', 'Y')
/
insert into plch_certifications values ('CONSTRUCT', 'JOHN',  'N')
/
insert into plch_certifications values ('PACK',      'JEFF',  'N')
/
insert into plch_certifications values ('PAINT',     'JILL',  'Y')
/
insert into plch_certifications values ('QA',        'JACK',  'Y')
/
insert into plch_certifications values ('QA',        'JOSH',  'Y')
/

commit;

--The first table contains the job flow for each production we start: which job processes (construction, painting, 
--quality assurance, packing) happen in which order for that particular production. Not all productions need a PAINT process, 
--for example. The other table contains which employees can do which job processes, and who are specially certified for that 
--particular process.

--My boss would like to see the process flow of the productions for those job processes, where we have at least one certified
--employee for that job process.

--Which of the choices return this desired output:

select * from plch_certifications;
select * from plch_production_flow;

select * from plch_production_flow f, PLCH_CERTIFICATIONS c where F.JOB_PROCESS = C.JOB_PROCESS;

select pf.production_id
     , pf.job_process
  from plch_production_flow pf
 where exists (
          select null
            from plch_certifications c
           where c.job_process = pf.job_process
             and c.certified = 'Y'
       )
 order by pf.production_id
        , pf.flow_order;
        
select pf.production_id
     , pf.job_process
  from plch_production_flow pf
 where exists (
          select *
            from plch_certifications c
           where c.job_process = pf.job_process
             and c.certified = 'Y'
       )
 order by pf.production_id
        , pf.flow_order;
        
select pf.production_id
     , pf.job_process
  from plch_production_flow pf
  semi join plch_certifications c
        on c.job_process = pf.job_process
       and c.certified = 'Y'
 order by pf.production_id
        , pf.flow_order; --there is no semi join
        
select pf.production_id
     , pf.job_process
  from plch_production_flow pf
  join plch_certifications c
        on c.job_process = pf.job_process
       and c.certified = 'Y'
 order by pf.production_id
        , pf.flow_order; --wrong option
        
select pf.production_id
     , pf.job_process
  from plch_production_flow pf
 where (
          select count(*)
            from plch_certifications c
           where c.job_process = pf.job_process
             and c.certified = 'Y'
       ) > 0
 order by pf.production_id
        , pf.flow_order;--Correct. But not efficient - we do not need the actual count, all we need is whether one exists at all.
        
select pf.production_id
     , pf.job_process
  from plch_production_flow pf
  join plch_certifications c
        on c.job_process = pf.job_process
       and c.certified = 'Y'
 group by pf.production_id
        , pf.job_process
 order by pf.production_id
        , min(pf.flow_order); --wrong option
        
select pf.production_id
     , max(pf.job_process) job_process
  from plch_production_flow pf
  join plch_certifications c
        on c.job_process = pf.job_process
       and c.certified = 'Y'
 group by pf.production_id
        , pf.flow_order
 order by pf.production_id
        , pf.flow_order; --Correct. But not efficient. Group by the primary key gives 1 row per pf record.
        
select pf.production_id
     , pf.job_process
  from plch_production_flow pf
  join (
          select distinct
                 c.job_process
            from plch_certifications c
           where c.certified = 'Y'
       ) c_unique
        on c_unique.job_process = pf.job_process
 order by pf.production_id
        , pf.flow_order; --Correct. But not efficient. Joins only to one QA rather than both employees.