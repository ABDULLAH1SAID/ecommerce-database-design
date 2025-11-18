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
![ER Diagram](https://github.com/ABDULLAH1SAID/ecommerce-database-design/blob/main/Schema/er_digram)

## 🛠️ SQL Queries

### 1. Daily Revenue Report
```sql
-- Returns total revenue for a specific date
