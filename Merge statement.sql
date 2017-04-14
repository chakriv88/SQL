----Merge statement----
--merge statement is used to select rows from one or multiple sources for update or insertion into a table or view.
--merge statement provides a convenient way to combine multiple operations. It lets you avoid multiple Insert, Update and Delete DML statements.

select * from sales;

select * from sales_history;

select sales_date, order_id, product_id, customer_id, salesperson_id from sales
intersect
select sales_date, order_id, product_id, customer_id, salesperson_id from sales_history;


select sales_date, order_id, product_id, customer_id, salesperson_id from sales_history
union
select sales_date, order_id, product_id, customer_id, salesperson_id from sales;

select sales_date, order_id, product_id, customer_id, salesperson_id from sales
union
select sales_date, order_id, product_id, customer_id, salesperson_id from sales_history;

MERGE INTO SALES_HISTORY dest
  USING SALES src
  ON(dest.sales_date = src.sales_date
  AND dest.order_id = src.order_id
  AND dest.product_id = src.product_id
  AND dest.customer_id = src.customer_id)
WHEN MATCHED THEN 
  UPDATE SET dest.quantity = src.quantity,
             dest.unit_price = src.unit_price,
             dest.sales_amount = src.sales_amount,
             dest.tax_amount = src.tax_amount,
             dest.total_amount = src.total_amount
WHEN NOT MATCHED THEN
  INSERT (SALES_DATE, ORDER_ID, PRODUCT_ID, CUSTOMER_ID, SALESPERSON_ID, QUANTITY, UNIT_PRICE, SALES_AMOUNT, TAX_AMOUNT, TOTAL_AMOUNT)
  VALUES (src.SALES_DATE, src.ORDER_ID, src.PRODUCT_ID, src.CUSTOMER_ID, src.SALESPERSON_ID, src.QUANTITY, src.UNIT_PRICE, src.SALES_AMOUNT, src.TAX_AMOUNT, src.TOTAL_AMOUNT);
--96 rows merged. (96 rows in sales)

select * from sales_history;

select * from sales;

create table sales_history1 as
select * from SALES_HISTORY where 1 <> 1; -- where 1 <> 1 is used so that no rows will be inserted into sales_history1

select * from sales_history1;

MERGE INTO SALES_HISTORY1 dest
  USING SALES src
  ON(dest.sales_date = src.sales_date
  AND dest.order_id = src.order_id
  AND dest.product_id = src.product_id
  AND dest.customer_id = src.customer_id)
WHEN MATCHED THEN 
  UPDATE SET dest.quantity = src.quantity,
             dest.unit_price = src.unit_price,
             dest.sales_amount = src.sales_amount,
             dest.tax_amount = src.tax_amount,
             dest.total_amount = src.total_amount
             where src.total_amount > 1000 --where clause can also be used here
WHEN NOT MATCHED THEN
  INSERT (SALES_DATE, ORDER_ID, PRODUCT_ID, CUSTOMER_ID, SALESPERSON_ID, QUANTITY, UNIT_PRICE, SALES_AMOUNT, TAX_AMOUNT, TOTAL_AMOUNT)
  VALUES (src.SALES_DATE, src.ORDER_ID, src.PRODUCT_ID, src.CUSTOMER_ID, src.SALESPERSON_ID, src.QUANTITY, src.UNIT_PRICE, src.SALES_AMOUNT, src.TAX_AMOUNT, src.TOTAL_AMOUNT)
  where src.total_amount > 1000;

commit;

create table sales_history2 as
select * from SALES_HISTORY where total_amount between 1 and 100; 

select * from SALES_HISTORY2;

MERGE INTO SALES_HISTORY2 dest
  USING SALES src
  ON(dest.sales_date = src.sales_date
  AND dest.order_id = src.order_id
  AND dest.product_id = src.product_id
  AND dest.customer_id = src.customer_id)
WHEN MATCHED THEN 
  UPDATE SET dest.quantity = src.quantity,
             dest.unit_price = src.unit_price,
             dest.sales_amount = src.sales_amount,
             dest.tax_amount = src.tax_amount,
             dest.total_amount = src.total_amount           
  DELETE WHERE dest.total_amount < 50 --delete clause can also be used here
WHEN NOT MATCHED THEN
  INSERT (SALES_DATE, ORDER_ID, PRODUCT_ID, CUSTOMER_ID, SALESPERSON_ID, QUANTITY, UNIT_PRICE, SALES_AMOUNT, TAX_AMOUNT, TOTAL_AMOUNT)
  VALUES (src.SALES_DATE, src.ORDER_ID, src.PRODUCT_ID, src.CUSTOMER_ID, src.SALESPERSON_ID, src.QUANTITY, src.UNIT_PRICE, src.SALES_AMOUNT, src.TAX_AMOUNT, src.TOTAL_AMOUNT)
  where src.total_amount > 1000;  

select * from SALES_HISTORY2;