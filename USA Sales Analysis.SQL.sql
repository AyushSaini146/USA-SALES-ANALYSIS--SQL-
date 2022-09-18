CREATE DATABASE Supermarket_Sales
USE Supermarket_Sales

SELECT * FROM Sales
SELECT * FROM products
SELECT * FROM Store_Locations
SELECT * FROM Customers
SELECT * FROM Sales_Team
SELECT * FROM Regions


--- Q1. Give the list of products having profit < 650000                                
SELECT P.product_Name,
SUM(S.Unit_Price*S.Order_Quantity) AS Total_sale_revenue,
SUM(S.Unit_Cost*S.Order_Quantity) AS Total_Cost_To_Company,
SUM(S.Unit_Price*S.Order_Quantity-S.Unit_Cost*S.Order_Quantity) AS Total_profit
FROM Sales S JOIN products P
ON S._ProductID = P._ProductID
GROUP BY P.product_Name
HAVING SUM(S.Unit_Price*S.Order_Quantity-S.Unit_Cost*S.Order_Quantity) <650000
ORDER BY Total_profit DESC


--- Q2. Show the delivery time taken to deliver the products according to the city.           
SELECT [City Name], product_Name,
(DATEDIFF(DAY,OrderDate,DeliveryDate)) AS Days_Taken_To_Deliver
FROM Sales JOIN products 
ON Sales._ProductID = products._ProductID JOIN Store_Locations 
ON Store_Locations._StoreID = Sales._StoreID
ORDER BY  Days_Taken_To_Deliver DESC

---Q3. Update the Name of row 'In-store' into 'In_store' From Column '[Sales Channel]' Of 'Sales' Table.(Because 'In-store' name is giving error in code)                     
UPDATE Sales
SET [Sales Channel]= 'In_store'
WHERE [Sales Channel]='In-store';

--- Q4. Show the total sales according to different Sale channels(Online,In-Store,Wholesale,Distributor).                                 
SELECT [Sales Channel],
SUM(CASE WHEN [Sales Channel]='Online' THEN 1 ELSE 0 END) AS Online_,
SUM(CASE WHEN [Sales Channel]='Wholesale'THEN 1 ELSE 0 END) AS Wholesale,
SUM (CASE WHEN [Sales Channel]='Distributor'THEN 1 ELSE 0 END) AS Distributor,
SUM(CASE WHEN [Sales Channel]='In_store' THEN 1 ELSE 0 END) AS In_Store
FROM Sales
WHERE [Sales Channel] in ('Online','Wholesale','Distributor','In_Store')
GROUP BY [Sales Channel]

---              OR


WITH CTE AS (SELECT [Sales Channel],                                                                                   
SUM(CASE WHEN [Sales Channel]='Online' THEN 1 ELSE 0 END) AS Sales_
FROM Sales
WHERE [Sales Channel]='Online'
GROUP BY [Sales Channel]
UNION
SELECT [Sales Channel],
SUM(CASE WHEN [Sales Channel]='Wholesale'THEN 1 ELSE 0 END)
FROM Sales
WHERE [Sales Channel]='Wholesale'
GROUP BY [Sales Channel]
UNION
SELECT [Sales Channel],
SUM (CASE WHEN [Sales Channel]='Distributor'THEN 1 ELSE 0 END) 
FROM Sales
WHERE [Sales Channel]='Distributor'
GROUP BY [Sales Channel]
UNION
SELECT [Sales Channel],
SUM(CASE WHEN [Sales Channel]='In_store' THEN 1 ELSE 0 END)
FROM Sales
WHERE [Sales Channel]='In_store'
GROUP BY [Sales Channel])
SELECT * FROM CTE
ORDER BY Sales_ DESC


---Q5. Show the products on which the profit is > 50%
SELECT Product_Name,
SUM(ROUND(Unit_Price*Order_Quantity,0)) AS Total_sale_revenue,
SUM(ROUND(Unit_Cost*Order_Quantity,0)) AS Total_Cost_To_Company,
SUM(ROUND(Unit_Price*Order_Quantity-Unit_Cost*Order_Quantity,0)) AS Total_profit,
ROUND(Sum(Round(Unit_Price * Order_Quantity,0) - Round(Unit_Cost * Order_Quantity,0))/Sum(Round(Unit_Cost * Order_Quantity,0))* 100,0)AS Percent_Profit 
FROM Sales JOIN products 
ON Sales._ProductID = Products._ProductID
GROUP BY Product_Name
HAVING ROUND(Sum(Round(Unit_Price * Order_Quantity,0) - Round(Unit_Cost * Order_Quantity,0))/Sum(Round(Unit_Cost * Order_Quantity,0))* 100,0)>50
ORDER BY Percent_Profit DESC


--- Q6. Show the shipping time, Dispatching time and the total delivery time taken to deliver the product according to the city.
 SELECT [City Name],Product_Name,
DATEDIFF(DAY,OrderDate,ShipDate) AS Shipping_Time,
DATEDIFF(DAY,ShipDate,DeliveryDate)AS Dispatching_Time,
DATEDIFF(DAY,Orderdate,DeliveryDate)AS Total_Delivery_Time
FROM Sales JOIN Store_Locations
ON Sales._StoreID = Store_Locations._StoreID JOIN Products
ON Sales._ProductID = Products._ProductID


---Q7. Show the top 5 customers who placed maximum orders.
SELECT TOP 5 Customers.[Customer Names],COUNT(Sales.Customer_id) AS Total_Orders
FROM Sales JOIN Customers 
ON Sales.Customer_id = Customers.Customer_id
GROUP BY Customers.[Customer Names]
ORDER BY COUNT(Sales.Customer_id) DESC

-- Q8. Show the top 5 Most demanded Products.
SELECT TOP 5 Sales._ProductID,Product_Name,COUNT(OrderNumber) AS Total_Orders,
ROUND(SUM(unit_price*Order_Quantity),0) AS total_Revenue_Generated
FROM Sales JOIN Products
ON Sales._ProductID = Products._ProductID
GROUP BY  Sales._ProductID,Product_Name
ORDER BY Total_Orders DESC


---Q9. Find the Yearly Percentage Profit of Each City.
SELECT [City Name],
YEAR(OrderDate) AS Year_,
ROUND(Sum(Round(Unit_Price * Order_Quantity,0) - Round(Unit_Cost * Order_Quantity,0))/Sum(Round(Unit_Cost * Order_Quantity,0))* 100,0)AS Percent_Profit 
FROM Sales JOIN Store_Locations
ON Sales._StoreID = Store_Locations._StoreID
GROUP BY [City Name],YEAR(OrderDate)
ORDER BY Year_

---Q10. Show Month Over Month Sales in Year '2020'.
SELECT MONTH(Sales.OrderDate) AS Month_Number,DATENAME(MONTH,Sales.OrderDate) AS Month_Name,
ROUND(SUM(Sales.Order_Quantity),0) AS Total_Quantity_Sold,
ROUND(LAG(SUM(Sales.Order_Quantity))OVER(ORDER BY MONTH(Sales.OrderDate)),0) AS Lag_sales,
ROUND(SUM(Sales.Order_Quantity)-LAG(SUM(Sales.Order_Quantity))OVER(ORDER BY MONTH(Sales.OrderDate)),0) AS Difference_in_sales
FROM Sales JOIN Products
ON Sales._ProductID = Products._ProductID
WHERE DATEPART (YEAR FROM Sales.OrderDate) = '2020'
GROUP BY MONTH(Sales.OrderDate),DATENAME(MONTH,Sales.OrderDate)
ORDER BY  MONTH(Sales.OrderDate)

---Similarly---

---Q11. Show Month Wise products sale in Year '2020'
SELECT Product_Name, MONTH(OrderDate) AS Month_Number,DATENAME(MONTH,OrderDate) AS Month_Name,
SUM(Order_Quantity) AS Total_Quantity_Sold,
SUM(Order_Quantity*Sales.Unit_price) AS Total_Sales_in_Price
FROM Sales JOIN Products
ON Sales._ProductID = Products._ProductID
WHERE DATEPART (YEAR FROM Sales.OrderDate) = '2020'
GROUP BY Product_Name,MONTH(OrderDate),DATENAME(MONTH,OrderDate)
ORDER BY  MONTH(OrderDate) ASC,Total_Sales_in_Price DESC