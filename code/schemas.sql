-- Apple Retails Sales Schemas

DROP TABLE IF EXISTS category;
CREATE TABLE category(
	category_id VARCHAR(10) PRIMARY KEY,
	category_name VARCHAR(50)
);


DROP TABLE IF EXISTS products;
CREATE TABLE products(
	Product_ID VARCHAR(15) PRIMARY KEY,
	Product_Name VARCHAR(35),
	Category_ID	VARCHAR(10),
	Launch_Date date,
	Price float,
	CONSTRAINT fk_category FOREIGN KEY (Category_ID) REFERENCES category(category_id)
);


DROP TABLE IF EXISTS stores;
CREATE TABLE stores
(
	Store_ID VARCHAR(10) PRIMARY KEY,
	Store_Name VARCHAR(35),
	City VARCHAR(20),
	Country VARCHAR(20)
);


DROP TABLE IF EXISTS sales;
CREATE TABLE sales
(
	sale_id VARCHAR(15) PRIMARY KEY,
	sale_date DATE,
	store_id VARCHAR(10),
	product_id VARCHAR(15),
	quantity INT,
	CONSTRAINT fk_stores FOREIGN KEY(store_id) REFERENCES stores(Store_ID),
	CONSTRAINT fk_products FOREIGN KEY(product_id) REFERENCES products(Product_ID)
);


DROP TABLE IF EXISTS warranty;
CREATE TABLE warranty
(
	claim_id VARCHAR(10) PRIMARY KEY,
	claim_date DATE,
	sale_id VARCHAR(15),
	repair_status VARCHAR(20),
	CONSTRAINT fk_sales FOREIGN KEY(sale_id) REFERENCES sales(sale_id)
)
