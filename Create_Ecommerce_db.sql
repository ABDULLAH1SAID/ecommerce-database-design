CREATE DATABASE  ecommerce_db;
use ecommerce_db;

-- Create Category Table
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- CREATE PRODUCT table

CREATE TABLE product (
	product_id 	INT PRIMARY KEY AUTO_INCREMENT,
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

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
-- CREATE Order table

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

-- CREATE Order_Details table
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

INSERT INTO Category (category_name) VALUES
('Electronics'),
('Clothing'),
('Books'),
('Home & Garden'),
('Sports & Outdoors');

INSERT INTO Product (category_id, name, description, price, stock_quantity) VALUES
(1, 'Laptop HP 15', 'High performance laptop with Intel i7 processor', 15999.99, 50),
(1, 'Samsung Smart TV 55"', '4K UHD Smart TV with HDR', 12499.00, 30),
(1, 'iPhone 15 Pro', 'Latest iPhone with A17 chip', 25999.00, 40),
(2, 'Men T-Shirt', 'Cotton comfortable t-shirt', 299.99, 100),
(2, 'Women Jeans', 'Blue denim jeans', 599.00, 75),
(3, 'The Great Gatsby', 'Classic American novel', 150.00, 200),
(3, 'Clean Code', 'A Handbook of Agile Software Craftsmanship', 450.00, 80),
(4, 'Garden Tool Set', 'Complete gardening tools', 899.99, 40),
(5, 'Football', 'Professional size 5 football', 249.00, 150),
(5, 'Yoga Mat', 'Non-slip exercise mat', 199.00, 120);


INSERT INTO Customer (first_name, last_name, email, password) VALUES
('Ahmed', 'Mohamed', 'ahmed.mohamed@email.com', '$2y$10$example_hashed_password1'),
('Fatima', 'Ali', 'fatima.ali@email.com', '$2y$10$example_hashed_password2'),
('Omar', 'Hassan', 'omar.hassan@email.com', '$2y$10$example_hashed_password3'),
('Layla', 'Ibrahim', 'layla.ibrahim@email.com', '$2y$10$example_hashed_password4'),
('Youssef', 'Khaled', 'youssef.khaled@email.com', '$2y$10$example_hashed_password5');

INSERT INTO `Order` (customer_id, order_date, total_amount, status) VALUES
(1, '2024-11-01 10:30:00', 16449.98, 'Delivered'),
(1, '2024-11-10 14:20:00', 25999.00, 'Processing'),
(2, '2024-11-05 09:15:00', 899.99, 'Shipped'),
(3, '2024-11-12 16:45:00', 1048.99, 'Pending'),
(4, '2024-11-15 11:00:00', 12499.00, 'Processing'),
(5, '2024-11-16 13:30:00', 648.00, 'Pending');

INSERT INTO Order_Details (order_id, product_id, quantity, unit_price) VALUES
-- Order 1 details (Ahmed's first order)
(1, 1, 1, 15999.99),  -- Laptop
(1, 6, 3, 150.00),    -- 3 Books

-- Order 2 details (Ahmed's second order)
(2, 3, 1, 25999.00),  -- iPhone

-- Order 3 details (Fatima's order)
(3, 8, 1, 899.99),    -- Garden Tool Set

-- Order 4 details (Omar's order)
(4, 4, 2, 299.99),    -- 2 T-Shirts
(4, 9, 2, 249.00),    -- 2 Footballs

-- Order 5 details (Layla's order)
(5, 2, 1, 12499.00),  -- Smart TV

-- Order 6 details (Youssef's order)
(6, 5, 1, 599.00),    -- Jeans
(6, 7, 1, 450.00);    -- Clean Code book


--  Write an SQL query to generate a daily report of the total revenue for a specific date.

select sum(total_amount) AS daily_revenue
from `order` 
where order_date='2024-11-01 10:30:00';

--  Write an SQL query to generate a monthly report of the top-selling products in a given month.

select p.`name`, sum(od.subtotal) as topselling 
from `order` o 
join order_details od
on o.order_id = od.order_id 
join product p 
on od.product_id = p.product_id 
where order_date between '2024-11-01'AND '2024-11-30'
group by p.`name`
order by topselling desc limit 3;

-- Write a SQL query to retrieve a list of customers who have placed orders totaling more than $500 in the past month.

-- Write a SQL query to retrieve a list of customers who have placed orders totaling more than $500 in the past month.
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
-- 
ALTER TABLE `Order`
ADD COLUMN customer_first_name varchar(50),
ADD COLUMN customer_last_name VARCHAR(50);

UPDATE `order` o
JOIN customer c
 ON o.customer_id = c.customer_id
 SET 
    o.customer_first_name = c.first_name,
    o.customer_last_name = c.last_name,
    o.customer_email = c.email;
