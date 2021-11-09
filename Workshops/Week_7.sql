
-- - WEEK-7

-- - What is the sales quantity of product according to the brands and sort them highest-lowest

SELECT S.product_id, B.brand_name, P.product_name, SUM(S.quantity) AS TotalQuantity
FROM sale.order_item AS S 
	 INNER JOIN product.product AS P ON S.product_id=P.product_id 
	 INNER JOIN product.brand AS B ON P.brand_id=B.brand_id
GROUP BY S.product_id, B.brand_name, P.product_name
ORDER BY TotalQuantity DESC;

-- ///////////////////////////////////////////////////////////

-- - Select the top 5 most expensive products

SELECT TOP 5 P.product_id, P.product_name, B.brand_name, C.category_name, P.list_price
FROM product.product AS P
	 INNER JOIN product.brand AS B ON P.brand_id=B.brand_id
	 INNER JOIN product.category AS C ON P.category_id=C.category_id
ORDER BY list_price DESC;

SELECT TOP 5 *
FROM product.product
ORDER BY list_price DESC;

-- ////////////////////////////////////////////////////////////

-- What are the categories that each brand has

SELECT B.brand_name, C.category_name --, COUNT(P.product_id) AS TotalNumber
FROM product.product AS P
	 INNER JOIN product.brand AS B ON P.brand_id=B.brand_id
	 INNER JOIN product.category AS C ON P.category_id=C.category_id
GROUP BY B.brand_name, C.category_name
ORDER BY B.brand_name, C.category_name

-----------------------

SELECT * FROM
	(SELECT category_name, brand_name, product_id
	 FROM product.product AS P
		INNER JOIN product.brand AS B ON P.brand_id=B.brand_id
		INNER JOIN product.category AS C ON P.category_id=C.category_id
	 ) AS BaseData
PIVOT(
	 COUNT(product_id)
	 FOR category_name
	 IN ([Children Bicycles]
		 ,[Comfort Bicycles]
		 ,[Cruisers Bicycles]
		 ,[Cyclocross Bicycles]
		 ,[Electric Bikes]
		 ,[Mountain Bikes]
		 ,[Road Bikes])
) AS PivotTable

-- /////////////////////////////////////////////////////////////

-- - Select the avg prices according to brands and categories

SELECT brand_name,
		CONVERT(DECIMAL, [Children Bicycles]) AS [Children Bicycles],
		CONVERT(DECIMAL, [Comfort Bicycles]) AS [Comfort Bicycles],
		CONVERT(DECIMAL, [Cruisers Bicycles]) AS [Cruisers Bicycles],
		CONVERT(DECIMAL, [Cyclocross Bicycles]) AS [Cyclocross Bicycles],
		CONVERT(DECIMAL, [Electric Bikes]) AS [Electric Bikes],
		CONVERT(DECIMAL, [Mountain Bikes]) AS [Mountain Bikes],
		CONVERT(DECIMAL, [Road Bikes]) AS [Road Bikes]
FROM
	(SELECT category_name, brand_name, list_price
	 FROM product.product AS P
		  INNER JOIN product.brand AS B ON P.brand_id=B.brand_id
		  INNER JOIN product.category AS C ON P.category_id=C.category_id
	 ) AS BaseData
PIVOT(
	 AVG(list_price)
	 FOR category_name
	 IN ([Children Bicycles]
		 ,[Comfort Bicycles]
		 ,[Cruisers Bicycles]
		 ,[Cyclocross Bicycles]
		 ,[Electric Bikes]
		 ,[Mountain Bikes]
		 ,[Road Bikes])
) AS PivotTable

-- //////////////////////////////////////////////////////////////

-- - Select the annual amount of product produced according to brands

SELECT B.brand_name, P.model_year, SUM(S.quantity) AS TotalAmountPerYear
FROM product.brand AS B 
	 INNER JOIN product.product AS P ON B.brand_id=P.brand_id 
	 INNER JOIN product.stock AS S ON P.product_id=S.product_id
GROUP BY B.brand_name, P.model_year
ORDER BY b.brand_name, model_year

----

SELECT b.brand_name, p.model_year, SUM(o.quantity) AS TotalAmountPerYear
FROM product.brand AS B 
	 INNER JOIN product.product AS P ON B.brand_id=P.brand_id 
	 INNER JOIN sale.order_item AS O ON O.product_id=P.product_id
GROUP BY B.brand_name, P.model_year
ORDER BY B.brand_name, P.model_year

----------------------------------

SELECT * FROM
	(SELECT brand_name, model_year, quantity
	 FROM product.brand AS B 
		  INNER JOIN product.product AS P ON B.brand_id=P.brand_id 
		  INNER JOIN sale.order_item AS O ON O.product_id=P.product_id) AS BaseData
PIVOT (
	SUM(quantity)
	FOR model_year
	IN ([2018]
		,[2019]
		,[2020])  -- 2021
) AS PivotTable
ORDER BY brand_name

-- ////////////////////////////////////////////////////////

-- - Select the least 3 products in stock according to stores

WITH CTE1 AS
	 (SELECT *
	  FROM(SELECT *, ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY store_id, quantity) AS RowNumber
		   FROM product.stock) AS SUBQ1
	  WHERE RowNumber BETWEEN 1 AND 3
	 )
SELECT CTE1.store_id, B.store_name, P.product_id, P.product_name, CTE1.quantity
FROM CTE1 INNER JOIN sale.store AS B ON CTE1.store_id=B.store_id
		  INNER JOIN product.product AS P ON CTE1.product_id=P.product_id

-- /////////////////////////////////////////////////////////////

-- - Select the store which has the most sales quantity in 2018

SELECT TOP 1 b.store_name, SUM(c.quantity) AS TotalSales
FROM sale.orders AS a INNER JOIN sale.store AS b ON a.store_id=b.store_id INNER JOIN sale.order_item AS c ON a.order_id=c.order_id
WHERE YEAR(order_date)=2018
GROUP BY b.store_name
ORDER BY TotalSales DESC;

-- /////////////////////////////////////////////////////////////

-- - Select the store which has the most sales amount in 2018

SELECT TOP 1 b.store_name, SUM((C.quantity*C.list_price)*(1-C.discount)) AS TotalSalesAmount
FROM sale.orders AS a INNER JOIN sale.store AS b ON a.store_id=b.store_id INNER JOIN sale.order_item AS c ON a.order_id=c.order_id
WHERE YEAR(order_date)=2018
GROUP BY b.store_name
ORDER BY TotalSalesAmount DESC;

-- /////////////////////////////////////////////////////////////

-- - Select the personnel which has the most sales amount in 2018

SELECT TOP 1 B.first_name, B.last_name, SUM((C.quantity*C.list_price)*(1-C.discount)) AS TotalSalesAmount
FROM sale.orders AS A INNER JOIN sale.staff AS B ON A.staff_id=B.staff_id INNER JOIN sale.order_item AS C ON A.order_id=C.order_id
WHERE YEAR(order_date)=2018
GROUP BY B.first_name, B.last_name
ORDER BY TotalSalesAmount DESC;

-- ////////////////////////////////////////////////////////////

-- - Select the least 3 sold products in 2018 and 2019 according to city.

SELECT *
FROM(SELECT *, ROW_NUMBER() OVER(PARTITION BY [date] ORDER BY [date], TotalNumber) AS RowNumber
     FROM(SELECT product_id, YEAR(order_date) AS [date], SUM(quantity) AS TotalNumber
	      FROM sale.order_item AS A INNER JOIN sale.orders AS B ON A.order_id=B.order_id
	      WHERE YEAR(order_date) IN (2018,2019)
	      GROUP BY product_id, YEAR(order_date)) AS SUBQ1) AS SUBQ2
WHERE RowNumber BETWEEN 1 AND 3

-- //////////////////////////////////////////////////////////////

-- 1. Find the customers who placed at least two orders per year.

WITH CTE1 AS
	 (SELECT customer_id, YEAR(order_date) AS [DATE], count(order_id) AS OrderNumber
	  FROM sale.orders
	  GROUP BY customer_id, YEAR(order_date)
	  HAVING COUNT(order_id) > 1)
SELECT CTE1.customer_id, C.first_name, C.last_name, CTE1.OrderNumber 
FROM CTE1 INNER JOIN sale.customer AS C ON CTE1.customer_id=C.customer_id;

-- ///////////////////////////////////////////////////////////////

-- 2. Find the total amount of each order which are placed in 2020. Then categorize them according to limits stated below.(You can use case when statements here)

/*   If the total amount of order    
    
      less then 500 then "very low"
      between 500 - 1000 then "low"
      between 1000 - 5000 then "medium"
      between 5000 - 10000 then "high"
      more then 10000 then "very high"  
*/

SELECT A.order_id, SUM((quantity*list_price)*(1-discount)) AS TotalAmount,
	   CASE WHEN SUM((quantity*list_price)*(1-discount)) < 500 THEN 'very low'
	        WHEN SUM((quantity*list_price)*(1-discount)) < 1000 THEN 'low'
			WHEN SUM((quantity*list_price)*(1-discount)) < 5000 THEN 'medium'
			WHEN SUM((quantity*list_price)*(1-discount)) < 10000 THEN 'high'
			WHEN SUM((quantity*list_price)*(1-discount)) > 10000 THEN 'very high'
	   END TotalAmountCategory
FROM sale.order_item AS A INNER JOIN sale.orders AS B ON A.order_id=B.order_id
WHERE YEAR(order_date) = 2020
GROUP BY A.order_id

-- ////////////////////////////////////////////////////////////////

-- 3. By using Exists Statement find all customers who have placed more than two orders.

SELECT customer_id, first_name, last_name
FROM sale.customer AS C
WHERE EXISTS (SELECT COUNT(O.order_id) AS OrderNumber 
			  FROM sale.orders AS O 
			  WHERE C.customer_id=O.customer_id
			  GROUP BY O.customer_id
			  HAVING COUNT(O.order_id) > 2)
ORDER BY C.customer_id;

-- /////////////////////////////////////////////////////////////////

-- 4. Show all the products and their list price, that were sold with more than two units in a sales order.

SELECT P.product_id, P.product_name, P.list_price, COUNT(O.item_id) AS Units
FROM sale.order_item AS O,  product.product AS P 
WHERE O.product_id=P.product_id
GROUP BY P.product_id, P.product_name, P.list_price
HAVING COUNT(O.item_id) > 2;

-- /////////////////////////////////////////////////////////////////

-- 5. Show the total count of orders per product for all times. (Every product will be shown in one line and the total order count will be shown besides it)

SELECT O.product_id, P.product_name, COUNT(order_id) AS TotalCount
FROM sale.order_item AS O 
	 INNER JOIN product.product AS P ON O.product_id=P.product_id
GROUP BY O.product_id, P.product_name
ORDER BY O.product_id, P.product_name

-- /////////////////////////////////////////////////////////////////

-- 6. Find the products whose list prices are more than the average list price of products of all brands

SELECT product_id
FROM
	(SELECT brand_id, product_id, list_price, 
		    AVG(list_price) OVER(PARTITION BY brand_id) AS AvgListPriceofBrands
	 FROM product.product) AS SUBQ
WHERE list_price > AvgListPriceofBrands
