# Sales Performance and Customer Behavior Analysis Using SQL

## 🔎 Overview

This project analyzes sales performance and customer behavior using relational data from a retail sales database. By leveraging SQL queries across multiple tables—including orders, customers, employees, products, and payments—the analysis uncovers patterns in revenue generation, customer purchasing behavior, and sales performance.

The goal is to demonstrate how SQL can be used to transform transactional data into actionable insights that support business decision-making in areas such as sales strategy, inventory management, and customer segmentation.

## 🔐 Business Problem

Retail companies collect large volumes of transactional data, but without structured analysis it can be difficult to understand:

* Which customers generate the most revenue
* Which products or orders drive the highest sales value
* Which employees or offices perform best
* How sales performance changes over time
* Which products may face inventory risks

This project addresses these questions by analyzing relational sales data to identify key performance drivers and operational opportunities.

## 📊 Dataset

The project uses a relational retail sales dataset consisting of multiple interconnected tables:

**Customers**

* Customer information
* Credit limits
* Location data

**Orders**

* Order numbers
* Order dates
* Order status

**Order Details**

* Products included in each order
* Quantity ordered
* Price per item

**Payments**

* Payment transactions made by customers

**Employees**

* Sales representatives responsible for customers

**Products**

* Product catalog
* Stock levels
* Buy prices

**Offices**

* Company office locations and organizational structure

These tables are connected through relational keys such as:

* `customerNumber`
* `orderNumber`
* `employeeNumber`
* `officeCode`

## 📍 Methodology

The analysis uses SQL techniques including:

### Data Aggregation

Summarizing business metrics such as:

* total sales revenue
* number of orders
* monthly order trends

Example:

```sql
SELECT DATE_FORMAT(o.orderDate, '%Y-%m'),
       COUNT(DISTINCT o.orderNumber),
       SUM(o2.quantityOrdered)
FROM orders o
LEFT JOIN orderdetails o2
ON o.orderNumber = o2.orderNumber
GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m');
```

### Revenue Analysis

Identifying high-value orders and customers.

Example:

```sql
SELECT orderNumber,
       SUM(quantityOrdered * priceEach) AS totalPrice
FROM orderdetails
GROUP BY orderNumber
ORDER BY totalPrice DESC
LIMIT 1;
```

### Customer Segmentation

Classifying customers based on credit limits.

Example:

```sql
CASE
WHEN creditLimit < 39800 THEN 'Low'
WHEN creditLimit < 76400 THEN 'Medium'
ELSE 'High'
END
```

### Performance Ranking

Ranking employees and offices by revenue using advanced queries and Common Table Expressions (CTEs).

### Window Functions

Assigning rankings within groups.

Example:

```sql
ROW_NUMBER() OVER (PARTITION BY country)
```

### Multi-table Joins

Connecting relational tables to analyze end-to-end sales performance.

Examples include joins across:

* customers
* orders
* orderdetails
* employees
* offices

## 🔑 Key Insights

### High-Value Customers Drive Significant Revenue

A small subset of customers accounts for a large share of total payments, highlighting opportunities for targeted relationship management.

### Order Value Distribution is Highly Uneven

Some orders generate significantly higher revenue due to larger product quantities and higher pricing.

### Sales Performance Varies Across Employees

Sales representatives managing high-performing customers generate substantially higher revenue compared to others.

### Inventory Risk Exists for Some Products

Certain products have stock levels below the average while still maintaining relatively low purchase prices, indicating potential inventory management challenges.

### Sales Trends Change Over Time

Monthly order volumes fluctuate year-to-year, providing insight into potential seasonal demand patterns and sales growth trends.

### Organizational Structure Impacts Sales

Offices and managers overseeing larger teams often generate higher total revenue through their sales representatives.

## ✍️ Business Recommendations

### Focus on High-Value Customers

Implement targeted retention programs and personalized offers for top-spending customers to maintain long-term revenue growth.

### Optimize Sales Representative Performance

Use performance analytics to identify best-performing sales representatives and replicate their strategies across the sales team.

### Improve Inventory Monitoring

Prioritize restocking products with low inventory levels and strong demand to avoid stock-out risks.

### Monitor Monthly Sales Trends

Analyze seasonal fluctuations to better align marketing campaigns and inventory planning with demand patterns.

### Strengthen Regional Sales Strategy

Compare office-level performance to identify regions with growth potential and allocate resources accordingly.

## ⚙ Tools & Technologies

* SQL (MySQL)
* Relational database analysis
* Multi-table joins
* Aggregations
* Subqueries
* Common Table Expressions (CTEs)
* Revenue analysis
* Customer segmentation
* Performance ranking
* Time-based sales analysis
