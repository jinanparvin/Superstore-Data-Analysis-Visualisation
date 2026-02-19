	--Establish relationship between the tables
ALTER TABLE orders
ALTER COLUMN OrderId nvarchar(255) NOT NULL 

ALTER TABLE orders
ADD CONSTRAINT pk_orderid PRIMARY KEY (OrderId)


ALTER TABLE orderbreakdown
ALTER COLUMN  OrderId nvarchar(255) NOT NULL

ALTER TABLE orderbreakdown
ADD CONSTRAINT fk_orderid FOREIGN KEY (OrderId) REFERENCES orders(OrderId)

--Q2. Split City State Country into 3 individual columns namely ‘City’, ‘State’, ‘Country’. */

ALTER TABLE OrdersList
ADD City nvarchar(255),
	States nvarchar(255),
	Country nvarchar(255);
UPDATE OrdersList 
SET City = PARSENAME(REPLACE([City_State_Country], ',','.'),3),
	States = PARSENAME(REPLACE([City_State_Country], ',','.'),2),
	Country = PARSENAME(REPLACE([City_State_Country], ',','.'),1);

Alter Table OrdersList
Drop Column [City_State_Country]
SELECT * FROM OrdersList;
SELECT * FROM EachOrderBreakdown;
 


 --Add a new Category Column using the following mapping as per the first 3 characters in the Product Name Column:
--TEC- Technology
--OFS – Office Supplies
--FUR - Furniture */

ALTER TABLE EachOrderBreakdown
ADD Category nvarchar(255)
UPDATE EachOrderBreakdown
SET Category = Case When LEFT(ProductName,3)='OFS' THEN 'Office Supplies'
					When LEFT(ProductName,3)='TEC' THEN 'Technology'
					When LEFT(ProductName,3)='FUR' THEN 'Furniture'
				END;

SELECT * FROM EachOrderBreakdown	

 


--Q4. Delete the first 4 characters from the ProductName Column.
UPDATE EachOrderBreakdown
SET ProductName = SUBSTRING(ProductName,5,LEN(ProductName)-4)
SELECT* FROM EachOrderBreakdown
 


--Q5. Remove duplicate rows from EachOrderBreakdown table, if all column values are matching.
WITH CTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY OrderID, ProductName, Discount, Sales, Profit, Quantity,
			Category,SubCategory ORDER BY OrderID) AS rn
		FROM EachOrderBreakdown
)
DELETE FROM CTE
WHERE rn > 1


--Q6. Replace blank with NA in OrderPriority Column in OrdersList table

UPDATE OrdersList
SET OrderPriority = 'NA'
WHERE OrderPriority = '' OR OrderPriority IS NULL;
SELECT *
FROM OrdersList



--DATA EXPLORATION

--1.List the top 10 orders with the highest sales from the EachOrderBreakdown table.

Select * from EachOrderBreakdown;
Select * from OrdersList;


select top 10 * from EachOrderBreakdown
order by Sales Desc;

 


--2.Show the number of orders for each product category in the EachOrderBreakdown table.
Select Category, Count(OrderId) AS Total_Orders From EachOrderBreakdown 
group by Category;

 
--3.Find the total profit for each sub-category in the EachOrderBreakdown table.
SELECT SubCategory,
       SUM([Profit($)]) AS Total_Profit
FROM EachOrderBreakdown
GROUP BY SubCategory;



--4.Identify the customer with the highest total sales across all orders.
SELECT TOP 1 
       o.CustomerName,
       SUM(e.[Sales($)]) AS TotalSale
FROM EachOrderBreakdown e
JOIN OrdersList o
  ON o.OrderID = e.OrderID
GROUP BY o.CustomerName
ORDER BY TotalSale DESC;

 


--5.Find the month with the highest average sales in the OrdersList table.

SELECT TOP 1
       MONTH(o.OrderDate) AS [Month],
       AVG(e.[Sales($)]) AS AvgSales
FROM OrdersList o
JOIN EachOrderBreakdown e
     ON o.OrderID = e.OrderID
GROUP BY MONTH(o.OrderDate)
ORDER BY AvgSales DESC;


 



--6.Find out the average quantity ordered by customers whose first name starts with an alphabet 's'?


 SELECT ROUND(AVG(e.Quantity), 2) AS AvgQuantity
FROM OrdersList o
JOIN EachOrderBreakdown e
     ON o.OrderID = e.OrderID
WHERE o.CustomerName LIKE 'S%';


 

--7.Find out how many new customers were acquired in the year 2014?
Select Count (*) AS TotalNewMember From 
(SELECT CustomerName, Min(OrderDate) AS FirstOrderDate
From OrdersList 
Group By CustomerName
Having Year(MIN(OrderDate)) = '2014') AS CustomerWithFirstOrderIn2014

 

--8.Calculate the percentage of total profit contributed by each sub-category to the overall profit.

SELECT
    SubCategory,
    SUM([Profit($)]) AS Subcategory_Profit,
    SUM([Profit($)]) * 100.0 / 
    SUM(SUM([Profit($)])) OVER () AS Percentage_Profit_Contributed
FROM EachOrderBreakdown
GROUP BY SubCategory;


 


--9.Find the average sales per customer, considering only customers who have made more than one order.


 WITH CustomerAvgSales AS (
    SELECT
        o.CustomerName,
        COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
        AVG(e.[Sales($)]) AS AvgSales
    FROM OrdersList o
    JOIN EachOrderBreakdown e
         ON o.OrderID = e.OrderID
    GROUP BY o.CustomerName
)
SELECT
    CustomerName,
    AvgSales
FROM CustomerAvgSales
WHERE NumberOfOrders > 1;



-- 10 .Identify the top-performing subcategory in each category based on total sales.
       -- Include the sub-category name, total sales,and a ranking of sub-category within each category. 
WITH TopSubcategory AS (
    SELECT
        Category,
        SubCategory,
        SUM([Sales($)]) AS TotalSales,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY SUM([Sales($)]) DESC
        ) AS SubcategoryRank
    FROM EachOrderBreakdown
    GROUP BY Category, SubCategory
)
SELECT
    Category,
    SubCategory,
    TotalSales,
    SubcategoryRank
FROM TopSubcategory
WHERE SubcategoryRank = 1;


