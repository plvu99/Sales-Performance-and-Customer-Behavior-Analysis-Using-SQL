# Sales Performance and Customer Behavior Analysis Using SQL

## 🔎 Overview

This project analyzes sales performance and customer behavior using relational data from a retail sales database. By leveraging **SQL queries across multiple tables**—including orders, customers, employees, products, and payments—the analysis uncovers **patterns in revenue generation, customer purchasing behavior, and sales performance**.

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

### Customers

* Customer information
* Credit limits
* Location data

### Employees

* Sales representatives responsible for customers
* Employee information

### Offices

* Company office locations and organizational structure

### Order Details

* Products included in each order
* Quantity ordered
* Price per item

### Orders

* Order numbers
* Order dates
* Order status

### Payments

* Payment transactions made by customers

### Products

* Product catalog
* Stock levels
* Buy prices

These tables are connected through relational keys such as:

* `customerNumber`
* `employeeNumber`
* `orderNumber`
* `officeCode`
* `productCode`

<img width="603" height="717" alt="Screenshot 2026-03-08 at 12 32 21 AM" src="https://github.com/user-attachments/assets/72b0573f-760c-4b15-aa7a-c5022a6dc6d5" />

## 📍 Methodology

The analysis uses SQL techniques including:

### Data Aggregation

Summarizing business metrics such as:

* Total sales revenue
* Number of orders
* Monthly order trends

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
SELECT customerName, 
       creditLimit,
       CASE WHEN creditLimit < 39800 THEN 'Low'
			WHEN creditLimit >= 39800 AND creditLimit < 76400 THEN 'Medium'
			ELSE 'High'
		END AS creditRank
FROM customers
```

### Performance Ranking

Ranking employees and offices by revenue using multi-table joins and Common Table Expressions (CTEs).

Example:

```sql
WITH office_num AS (SELECT e.officeCode, SUM(employee_num.totalRevenue2) AS totalRevenue3
					FROM employees e
					INNER JOIN (SELECT c.salesRepEmployeeNumber AS employeeNumber, SUM(customer_num.totalRevenue) AS totalRevenue2
								FROM customers c
								INNER JOIN (SELECT o.customerNumber, SUM(o2.totalValue) AS totalRevenue
											FROM orders o
											LEFT JOIN (SELECT orderNumber, SUM(quantityOrdered * priceEach) AS totalValue
														FROM orderdetails
														GROUP BY orderNumber) AS o2
											ON o.orderNumber = o2.orderNumber
											WHERE YEAR(o.orderDate) = 2004 AND o.status = 'Shipped'
											GROUP BY o.customerNumber) AS customer_num
								ON c.customerNumber = customer_num.customerNumber 
								GROUP BY c.salesRepEmployeeNumber) AS employee_num
					ON e.employeeNumber = employee_num.employeeNumber 
					GROUP BY e.officeCode)
		SELECT office_num.officeCode, o3.city, office_num.totalRevenue3
		FROM office_num
		LEFT JOIN offices o3
		ON office_num.officeCode = o3.officeCode
		ORDER BY office_num.totalRevenue3 DESC 
```

### Window Functions

Assigning rankings within groups.

Example:

```sql
SELECT customerName,
       country,
       ROW_NUMBER () OVER (PARTITION BY country) AS rowNum
FROM customers
```

## 🔑 Key Insights

* A small subset of customers accounts for a large share of total payments, highlighting opportunities for targeted relationship management.
* Some orders generate significantly higher revenue due to larger product quantities and higher pricing.
* Sales representatives managing high-performing customers generate substantially higher revenue compared to others.
* Certain products have stock levels below the average while still maintaining relatively low purchase prices, indicating potential inventory management challenges.
* Monthly order volumes fluctuate year-to-year, providing insight into potential seasonal demand patterns and sales growth trends.
* Offices and managers overseeing larger teams often generate higher total revenue through their sales representatives.

## ✍️ Business Recommendations

### 1. Focus on high-value customers

Implement targeted retention programs and personalized offers for top-spending customers to maintain long-term revenue growth.

### 2. Optimize sales representative performance

Use performance analytics to identify best-performing sales representatives and replicate their strategies across the sales team.

### 3. Improve inventory monitoring

Prioritize restocking products with low inventory levels and strong demand to avoid stock-out risks.

### 4. Monitor monthly sales trends

Analyze seasonal fluctuations to better align marketing campaigns and inventory planning with demand patterns.

### 5. Strengthen regional sales strategy

Compare office-level performance to identify regions with growth potential and allocate resources accordingly.

## ⚙ Tools & Techniques

* SQL (MySQL)
* Multi-table joins
* Aggregations
* Subqueries
* Common Table Expressions (CTEs)
* Revenue analysis
* Customer segmentation
* Performance ranking
* Time-based sales analysis
