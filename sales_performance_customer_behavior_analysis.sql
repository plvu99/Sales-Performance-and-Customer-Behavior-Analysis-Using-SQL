-- What is the total number of unique orders and the total quantity of orders by month?
SELECT DATE_FORMAT(o.orderDate, '%Y-%m'), COUNT(DISTINCT o.orderNumber), SUM(o2.quantityOrdered) 
FROM orders o  
LEFT JOIN orderdetails o2  
ON o.orderNumber = o2.orderNumber 
GROUP BY DATE_FORMAT(o.orderDate, '%Y-%m') 

-- Which order has the largest value (quantity * price)?
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS 'totalPrice'
FROM orderdetails o2 
GROUP BY orderNumber
ORDER BY SUM(quantityOrdered * priceEach) DESC
LIMIT 1 

-- Which customer number has the largest total amount? 
SELECT customerNumber, SUM(amount)
FROM payments p
GROUP BY customerNumber
ORDER BY SUM(amount) DESC 
LIMIT 1

-- What are the first names of customers, their total amount paid, and their city 
-- (for those with a customer number between 200 and 300)?
SELECT c.contactFirstName, SUM(p.amount) AS 'totalAmount', c.city, c.customerNumber
FROM customers c 
LEFT JOIN payments p 
ON c.customerNumber = p.customerNumber 
WHERE c.customerNumber >= 200 AND c.customerNumber <= 300 
GROUP BY c.contactFirstName, c.city, c.customerNumber

-- What is the total order value (quantity * price) earned by employee whose first name is Jeff, Mary, Peter and Andy?
SELECT e.firstName, SUM(o2.quantityOrdered * o2.priceEach) AS 'totalRevenue'
FROM orderdetails o2
LEFT JOIN orders o 
ON o2.orderNumber = o.orderNumber
LEFT JOIN customers c
ON o.customerNumber = c.customerNumber 
LEFT JOIN employees e
ON c.salesRepEmployeeNumber = e.employeeNumber 
WHERE e.firstName IN ('Jeff', 'Mary', 'Peter', 'Andy')
GROUP BY e.firstName

-- What are the employee numbers, last names, first names, and emails of employees 
-- working in offices located in Boston, Tokyo, or London?
SELECT e.employeeNumber, e.lastName, e.firstName, e.email
FROM employees e 
LEFT JOIN offices o 
ON e.officeCode = o.officeCode 
WHERE o.city IN ('Boston', 'Tokyo', 'London')

SELECT e.employeeNumber, e.lastName, e.firstName, e.email
FROM employees e 
WHERE e.officeCode IN (SELECT o.officeCode 
		       FROM offices o
		       WHERE o.city IN ('Boston', 'Tokyo', 'London'))

-- What are the order numbers and order dates for orders that include at least 5 products 
-- and have been shipped, sorted in ascending order of total price?
SELECT o.orderNumber, o.orderDate, o2.num_Order, o2.total_Value  
FROM orders o 
INNER JOIN (SELECT orderNumber, COUNT(quantityOrdered) AS num_Order, SUM(quantityOrdered * priceEach) AS total_Value 
	    FROM orderdetails
	    GROUP BY orderNumber
	    HAVING num_Order >= 5) AS o2
ON o.orderNumber = o2.orderNumber 
WHERE o.status = 'Shipped'
ORDER BY o2.total_Value

-- What are the order numbers, order dates, and statuses of the 5 orders with the largest total order amounts?
SELECT o.orderNumber, o.orderDate, o.status, o2.total_Value
FROM orders o 
LEFT JOIN (SELECT orderNumber, SUM(quantityOrdered * priceEach) AS total_Value 
	   FROM orderdetails
	   GROUP BY orderNumber) AS o2
ON o.orderNumber = o2.orderNumber
ORDER BY o2.total_Value DESC
LIMIT 5

-- What are the product codes, names, quantities in stock, and buy prices of 10 products 
-- that have a stock quantity below the overall average and a price lower than $60, 
-- sorted in ascending order by quantity remaining?
SELECT productCode, productName, quantityInStock, buyPrice
FROM products p
WHERE p.quantityInStock >= 1 
      AND p.quantityInStock < (SELECT AVG(quantityInStock) FROM products p)  
      AND buyPrice < 60
ORDER BY quantityInStock
	
-- Who are the top 5 employees (employeeNumber, lastName, firstName, email, jobTitle) with the best sales performance, 
-- based on total sales from successfully delivered orders?
SELECT e.employeeNumber, e.lastName, e.firstName, e.email, e.jobTitle, s.sales
FROM employees e
LEFT JOIN (SELECT c.salesRepEmployeeNumber AS employeeNumber, SUM(v.total_Value) AS sales
	   FROM (SELECT customerNumber, salesRepEmployeeNumber
		 FROM customers) AS c
	   RIGHT JOIN (SELECT o.orderNumber, o.status, o.customerNumber, o2.total_Value
		       FROM (SELECT orderNumber, status, customerNumber
			     FROM orders
			     WHERE status = 'Shipped') AS o
		       INNER JOIN (SELECT orderNumber, SUM(quantityOrdered * priceEach) AS total_Value
				   FROM orderdetails
				   GROUP BY orderNumber) AS o2 
		       ON o.orderNumber = o2.orderNumber) AS v 
	   ON c.customerNumber = v.customerNumber
	   GROUP BY c.salesRepEmployeeNumber) AS s
ON e.employeeNumber = s.employeeNumber
ORDER BY s.sales DESC
LIMIT 5

-- What are the customer names and their credit limits, classified into Low (< 39,800), 
-- Medium (≥ 39,800 and < 76,400), and High (≥ 76,400) categories?
SELECT customerName, 
       creditLimit,
       CASE WHEN creditLimit < 39800 THEN 'Low'
	    WHEN creditLimit >= 39800 AND creditLimit < 76400 THEN 'Medium'
	    ELSE 'High'	
       END AS creditRank
FROM customers 

-- What are the customer names and their countries, with the country classified as “US,” “UK,” or “Germany,” 
-- and all other countries labeled as “Others”?
SELECT customerName,
       country,
       CASE WHEN country IN ('USA', 'UK', 'Germany') THEN 'Country'
            ELSE 'Others'
       END AS countryCategory
FROM customers 

SELECT CASE WHEN country = 'USA' THEN 'USA'
	    WHEN country = 'UK' THEN 'UK'
	    WHEN country = 'Germany' THEN 'Germany'
            ELSE 'Others'
       END AS countryCategory,
       COUNT(customerNumber) AS customerNum 
FROM customers
GROUP BY countryCategory

-- How can we assign row numbers to customers grouped by country?
SELECT customerName,
       country,
       ROW_NUMBER () OVER (PARTITION BY country) AS rowNum
FROM customers 

-- How many orders did the top 5 customers (with the most orders in 2003) place in 2004?
WITH order_2003 AS (SELECT customerNumber, COUNT(orderNumber) AS orderNum
      		    FROM orders o 
      		    WHERE YEAR(orderDate) = 2003
      		    GROUP BY customerNumber
      		    ORDER BY orderNum DESC
      		    LIMIT 5)
      		SELECT order_2003.customerNumber, COUNT(o.orderNumber) AS orderNum2 
		FROM order_2003
		LEFT JOIN orders o
		ON order_2003.customerNumber = o.customerNumber
      		WHERE YEAR(o.orderDate) = 2004
      		GROUP BY o.customerNumber

-- Which country has the lowest average credit limit?
SELECT country, AVG(creditLimit) AS avg_credit_limit
FROM customers 
GROUP BY country
ORDER BY avg_credit_limit ASC 
LIMIT 1

-- Who are the top 5 employees (employeeNumber, lastName, firstName, email, jobTitle) with the highest sales performance, 
-- considering only successfully delivered orders and ranking based on total sales?
SELECT e.employeeNumber, e.lastName, e.firstName, e.email, e.jobTitle, employee_num.totalSales 
FROM employees e 
RIGHT JOIN (SELECT c.salesRepEmployeeNumber AS employeeNumber, SUM(order_num.totalValue) AS totalSales  
	    FROM customers c 
	    RIGHT JOIN (SELECT o.orderNumber, o.customerNumber, o2.totalValue
			FROM (SELECT orderNumber, customerNumber
			      FROM orders
			      WHERE status = 'Shipped') AS o
			INNER JOIN (SELECT orderNumber, SUM(quantityOrdered * priceEach) AS totalValue
				    FROM orderdetails
				    GROUP BY orderNumber) AS o2
			ON o.orderNumber = o2.orderNumber) AS order_num
	    ON c.customerNumber = order_num.customerNumber
	    GROUP BY employeeNumber) AS employee_num
ON e.employeeNumber = employee_num.employeeNumber  
ORDER BY employee_num.totalSales DESC
LIMIT 5

-- How did the total number of orders placed each month (across all order statuses) change in 2004 
-- compared to 2003, in terms of increase or decrease per month?
SELECT order_2003.month_2003 AS 'month', order_2003.order_num_2003, order_2004.order_num_2004, 
	   CONCAT((order_num_2004 - order_num_2003) / order_num_2003 * 100, '%') AS percent_change
FROM (SELECT MONTH(orderDate) AS month_2003, COUNT(orderNumber) AS order_num_2003
      FROM orders
      WHERE YEAR(orderDate) = 2003
      GROUP BY MONTH(orderDate)) AS order_2003
LEFT JOIN (SELECT MONTH(orderDate) AS month_2004, COUNT(orderNumber) AS order_num_2004
	   FROM orders
	   WHERE YEAR(orderDate) = 2004
	   GROUP BY MONTH(orderDate)) AS order_2004
ON order_2003.month_2003 = order_2004.month_2004

-- Which employees manage at least 5 other employees, 
-- and what are their employee IDs and the cities they work in?
WITH employee_num_under AS (SELECT reportsTo AS employee_num, COUNT(employeeNumber) AS employee_under 
			    FROM employees e 
			    GROUP BY reportsTo
			    HAVING employee_under >= 5)
			SELECT employee_num, employee_under, e.officeCode, o.city 
			FROM employee_num_under
			LEFT JOIN employees e 
			ON employee_num_under.employee_num = e.employeeNumber
			LEFT JOIN offices o
			ON e.officeCode = o.officeCode

-- What is the ranking of company offices (officeCode, city) by revenue in 2004, 
-- with revenue calculated from the total value of successfully delivered orders?
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
