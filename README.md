# E-Commerce Database Design & SQL Queries

## 📋 Project Overview
Complete database solution for an e-commerce system including schema design, ER diagrams, and complex SQL queries.

## 🗄️ Database Schema
### Entities
- **Categories** (`category_id`, `category_name`)
- **Products** (`product_id`, `category_id`, `name`, `description`, `price`, `stock_quantity`)
- **Customers** (`customer_id`, `first_name`, `last_name`, `email`, `password`)
- **Orders** (`order_id`, `customer_id`, `order_date`, `total_amount`)
- **Order Details** (`order_detail_id`, `order_id`, `product_id`, `quantity`, `unit_price`)

### Relationships
- Categories (1) → Products (Many)
- Customers (1) → Orders (Many) 
- Orders (1) → Order Details (Many)
- Products (1) → Order Details (Many)
## 📊 ER Diagram
![ER Diagram](https://github.com/ABDULLAH1SAID/ecommerce-database-design/blob/main/Schema/er_digram.png?raw=true)

### Table Creation Script

```sql
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Create Category Table
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Product Table
CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES Category(category_id) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
);

-- Create Customer Table
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create Order Table
CREATE TABLE `Order` (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_customer 
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
);

-- Create Order_Details Table
CREATE TABLE Order_Details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    subtotal DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_details_order
    FOREIGN KEY (order_id) REFERENCES `Order`(order_id) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE,
    CONSTRAINT fk_order_details_product 
    FOREIGN KEY (product_id) REFERENCES Product(product_id) 
    ON DELETE RESTRICT 
    ON UPDATE CASCADE
);

```
## 🛠️ E-Commerce Analytics Queries
- daily report of the total revenue for a specific date.
```sql
select sum(total_amount) AS daily_revenue
from `order` 
where order_date='2024-11-01 10:30:00';
```
- monthly report of the top-selling products in a month
```sql
select p.`name`, sum(od.subtotal) as topselling 
from `order` o 
join order_details od
on o.order_id = od.order_id 
join product p 
on od.product_id = p.product_id 
where order_date between '2024-11-01'AND '2024-11-30'
group by p.`name`
order by topselling desc limit 3;
```
- retrieve a list of customers who have placed orders totaling more than $500 in the past month.
```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent_in_november
FROM customer c
JOIN `order` o 
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name
HAVING 
    SUM(o.total_amount) > 500;
```

## 📦 Denormalization in the E-Commerce System
### 📘 Why Denormalization Was Applied

In the fully normalized database design, the Order table stores only the customer_id, which means any query that needs customer information such as name or email requires a JOIN with the Customer table.

While normalization maintains data integrity, it may reduce performance in real-world e-commerce systems where:
- Reports query millions of rows
- Dashboards need fast loading
- JOIN operations become expensive

To optimize read operations and preserve the customer data associated with each order, a denormalization strategy was applied by copying selected customer attributes into the Order table.

✔️ Benefits of Denormalization

⚡ Improved query performance (fewer JOINs)

📊 Faster reporting & analytics

🗂️ Preserves customer info at order time even if the customer updates their profile later

🔄 Reduces system load on frequently accessed tables

## 🛠️ Denormalization Implementation

### 1️⃣ Add Denormalized Fields to the Order Table
```sql
ALTER TABLE `Order`
ADD COLUMN customer_first_name VARCHAR(50),
ADD COLUMN customer_last_name VARCHAR(50),
ADD COLUMN customer_email VARCHAR(100);
```
### 2️⃣ Populate Existing Orders With Customer Data
```sql
UPDATE `Order` o
JOIN Customer c 
    ON o.customer_id = c.customer_id
SET 
    o.customer_first_name = c.first_name,
    o.customer_last_name = c.last_name,
    o.customer_email = c.email;
```


  

