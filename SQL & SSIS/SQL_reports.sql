

/*	Group CA - 50%
Student Name:	Karina Jonina	10543032
				Pauline Lloyd	10525563 
				Stephen Quinn	10537441 
Course:			Higher Diploma in Science in Data Analytics	
Module:			Data Warehousing and Business Intelligence
Module Code:	B8IT104
Lecturer:		Kunwar Madan
Date:			1st November 2020
*/

/*
Aim of this document is to 
- run SQL queries ON Data Warehouse (PublisherDW) 
*/


USE PublisherDW
GO


-------------------------------------------------------------
--What is the best performing Title in terms of Revenue Total?
Create View [Revenue Total for each Title] AS
SELECT rank, TitleName, NetTotal  'Revenue Total',
CASE
	WHEN NetTotal < 1000 THEN 'Low Revenue Total'
	WHEN NetTotal >=  1000 THEN 'High Revenue Total'
	ELSE 'No Sales' --catch null values
END 'High / Low Revenue Total', MaxNet AS 'Max Revenue Per Order', MinNet AS'Min Revenue Per Order'
FROM 
(SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, TitleName, NetTotal, MaxNet, MinNet FROM
(Select TitleName, SUM(NetTotal) NetTotal, MAX(NetTotal) MaxNet, MIN(NetTotal) MinNet 
FROM PublisherDW.dbo.Sales_Fact s FULL JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
GROUP BY TitleName)a)A


SELECT * FROM [Revenue Total for each Title]

-------------------------------------------------------------
--What is the Revenue Total per Month per Title?
Create View [Revenue Total by Month per Title] AS
SELECT TitleName, Month_, Year_, NetTotal  'Revenue Total',
CASE
	WHEN NetTotal < 500 THEN 'Low Revenue Total'
	WHEN NetTotal >=  500 THEN 'High Revenue Total'
	ELSE 'No Sales' --catch null values
END 'High / Low Revenue Total', MaxNet AS 'Max Revenue Per Order', MinNet AS'Min Revenue Per Order'
FROM 
(SELECT TitleName, Month_, Year_, NetTotal, MaxNet, MinNet FROM
(Select TitleName, Month_, Year_, SUM(NetTotal) NetTotal, MAX(NetTotal) MaxNet, MIN(NetTotal) MinNet 
FROM PublisherDW.dbo.Store_Dim st FULL JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
FULL JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
FULL JOIN PublisherDW.dbo.Calendar_Dim cal ON s.CalendarKey = cal.CalendarKey
GROUP BY TitleName, Month_, Year_)a)A

SELECT * FROM [Revenue Total by Month per Title] 
-------------------------------------------------------------
---What is the best performing Title Type in terms of Revenue Total?
Create View [Revenue Total for each Title Type] AS 
SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, TitleType, NetTotal AS 'Revenue Total' FROM
(SELECT  t.TitleType,sum(s.NetTotal) NetTotal
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
 GROUP BY TitleType)A

SELECT * FROM [Revenue Total for each Title Type]
--------------------------------------------------------------
---What Stores generate the most Revenue Total?
Create View [Revenue Total for each Store Name] AS
SELECT rank, StoreName, NetTotal AS 'Revenue Total',
CASE
	WHEN NetTotal < 3500 THEN 'Low Revenue Total'
	WHEN NetTotal >=  3500 THEN 'High Revenue Total'
	ELSE 'NO Sales' --catch null values
END NetTotals,  MaxNet AS 'Max Revenue Per Order', MinNet AS'Min Revenue Per Order' 
FROM 
(SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, StoreName, NetTotal, MaxNet, MinNet FROM
(SELECT StoreName,  SUM(NetTotal) NetTotal, MAX(NetTotal) MaxNet, MIN(NetTotal) MinNet 
FROM PublisherDW.dbo.Store_Dim st LEFT JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
GROUP BY st.StoreName)a)A

SELECT * FROM [Revenue Total for each Store Name]
--------------------------------------------------------------------
---What Store Cities  generate the most Revenue Total?
Create View [Revenue Total for each Store City] AS
SELECT RANK() OVER (ORDER BY NetTotal DESC) rank,  StoreCity, NetTotal AS 'Revenue Total' FROM
(SELECT  st.StoreCity,  sum(s.NetTotal) NetTotal
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Store_Dim st
ON s.StoreKey = st.StoreKey
 GROUP BY StoreCity)a

SELECT * FROM [Revenue Total for each Store City]
-----------------------------------------------------------------
---What Store State  generate the most Revenue Total?
Create View [Revenue Total for each Store State] AS
SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, StoreState, NetTotal AS 'Revenue Total' FROM
(SELECT  st.StoreState, sum(s.NetTotal) NetTotal
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Store_Dim st
ON s.StoreKey = st.StoreKey
 GROUP BY StoreState)a

SELECT * FROM [Revenue Total for each Store State]
--------------------------------------------------------------------
---What PublisherHouse City generates the most Revenue Total?
Create View [Revenue Total for each Publisher City] AS
SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, PublisherCity, NetTotal AS 'Revenue Total' FROM
(SELECT  t .PublisherCity, sum(s. NetTotal) NetTotal
FROM PublisherDW.dbo.Sales_Fact s FULL JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
GROUP BY PublisherCity)a

SELECT * FROM [Revenue Total for each Publisher City]

--------------------------------------------------------------
---What Stores generate the most Revenue Total for Washington Publishing House?
Create View [Revenue Total for each Store Name for Washington Publishing House] AS
SELECT rank, StoreName, NetTotal AS 'Revenue Total',
CASE
	WHEN NetTotal < 1000 THEN 'Low Revenue Total'
	WHEN NetTotal >=  1000 THEN 'High Revenue Total'
	ELSE 'NO Sales' --catch null values
END NetTotals,  MaxNet AS 'Max Revenue Per Order', MinNet AS'Min Revenue Per Order' 
FROM 
(SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, StoreName, NetTotal, MaxNet, MinNet FROM
(SELECT StoreName,  SUM(NetTotal) NetTotal, MAX(NetTotal) MaxNet, MIN(NetTotal) MinNet 
FROM PublisherDW.dbo.Store_Dim st full JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
full JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
WHERE PublisherCity = 'Washington'
GROUP BY st.StoreName)a)A

SELECT * FROM [Revenue Total for each Store Name for Washington Publishing House]
--------------------------------------------------------------------

-- What is the YTD Revenue by Title for Washington Publishing House?
Create View [Total YTD Revenue by Title for Washington Publishing House] AS

SELECT t.TitleName, t.TitleType, sum(s.NetTotal) NetTotal
FROM PublisherDW.dbo.Store_Dim st FULL JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
LEFT JOIN PublisherDW.dbo.Calendar_Dim cal ON s.CalendarKey = cal.CalendarKey
where PublisherCity = 'Washington' AND
Year_ = 2020
GROUP BY t.titlename, t.titletype
 
 SELECT * FROM [Total YTD Revenue by Title for Washington Publishing House]

 --------------------------------------------------------------------
---What PublisherHouse Country generate the most Revenue Total?
Create View [Revenue Total for each Publisher Country] AS
SELECT PublisherCountry, NetTotal AS 'Revenue Total' FROM
(SELECT t .PublisherCountry, sum(s. NetTotal) AS NetTotal
FROM PublisherDW.dbo.Sales_Fact s FULL JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
 GROUP BY PublisherCountry)A

SELECT * FROM [Revenue Total for each Publisher Country]

-----------------------------------------------------------------------
---What Title Type generates the most Revenue in a specific Store (e.g. Bookbeat)?
Create View [Revenue Total for Title Type in a Bookbeat] AS
SELECT RANK() OVER (ORDER BY NetTotal DESC) rank, StoreName, TitleType,  NetTotal AS 'Revenue Total' FROM
(SELECT t .TitleType ,st.StoreName, sum(s. NetTotal) NetTotal
FROM PublisherDW.dbo.Sales_Fact s join PublisherDW.dbo.Title_Dim t ON s.TitleKey = t.TitleKey
full JOIN PublisherDW.dbo.Store_Dim st ON s.StoreKey = st.StoreKey
WHERE StoreName = 'Bookbeat'
GROUP BY TitleType, StoreName)a

SELECT * FROM [Revenue Total for Title Type in a Bookbeat]

--------------------------------------------------------------
--What is the best performing Title in terms of Gross Total?
Create View [Gross Total for each Title] AS
SELECT rank, TitleName, GrossTotal  'Gross Total',
CASE
	WHEN GrossTotal < 2250 THEN 'Low Gross Total'
	WHEN GrossTotal >=  2250 THEN 'High Gross Total'
	ELSE 'No Sales' --catch null values
END 'High / Low Gross Total', MaxGT AS 'Max Gross Total Per Order', MinGT AS'Min Gross Total Per Order'
FROM 
(SELECT RANK() OVER (ORDER BY GrossTotal DESC) rank, TitleName, GrossTotal, MaxGT, MinGT FROM
(Select TitleName, SUM(GrossTotal) GrossTotal, MAX(GrossTotal) MaxGT, MIN(GrossTotal) MinGT 
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
GROUP BY TitleName)a)A

SELECT * FROM [Gross Total for each Title]

--------------------------------------------------------------
---What Stores generate the most Gross Total?
Create View [Gross Total for each Store Name] AS
SELECT rank, StoreName, GrossTotal AS 'Gross Total',
CASE
	WHEN GrossTotal < 3500 THEN 'Low Gross Total'
	WHEN GrossTotal >=  3500 THEN 'High Gross Total'
	ELSE 'NO Sales' --catch null values
END GrossTotal,  MaxGT AS 'Max Gross Total Per Order', MinGT AS'Min Gross Total Per Order' 
FROM 
(SELECT RANK() OVER (ORDER BY GrossTotal DESC) rank, StoreName, GrossTotal, MaxGT, MinGT FROM
(SELECT StoreName,  SUM(GrossTotal) GrossTotal, MAX(GrossTotal) MaxGT, MIN(GrossTotal) MinGT 
FROM PublisherDW.dbo.Store_Dim st left JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
GROUP BY st.StoreName)a)A

SELECT * FROM [Gross Total for each Store Name]



--------------------------------------------------------------------
--What is the Discount Value for each Store?
Create View [Discount Total for Store Name] AS
SELECT RANK() OVER (ORDER BY SDiscount DESC) rank, StoreName, SDiscount AS 'Discount Total' FROM
(SELECT  st.StoreName, sum(s.DiscountTotal) SDiscount
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Store_Dim st
ON s.StoreKey = st.StoreKey
GROUP BY StoreName)a

SELECT * FROM [Discount Total for Store Name]

-------------------------------------------------------------------------------------
--Which Title is most ordered (quantity)?
Create View [Quantity Sold for each Title] AS
SELECT Rank, TitleName, Quantity  'Quantity Sold',
CASE
	WHEN Quantity < 50 THEN 'Low Quantity Sold'
	WHEN Quantity >=  50 THEN 'High Quantity Sold'
	ELSE 'No Quantity Sold' --catch null values
END 'High / Low Quantity_Order', MaxQty AS 'Max Quantity Per Order', MinQty AS 'Min Quantity Per Order'
FROM 
(SELECT RANK() OVER (ORDER BY Quantity DESC) rank, TitleName, Quantity,MaxQty, MinQty FROM
(Select TitleName, SUM(Qty) Quantity, MAX(Qty) MaxQty, MIN(Qty) MinQty
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
GROUP BY TitleName)a)A

SELECT * FROM [Quantity Sold for each Title]

-------------------------------------------------------------
--What Title Type  is most ordered (quantity)?
Create View [Quantity Sold for each Title Type] AS 
SELECT  RANK() OVER (ORDER BY Qty DESC) rank, TitleType, Qty AS 'Quantity Sold'FROM
(SELECT  t.TitleType,sum(s.Qty) Qty
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
GROUP BY TitleType)a

SELECT * FROM [Quantity Sold for each Title Type]

-------------------------------------------------------------
--Which TitleType is ordered by day of the week – ordered by the day of the week with the most orders?
Create View [Quantity Sold for each Title Type by Day of Week] AS 
SELECT TitleType, DayofWeek_, Qty AS 'Quantity Sold'FROM
(SELECT  t.TitleType, DayofWeek_, sum(s.Qty) Qty
FROM PublisherDW.dbo.Store_Dim st FULL JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
LEFT JOIN PublisherDW.dbo.Calendar_Dim cal ON s.CalendarKey = cal.CalendarKey
GROUP BY DayofWeek_, TitleType)a

SELECT * FROM [Quantity Sold for each Title Type by Day of Week]

--------------------------------------------------------------------
-- What Quantity of books did each store buy?
Create View [Quantity Sold to each Store] AS
SELECT Rank,  StoreName, Quantity AS 'Quantity Sold',
CASE
	WHEN Quantity < 250 THEN 'Low Quantity Sold'
	WHEN Quantity >=  250 THEN 'High Quantity Sold'
	ELSE 'No Quantity Sold' --catch null values
END 'High / Low Quantity_Order', MaxQty AS 'Max Quantity Per Order', MinQty AS 'Min Quantity Per Order'
FROM (SELECT RANK() OVER (ORDER BY Quantity DESC) rank, StoreName, Quantity, MaxQty, MinQty FROM
(SELECT StoreName, SUM(Qty) Quantity, MAx(Qty) MaxQty, MIN(Qty) MinQty
FROM PublisherDW.dbo.Store_Dim st left JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
left JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
GROUP BY st.StoreName)a)A

SELECT * FROM [Quantity Sold to each Store] 

--------------------------------------------------------------------
-- What quantity of books were purchased in each States?
Create View [Quantity Sold for each Store State] AS
SELECT RANK() OVER (ORDER BY Qty DESC) rank, StoreState, Qty AS 'Quantity Sold'FROM
(SELECT  st.StoreState, sum(s.Qty) Qty
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Store_Dim st
ON s .StoreKey = st.StoreKey
GROUP BY StoreState)a

SELECT * FROM [Quantity Sold for each Store State]

--------------------------------------------------------------------
-- What quantity of books were purchased in each States by Quarter and Year?
Create View [Quantity Sold for each Store State by Quarter and Year] AS
SELECT StoreState, Quarter_, Year_, Qty AS 'Quantity Sold'FROM
(SELECT  st.StoreState, Quarter_, Year_, sum(s.Qty) Qty
FROM PublisherDW.dbo.Store_Dim st FULL JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
LEFT JOIN PublisherDW.dbo.Calendar_Dim cal ON s.CalendarKey = cal.CalendarKey
GROUP BY StoreState, Year_, Quarter_)a

SELECT * FROM [Quantity Sold for each Store State by Quarter and Year]


--------------------------------------------------------------------
-- What quantity of books did each Publisher Country sell?
Create View [Quantity Sold for each Publisher Country] AS
SELECT RANK() OVER (ORDER BY Qty DESC) rank, PublisherCountry, Qty AS 'Quantity Sold' FROM
(SELECT t .PublisherCountry, sum(s. Qty) Qty
FROM PublisherDW.dbo.Sales_Fact s full JOIN
PublisherDW.dbo.Title_Dim t
ON s.TitleKey = t.TitleKey
GROUP BY PublisherCountry)a

SELECT * FROM  [Quantity Sold for each Publisher Country] 

--------------------------------------------------------------------
-- What quantity of books did each Publisher City sell during a particular week this year?
Create View [Quantity Sold for each Publisher City for 2nd week of Sept 2020] AS
SELECT t.PublisherCity, sum(s. Qty) Qty
FROM PublisherDW.dbo.Store_Dim st FULL JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
LEFT JOIN PublisherDW.dbo.Calendar_Dim cal ON s.CalendarKey = cal.CalendarKey
where Month_ = 9 AND
Year_ = 2020 AND
DayofMonth_ Between 8 and 14
GROUP BY PublisherCity

SELECT * FROM  [Quantity Sold for each Publisher City for 2nd week of Sept 2020]


--------------------------------------------------------------------
-- What Title Type was ordered most in a specific Store (e.g. Bookbeat)?
Create View [Quantity sold in Bookbeat] AS 
SELECT  RANK() OVER (ORDER BY Qty DESC) rank,  StoreName, TitleType, Qty AS 'Quantity Sold' FROM
(SELECT t .TitleType ,st.StoreName, sum(s. Qty) Qty
FROM PublisherDW.dbo.Sales_Fact s join PublisherDW.dbo.Title_Dim t ON s.TitleKey = t.TitleKey
full JOIN PublisherDW.dbo.Store_Dim st ON s.StoreKey = st.StoreKey
WHERE StoreName = 'Bookbeat'
GROUP BY StoreName, TitleType) a

SELECT * FROM [Quantity sold in Bookbeat]

--------------------------------------------------------------------
--What are the Titles in the Top Quartile for Revenue Total?
Create View [Titles in Top Quartile for Revenue Total] AS
Select TitleName  AS 'Title Names in Top Quartile', TitleType, NetTotal AS 'Revenue Total' FROM
(SELECT TitleName,TitleType, NetTotal, NTILE(4) OVER(ORDER BY NetTotal DESC) quartile
FROM 
(SELECT TitleName,TitleType, sum(NetTotal) NetTotal
FROM
PublisherDW.dbo.Sales_Fact s  
full JOIN PublisherDW.dbo.Title_Dim t 
ON t.TitleKey = s.TitleKey
 GROUP BY TitleName, TitleType)a)a
WHERE quartile = 1

SELECT * FROM [Titles in Top Quartile for Revenue Total] 


--What are the Titles in the Bottom Quartile for Revenue Total?
Create View [Titles in Bottom Quartile for Revenue Total] AS
Select TitleName AS 'Title Names in Bottom Quartile',TitleType, NetTotal AS 'Revenue Total' FROM
(SELECT TitleName,TitleType, NetTotal, NTILE(4) OVER(ORDER BY NetTotal DESC) quartile
FROM 
(SELECT TitleName,TitleType, sum(NetTotal) NetTotal
FROM
PublisherDW.dbo.Sales_Fact s  
full JOIN PublisherDW.dbo.Title_Dim t 
ON t.TitleKey = s.TitleKey
GROUP BY TitleName, TitleType)a)a
WHERE quartile = 4

SELECT * FROM [Titles in Bottom Quartile for Revenue Total]

--------------------------------------------------------------------
--What are the top titles sold by State in Revenue Total?
Create View [Top Title in each State] AS
SELECT  StoreState, TitleName as 'Top Selling Title Name', TitleType, NetTotal as 'Revenue Total' FROM
(SELECT rank, StoreState, TitleName, TitleType, NetTotal  FROM
(SELECT RANK() OVER (PARTITION BY StoreState ORDER BY NetTotal DESC) rank, StoreState, TitleName, TitleType, NetTotal  FROM
(SELECT StoreState, TitleName, TitleType, SUM(NetTotal) NetTotal
FROM PublisherDW.dbo.Store_Dim st LEFT JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
GROUP BY StoreState, TitleName, TitleType)A)a
WHERE rank = 1)A


SELECT * FROM [Top Title in each State] 


-------------------------------------------------------------------
-- What is the best-selling title by title type by Revenue Total?
Create View [Top Selling  Title by Type] AS
Select TitleType,TitleName as 'Top Selling Title Name',  NetTotal AS 'Revenue Total' from
(SELECT TitleName, TitleType, NetTotal, rank FROm
(SELECT TitleName, TitleType, NetTotal,
DENSE_RANK() OVER (PARTITION BY TitleType ORDER BY NetTotal DESC) RANK
from
(SELECT t.TitleName, t.TitleType, sum(s.NetTotal) NetTotal
FROM PublisherDW.dbo.Store_Dim st full JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
full JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
 GROUP BY t.titlename, t.titletype)a)A
where rank =1)A


SELECT * FROM [Top Selling  Title by Type]

--------------------------------------------------------------------
-- 	What is the best-selling title purchased by each Store by Revenue Total?
Create View [Top Selling Title purchased by Store] AS
Select StoreName, TitleName,  NetTotal AS 'Revenue Total' from
(SELECT StoreName, TitleName,NetTotal, rank FROm
(SELECT StoreName, TitleName, NetTotal,
DENSE_RANK() OVER (PARTITION BY StoreName ORDER BY NetTotal DESC) RANK
from
(SELECT t.TitleName, st.StoreName, sum(s.NetTotal) NetTotal
FROM PublisherDW.dbo.Store_Dim st LEFT JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
LEFT JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey
 GROUP BY st.StoreName, t.TitleName, t. TitleType)a)A
where rank =1)A

SELECT * FROM [Top Selling Title purchased by Store]



--------------------------------------------------------------------
-- How many Titles  are there in each Type?
Create View [Number of Title in each Type] AS
SELECT SUM(CASE WHEN TitleType = 'popular_comp' THEN 1 ELSE 0 END) 'Popular Computer',
		SUM(CASE WHEN TitleType = 'psychology' THEN 1 ELSE 0 END) 'Psychology',
		SUM(CASE WHEN TitleType = 'business' THEN 1 ELSE 0 END) 'Business',
		SUM(CASE WHEN TitleType = 'mod_cook' THEN 1 ELSE 0 END) 'Modern Cookbook',
		SUM(CASE WHEN TitleType = 'beg_cook' THEN 1 ELSE 0 END) 'Cookbook for Beginners'
FROM PublisherDW.dbo.Store_Dim st full JOIN PublisherDW.dbo.Sales_Fact s ON st.StoreKey = s.StoreKey
full JOIN PublisherDW.dbo.Title_Dim t ON t.TitleKey = s.TitleKey

SELECT * FROM [Number of Title in each Type]


--------------------------------------------------------------------
-- Which Store changed location ordered by descending date?
Create View [Store changed location ordered by descending date] AS
SELECT StoreName , PrevName as 'Previous StoreName', StoreCity as 'Current City', StoreState as 'Current State', PrevCity as 'Previous City', 
PrevState as 'Previous State', DateUpdated, RANK() OVER (ORDER BY DateUpdated DESC) rank FROM
(SELECT StoreName, PrevName, StoreCity, PrevCity, StoreState, PrevState, DateUpdated
FROM PublisherDW.dbo.Store_Dim st 
WHERE PrevCity IS NOT NULL OR
PrevState IS NOT NULL)A

SELECT * FROM [Store changed location ordered by descending date]