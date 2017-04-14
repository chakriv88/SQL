----PARTITION TABLE----*Feature not available for express edition. Only available to enterprise edition.

--partition by range--
create table sales1 
(
sales_id number,
order_date date,
description varchar(50)
)
partition by range (order_date)
(
partition p1506 values less than (to_date('01-JAN-2015','DD-MM-YYYY')),
partition p1507 values less than (to_date('01-MAR-2015','DD-MM-YYYY')),
partition p1508 values less than (to_date('01-MAY-2015','DD-MM-YYYY')),
partition p1509 values less than (to_date('01-JUL-2015','DD-MM-YYYY')),
partition p1510 values less than (MAXVALUE)
);

insert into sales1 values(1,'01-FEB-2015','desc');
select * from sales1; --this access the entry table
select * from sales1 partition (p1507); -- this access only the partition p1507

--partition by list--
create table sales1 
(
sales_id number,
order_date date,
description varchar(50),
regoin varchar2(10)
)
partition by list (region)
(
partition es values ('East'),
partition ws values ('West'),
partition nr values ('North'),
partition st values ('South')
);

insert into sales1 values(2,'01-MAR-2015','desc','East');
select * from sales1; --this access the entry table and return data present in entire table
select * from sales1 partition (es); -- this access only the partition es and returns data present in it

--partition by hash key--*Where ever range and list partitions are not appropriate like Customer_ID, Product_ID etc., then we use hash partitioning. It divides the
--rows appropriately (may not be equally) across different partitions. We cannot decide which rows should go into a particular partition. Oracle will generate 
--hash key and based on that hash key the row will go into the appropriate partition.

create table sales1 
(
sales_id number,
order_date date,
description varchar(50),
regoin varchar2(10)
)
partition by hash (sales_id)
(
partition c1,
partition c2,
partition c3,
partition c4
);

insert into sales1 values(3,'01-MAR-2015','desc','East');
insert into sales1 values(4,'01-MAR-2015','desc','East');
insert into sales1 values(5,'01-MAR-2015','desc','East');
insert into sales1 values(6,'01-MAR-2015','desc','East');
insert into sales1 values(7,'01-MAR-2015','desc','East');
select * from sales1; --this access the entry table and return data present in entire table
--we dont know which row is inserted into which partition. To get that info, following should be done.
select * from sales1 partition (c1); --0 rows might have inserted
select * from sales1 partition (c2); --0 rows might have inserted
select * from sales1 partition (c3); --2 rows might have inserted
select * from sales1 partition (c4); --3 rows might have inserted

--Composite partitioning--* implementing multiple partitions (ex: range and list, range and hash etc. is called composite partitioning.

create table sales1 
(
sales_id number,
order_date date,
description varchar(50),
regoin varchar2(10)
)
partition by range (order_date)
subpartition by hash(sales_id) subpartitions 4
(
partition p1506 values less than (to_date('01-JAN-2015','DD-MM-YYYY')),
partition p1507 values less than (to_date('01-MAR-2015','DD-MM-YYYY')),
partition p1508 values less than (to_date('01-MAY-2015','DD-MM-YYYY')),
partition p1509 values less than (to_date('01-JUL-2015','DD-MM-YYYY')),
partition p1510 values less than (MAXVALUE)
);

insert into sales1 values(8,'01-SEP-2015','desc','East');
insert into sales1 values(9,'01-APR-2015','desc','East');
select * from sales1; --this access the entry table and return data present in entire table
--we dont know which row is inserted into which subpartition. We can access through range partitions only.
select * from sales1 partition (p1510); --Returns the rows with july and above months. However, we don't know in which subpartition it gets stored.
--We can see explain plan for more.

--Here is an example of creating a range-list partitioned table:

create table range_list_example (
sales_dt date,
state char(2),
amount number)
partition by range (sales_dt)
subpartition by list (state)
(
partition s2004q1
values less than (to_date('04-2004','MM-YYYY'))
(subpartition s2004q1_south values  ('TX','LA','OK'),
subpartition s2004q1_north values ('NY','DE','MA'),
subpartition s2004q1_others values (DEFAULT)),
partition s2004q2
values less than (to_date('07-2004','MM-YYYY'))
(subpartition s2004q2_south values  ('TX','LA','OK'),
subpartition s2004q2_north values ('NY','DE','MA'),
subpartition s2004q2_others values (DEFAULT))
)

--The same sub-partitions can be created using a sub-partition template as in the following example:

create table range_list_example (
sales_dt date,
state char(2),
amount number)
partition by range (sales_dt)
subpartition by list (state)
subpartition template
(subpartition south values  ('TX','LA','OK'),
subpartition north values ('NY','DE','MA'),
subpartition others values (DEFAULT))
(
partition s2004q1
values less than (to_date('04-2004','MM-YYYY')),
partition s2004q2
values less than (to_date('07-2004','MM-YYYY'))
)

--Interval partition-- It is an enhancement to range partition. It automatically create time-based partitios as new data is added.

create table sales1 
(
sales_id number,
order_date date,
description varchar(50),
regoin varchar2(10)
)
partition by range (order_date)
interval (numtoyminterval(1,'MONTH'))
(
partition p1506 values less than (to_date('01-JAN-2015','DD-MM-YYYY')),
partition p1507 values less than (to_date('01-MAR-2015','DD-MM-YYYY')),
partition p1508 values less than (to_date('01-MAY-2015','DD-MM-YYYY'))
);

select * from ALL_TAB_PARTITONS where TABLE_NAME = 'sales1'; -- returns all the partitions for sales1 table. In above case 3 partitions.

insert into sales1 values(8,'01-SEP-2015','desc','East'); --Throws an error since there is no mapping to any partition that matches this key if we had not created 
--interval partitioning. However, if interval partitioning is created, above insert statement will automatically create another partition. This way there is no need
--to create a partition every month

select * from ALL_TAB_PARTITONS where TABLE_NAME = 'sales1'; -- Now it returns 4 partitions as one more partition is automatically created from above insert statement.

--Once you have created a partitioned table, you can add more partitions using the ALTER TABLE command.

ALTER TABLE SALES1 ADD PARTITION (PARTITION 'P1550' VALUES LESS THAN TO_DATE ('2016-01-01', 'YYYY-MM-DD'));

-- If you want to drop a partition, you can use the below command

ALTER TABLE SALES1 DROP PARTITION P1550;