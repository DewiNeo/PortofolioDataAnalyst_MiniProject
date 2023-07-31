USE Portofolio_DataAnalyst_MiniProject

SELECT * FROM Orders

-- DISPLAY CUSTOMER DATA from Orders WITHOUT ANY REDUNDANT DATA
SELECT DISTINCT [Customer Id], 
	[Customer Name],
	[Country],
	[Region],
	[State or Province],
	[City],
	[Postal Code]
FROM Orders

-- DISPLAY PRODUCT DATA FROM Orders WITHOUT ANY REDUNDANT DATA
SELECT DISTINCT [Product Name],
	[Product Category]
FROM Orders
ORDER BY [Product Category] 


-- DISPLAY CUSTOMER TOTAL PAYMENT TRANSACTION
SELECT [Customer ID], 
	[Customer Name],[Unit Price],
	[Quantity ordered new],
	[Discount],
	TotalPayment = CONCAT('$ ', ([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount]))
FROM Orders
ORDER BY [Customer ID]


-- DISPLAY TOP 10 CUSTOMERS DATA WITH THE BIGGEST TOTAL PAYMENT
SELECT TOP 10 [Customer ID], 
	[Customer Name],
	TotalTransactionID = COUNT(DISTINCT [Order Id]),
	TotalPayment = SUM(([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount]))
FROM Orders
GROUP BY [Customer ID], [Customer Name]
ORDER BY TotalPayment desc


-- DISPLAY CUSTOMERS WHO FREQUENTLY DO TRANSACTIONS
SELECT [Customer ID], 
	[Customer Name],
	TotalPayment = SUM(([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount])),
	TotalTransactionID = COUNT(DISTINCT [Order Id])
FROM Orders
GROUP BY [Customer ID], 
	[Customer Name]
ORDER BY TotalTransactionID desc


-- SELECT THE MOST PRODUCT HAD BEEN PURCHASE
SELECT DISTINCT [Product Name],
	[Product Category],
	[TheMostProductPurchase]= COUNT([Product Name]) OVER (PARTITION BY [Product Name])
FROM Orders
ORDER BY [TheMostProductPurchase] DESC

-- SELECT THE MOST PRODUCT CATEGORY HAD BEEN PURCHASE
SELECT DISTINCT [Product Category],
	[TheMostProductCategoryPurchase]= COUNT([Product Category]) OVER (PARTITION BY [Product Category])
FROM Orders
ORDER BY [TheMostProductCategoryPurchase] DESC


-- CREATING TEMP TABLE FOR PRODUCT DATA
DROP TABLE IF EXISTS #Temp_ProductList

CREATE TABLE #Temp_ProductList(
	ProductName VARCHAR(255),
	ProductCategory VARCHAR(255)
)

INSERT INTO #Temp_ProductList
SELECT DISTINCT[Product Name],
	[Product Category]
FROM Orders
ORDER BY [Product Category] 

SELECT * FROM #Temp_ProductList
ORDER BY ProductCategory 


-- SHOWING TOTAL PRODUCT IN ONE CATEGORY PRODUCT [USING TEMP DATA]
SELECT ProductName,
	ProductCategory,
	[TotalProduct] = COUNT(ProductName) OVER (PARTITION BY ProductCategory)
FROM #Temp_ProductList
ORDER BY ProductCategory 


-- SHOWING CUSTOMER AVARAGE TOTAL PAYMENT
SELECT [Customer ID], 
	[Customer Name],
	TotalTransactionID = COUNT(DISTINCT [Order Id]),
	TotalPayment = SUM(([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount])),
	AvgPayment = AVG(([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount]))
FROM Orders
GROUP BY [Customer ID], 
	[Customer Name]
ORDER BY TotalTransactionID desc



-- SHOWING TOTAL AVARAGE OF SUPERSTORE_US_2015
SELECT DISTINCT AvgPayment = AVG(sub.sumPayment)
FROM Orders,
(
	SELECT DISTINCT SUM(([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount])) AS sumPayment
	FROM Orders
)sub
GROUP BY [Customer ID], 
	[Customer Name]

	
-- SHOWING CUSTOMER DATA WO HAD ABOVE THE AVERAGE OF TRANSACTION
SELECT O.[Customer ID],
	[Customer First Name] = SUBSTRING(O.[Customer Name], 1, CHARINDEX(' ', O.[Customer Name]+' ')-1),
	TotalTransactionID = COUNT(DISTINCT O.[Order ID]),
	AvgTotTransaction = AVG(sub.CountTransID)
FROM Orders O,
(
	SELECT [Customer ID],
		[Customer Name],
		COUNT(DISTINCT[Order Id]) AS CountTransID
	FROM Orders
	GROUP BY  [Customer ID], [Customer Name]
)sub
GROUP BY O.[Customer ID], O.[Customer Name]
HAVING COUNT(DISTINCT O.[Order ID]) > AVG(sub.CountTransID)
ORDER BY TotalTransactionID DESC


-- DISPLAYIN TRANSACTION THAT HANDLE BY MANAGER
SELECT  U.Manager,
		U.Region,
		O.[Order ID],
		[OrderDate] = CAST (DAY(O.[Order Date]) AS VARCHAR)
							+' - ' + CONVERT(VARCHAR, MONTH(O.[Order Date] )) 
							+ ' - ' + CAST(YEAR(O.[Order Date] ) AS VARCHAR),
		TotalPayment = SUM((O.[Unit Price] * O.[Quantity ordered new]) - (O.[Unit Price] * O.[Quantity ordered new] * O.[Discount]))
FROM Users U 
JOIN Orders O ON U.Region = O.Region
GROUP BY U.Manager, U.Region, O.[Order ID], O.[Customer Name], O.[Order Date]
ORDER BY U.Manager


-- DISPLAYIN TOTAL TRANSACTION THAT HANDLE BY MANAGER
SELECT  U.Manager,
		U.Region,
		[Total Transaction Id] = CONCAT(COUNT(DISTINCT O.[Order ID]),' Transaction')
FROM Users U 
JOIN Orders O ON U.Region = O.Region
GROUP BY U.Manager, U.Region
ORDER BY U.Manager


-- DISPLAYIN TOP 10 BIGGEST TRANSACTION BY REGION
SELECT TOP 10 
	O.[Customer ID], 
	[Customer First Name] = SUBSTRING(O.[Customer Name], 1, CHARINDEX(' ', O.[Customer Name]+' ')-1),
	U.Region,
	U.Manager,
	TotalTransactionID = CONCAT(COUNT(DISTINCT [Order Id]),' Transaction'),
	TotalPayment = SUM(([Unit Price] * [Quantity ordered new]) - ([Unit Price] * [Quantity ordered new] * [Discount]))
FROM Orders O
JOIN Users U ON O.Region = U.Region
WHERE O.Region LIKE 'WEST'
GROUP BY O.[Customer ID], O.[Customer Name], U.Region, U.Manager
ORDER BY TotalPayment desc


-- DISPLAYIN TOP 10 PRODUCT BY REGION
SELECT TOP 10 
	O.[Product Category], 
	O.[Product Name],
	U.Region,
	U.Manager,
	[Total Product solded] = CONCAT(COUNT(O.[Product Name]), ' Transaction')
FROM Orders O
JOIN Users U ON O.Region = U.Region
WHERE O.Region LIKE 'CENTRAL'
GROUP BY O.[Product Category], O.[Product Name], U.Region, U.Manager
ORDER BY [Total Product solded] DESC


-- CREATE VIEW [ TRANSACTION THAT HANDLE BY MANAGER ]
CREATE VIEW TransactioHandleBy AS
SELECT  U.Manager,
		U.Region,
		O.[Order ID],
		[OrderDate] = CAST (DAY(O.[Order Date]) AS VARCHAR)
							+' - ' + CONVERT(VARCHAR, MONTH(O.[Order Date] )) 
							+ ' - ' + CAST(YEAR(O.[Order Date] ) AS VARCHAR),
		TotalPayment = CONCAT('$ ', SUM((O.[Unit Price] * O.[Quantity ordered new]) - (O.[Unit Price] * O.[Quantity ordered new] * O.[Discount])))
FROM Users U 
JOIN Orders O ON U.Region = O.Region
GROUP BY U.Manager, U.Region, O.[Order ID], O.[Customer Name], O.[Order Date]

SELECT * FROM TransactioHandleBy

