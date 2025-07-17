<img src = 'apple_store.jpg'></img>
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-blue)
![Analysis](https://img.shields.io/badge/Data%20Analysis-SQL-orange)
![Status](https://img.shields.io/badge/Project-Complete-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

# 🍏 Apple Sales Data Analysis

An analytical deep dive into 1 million+ Apple product sales using PostgreSQL. This project explores trends in revenue, warranty claims, product launch impact, and store performance across time and geography.

---

## 📦 Dataset Overview

- **Volume**: Over 1,000,000 rows of transactional sales data  
- **Scope**: Apple product sales, warranty activity, and store metadata, products details, categories
- **Fields include**:
  - Sale and launch dates  
  - Product details (name, price)  
  - Quantity sold  
  - Store location (country, region)  
  - Warranty claims

---

## 🧠 Key Analysis Goals

- 📈 Year-by-year **revenue growth trends** per store  
- 🗓️ Sales breakdown by product lifecycle: _launch → post-launch periods_  
- 🛠️ Correlation between product price and warranty claims  
- 🌍 Identify **least-selling products** by country and year  
- 📊 Monthly sales trends and **running totals**  


## 🧰 Tools Used

- **Database**: PostgreSQL  
- **Language**: SQL  
- **Environment**: Local PostgreSQL instance or cloud-hosted DB  

---

## 🚀 Project Structure
├── code/  


├──── schemas.sql   

├──── query_optimization.sql  

├──── apple_sales_insights.sql

├── dataset/

├──── sales.csv

├──── products.csv

├──── stores.csv

├──── warranty.csv

├──── category.csv

├── apple_store.jpg 

├── README.md




## 🧪 Sample Insight

> "Products priced between $100–$500 showed the strongest correlation with warranty claims during the first 6–12 months after launch."


## 📈 How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/apple-sales-analysis.git

2. Import the dataset into PostgreSQL.
3. Run the SQL queries from the /sql folder using your preferred client (e.g. DBeaver, pgAdmin, psql).
4. Export results or visualize using your chosen tool.


📄 License
Distributed under the MIT License. See LICENSE for more information.
