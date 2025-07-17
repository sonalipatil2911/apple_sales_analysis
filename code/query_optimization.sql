--Exploratory Data Analysis

select distinct repair_status from warranty;
select distinct store_name from stores;
select distinct category_name from category;
select distinct product_name from products;
select count(*) from sales;

--"Planning Time: 0.131 ms"
--"Execution Time: 174.723 ms"
EXPLAIN ANALYZE SELECT * FROM sales WHERE product_id ='P-40';

--Improve Query Performance
CREATE INDEX sales_product_id ON sales(product_id);

EXPLAIN ANALYZE SELECT * FROM sales WHERE product_id ='P-40';
--After creation of indexes query performances are increased to
--"Planning Time: 0.117 ms"
--"Execution Time: 6.707 ms"

CREATE INDEX sales_store_id ON sales(store_id);
CREATE INDEX sales_quantity ON sales(quantity);
CREATE INDEX sale_date ON sales(sale_date);
CREATE INDEX sales_product_id_store_id ON sales(product_id, store_id);


