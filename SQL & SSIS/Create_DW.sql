
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
- build the data warehouse (dimension and tables)
- build the staging tables(dimension and tables)
- create stored procedures
- create stored procedures for the dimensions and facts.
*/


-- Creating Data Warehouse
CREATE DATABASE PublisherDW
GO

-- Using Data Warehouse for Publisher
USE PublisherDW;
GO

-- Creating Title Dimension Table
CREATE TABLE Title_Dim
(TitleKey INT NOT NULL IDENTITY,
TitleID CHAR(20),
TitleName VARCHAR(100),
TitlePrice MONEY,
TitleType CHAR(50),
PublisherCity VARCHAR(100),
PublisherCountry VARCHAR(100),
PRIMARY KEY (TitleKey));
GO

-- Creating Calendar Dimension Table
CREATE TABLE Calendar_Dim
(CalendarKey INT NOT NULL IDENTITY,
FullDate DATETIME,
DayofWeek_ CHAR(15),
DayofMonth_ INT,
Month_	CHAR(10),
Quarter_ CHAR(2),
Year_ INT,
PRIMARY KEY (CalendarKey));
GO

-- Creating Store Dimension Table
CREATE TABLE Store_Dim
(StoreKey INT NOT NULL IDENTITY,
StoreId CHAR(50),
StoreName CHAR(100),
StoreCity CHAR(100),
StoreState CHAR(100),
StoreDiscount INT,
PRIMARY KEY (StoreKey));
GO

-- Creating Sales Fact Table
CREATE TABLE Sales_Fact
(FactID INT NOT NULL IDENTITY,
CalendarKey INT,
StoreKey INT,
TitleKey INT,
Qty INT,
GrossTotal MONEY,
DiscountTotal MONEY,
NetTotal MONEY,
PRIMARY KEY(FactID),
FOREIGN KEY (Calendarkey) REFERENCES Calendar_Dim (CalendarKey),
FOREIGN KEY (StoreKey) REFERENCES Store_Dim (StoreKey),
FOREIGN KEY (Titlekey) REFERENCES Title_Dim (TitleKey),
);

-----------------------------------
-- Creating ETL Run
CREATE TABLE ETLRun
(ETLRunKey INT NOT NULL IDENTITY,
TableName varchar(200) NOT NULL,
ETLStatus varchar(25) NULL,
StartTime datetime NULL,
EndTime   datetime NULL,
RecordCount INT NULL
CONSTRAINT PK_ETLRun PRIMARY KEY CLUSTERED 
(
	ETLRunKey ASC
));
GO

-----------------------------------
-- Creating CreateETLLoggingRecord

CREATE or ALTER PROCEDURE CreateETLLoggingRecord
	@TableName varchar(200),
	@ETLID INT OUTPUT
AS
BEGIN
	--Insert a new record into the ETLRun table and return the ETLID that was generated
    INSERT INTO ETLRun
           (TableName
           ,ETLStatus
           ,StartTime
           ,EndTime
           ,RecordCount)
     VALUES
           (@TableName
           ,'Running'
           ,getdate()
           ,NULL
           ,NULL)

	SET @ETLID = SCOPE_IDENTITY(); -- RETURNS LAST IDENTITY VALUE INSERTED INTO AN IDENTITY COLUMN

END
GO

-----------------------------------
-- Creating UpdateETLLoggingRecord Store Procedure
CREATE or ALTER PROCEDURE UpdateETLLoggingRecord
	@ETLID INT,
	@RecordCount INT
AS
BEGIN
	--Insert a new record into the ETLRun table and return the ETLID that was generated
	update ETLRun 
	set	EndTime = getdate(),
		ETLStatus = 'Success',
		RecordCount = @RecordCount
	where ETLRunKey = @ETLID;

END
GO

---------------------------------------------
-- Creating staging Title Dimension table
CREATE TABLE stg_Title_Dim 
(
TitleID CHAR(20),
TName VARCHAR(100),
TPrice MONEY,
TType CHAR(50),
TCity VARCHAR(50),
TCountry VARCHAR(50),
CONSTRAINT stg_TitleKey PRIMARY KEY CLUSTERED
(TitleID ASC));
GO

-- Creating staging Store Dimension table
CREATE TABLE stg_Store_Dim 
(StoreId CHAR(50),
SName CHAR(100),
SCity CHAR(50),
SState CHAR(50),
SDiscount INT,
CONSTRAINT stg_StoreKey PRIMARY KEY CLUSTERED
(StoreID ASC));
GO

-- Creating staging Calendar Dimension table
CREATE TABLE stg_Calendar_Dim 
(CalendarKey INT NOT NULL IDENTITY,
FullDate DATETIME,
DayofWeek_ CHAR(15),
DayofMonth_ INT,
Month_	CHAR(10),
Quarter_ CHAR(2),
Year_ INT,
CONSTRAINT stg_CalendarKey PRIMARY KEY CLUSTERED
(CalendarKey ASC));
GO

-- Creating staging Sales Fact table
CREATE TABLE stg_Sales_Fact
(FactID INT NOT NULL IDENTITY,
CalendarKey INT,
StoreKey INT,
TitleKey INT,
QTY INT,
GrossTotal MONEY,
DiscountTotal MONEY,
NetTotal MONEY,
);
GO


---------------------------------------------
-----------Calendar_Dim Type 1---------------
---------------------------------------------

CREATE or ALTER PROCEDURE Merge_Calendar_Dim
@RecordCount INT OUTPUT
AS
BEGIN
		--Merge from the staging table into the final dimension table
		--FullDate, DayofWeek_, DayofMonth_,Month_, Quarter_,Year_
		MERGE INTO Calendar_Dim tgt
		USING stg_Calendar_Dim src ON tgt.FullDate = src.FullDate
		WHEN MATCHED AND EXISTS 
                (
			select src.FullDate, src.DayofWeek_, src.DayofMonth_, src.Month_, src.Quarter_, src.Year_
			except 
			select tgt.FullDate, tgt.DayofWeek_, tgt.DayofMonth_, tgt.Month_, tgt.Quarter_, tgt.Year_

		)
		THEN UPDATE
		SET 
			tgt.FullDate = src.FullDate,
			tgt.DayofWeek_ = src.DayofWeek_,
			tgt.DayofMonth_ = src.DayofMonth_,
			tgt.Month_ = src.Month_,
			tgt.Quarter_ = src.Quarter_,
			tgt.Year_ = src.Year_


		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		  FullDate
		  ,DayofWeek_
		  ,DayofMonth_
		  ,Month_
		  ,Quarter_
		  ,Year_
		)
		VALUES
		(
			src.FullDate
			,src.DayofWeek_
			,src.DayofMonth_
			,src.Month_
			,src.Quarter_
			,src.Year_
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount;
	
END
GO



---------------------------------------------
-----------Store_Dim Type 1 & 3--------------
---------------------------------------------

ALTER TABLE Store_Dim
ADD 
	PrevDiscount varchar(100),
	PrevName varchar(100),
	PrevCity varchar(100),
	PrevState varchar(100),
	StartDate datetime,
	EndDate datetime,
	DateInserted datetime default getdate(),
	DateUpdated datetime default getdate()
GO



CREATE or ALTER PROCEDURE Merge_Store_Dim
@PackageStartTime datetime,
@RecordCount INT OUTPUT
AS
BEGIN
	
	/*
	StoreName		= Type 3
	StoreDiscount	= Type 3
	StoreCity		= Type 3
	StoreState		= Type 3
	*/


		--Type 1 and 3 changes
		MERGE INTO Store_Dim tgt
		USING stg_Store_Dim src ON tgt.StoreID = src.StoreID
		WHEN MATCHED AND EXISTS 
		(	
			select src.SName, src.SCity, src.SState, src.SDiscount
			except 
			select tgt.StoreName,  tgt.StoreCity, tgt.StoreState, tgt.StoreDiscount
		)
		THEN UPDATE
		SET
			tgt.StoreName = src.SName,
			tgt.PrevName = CASE WHEN src.SName <> tgt.StoreName THEN tgt.StoreName ELSE tgt.PrevName END,

			tgt.StoreCity = src.SCity,
			tgt.PrevCity = CASE WHEN src.SCity <> tgt.StoreCity THEN tgt.StoreCity ELSE tgt.PrevCity END,

			tgt.StoreState = src.SState,
			tgt.PrevState = CASE WHEN src.SState <> tgt.StoreState THEN tgt.StoreState ELSE tgt.PrevState END,

			tgt.StoreDiscount = src.SDiscount,
			tgt.PrevDiscount = CASE WHEN src.SDiscount <> tgt.StoreDiscount THEN tgt.StoreDiscount ELSE tgt.PrevDiscount END,

			tgt.DateUpdated = @PackageStartTime

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   StoreID
		  ,StoreName
		  ,StoreCity
		  ,StoreState
		  ,StoreDiscount
		  ,StartDate
		  ,EndDate
		  ,DateInserted
		  ,DateUpdated
		)
		VALUES
		(
			 src.StoreID
			,src.SName
			,src.SCity
			,src.SState
			,src.SDiscount
			,@PackageStartTime
			,NULL
			,@PackageStartTime
			,@PackageStartTime
		);

END
GO

---------------------------------------------
-----------Title_Dim Type 1 & 3--------------
---------------------------------------------

ALTER TABLE Title_Dim
ADD 
	PrevPrice varchar(100),
	PrevCity varchar(100),
	PrevCountry varchar(100),
	StartDate datetime,
	EndDate datetime,
	DateInserted datetime default getdate(),
	DateUpdated datetime default getdate()
GO



CREATE or ALTER PROCEDURE Merge_Title_Dim
@PackageStartTime datetime,
@RecordCount INT OUTPUT
AS
BEGIN
	
	/*
	TitleName			= Type 1
	TitlePrice			= Type 3
	TitleType			= Type 1
	PublisherCity		= Type 3
	PublisherCountry	= Type 3
	*/


		--Type 1 and 3 changes
		MERGE INTO Title_Dim tgt
		USING stg_Title_Dim src ON tgt.TitleID = src.TitleID
		WHEN MATCHED AND EXISTS 
		(	
			select src.TName, src.TType, src.TCity, src.TCountry,src.TPrice
			except 
			select tgt.TitleName, tgt.TitleType, tgt.PublisherCity, tgt.PublisherCountry, tgt.TitlePrice
		)
		THEN UPDATE
		SET
			tgt.TitleName = src.TName,

			tgt.TitlePrice = src.TPrice,
			tgt.PrevPrice = CASE WHEN src.TPrice <> tgt.TitlePrice THEN tgt.TitlePrice ELSE tgt.PrevPrice END,

			tgt.PublisherCity = src.TCity,
			tgt.PrevCity = CASE WHEN src.TCity <> tgt.PublisherCity THEN tgt.PublisherCity ELSE tgt.PrevCity END,

			tgt.PublisherCountry = src.TCountry,
			tgt.PrevCountry = CASE WHEN src.TCountry <> tgt.PublisherCountry THEN tgt.PublisherCountry ELSE tgt.PrevCountry END,

			tgt.TitleType = src.TType, 
			tgt.DateUpdated = @PackageStartTime

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   TitleID
		  ,TitleName
		  ,TitlePrice
		  ,TitleType
		  ,PublisherCity
		  ,PublisherCountry
		  ,StartDate
		  ,EndDate
		  ,DateInserted
		  ,DateUpdated
		)
		VALUES
		(
			 src.TitleID
			,src.TName
			,src.TPrice
			,src.TType
			,src.TCity
			,src.TCountry
			,@PackageStartTime
			,NULL
			,@PackageStartTime
			,@PackageStartTime
		);
	
END
GO


---------------------------------------------
---------------Sales_Fact--------------------
---------------------------------------------
CREATE OR ALTER   PROCEDURE Merge_Sales_Fact
@RecordCount INT OUTPUT
AS
BEGIN

		MERGE INTO Sales_Fact tgt
		USING stg_Sales_Fact src ON tgt.FactID = src.FactID
		WHEN MATCHED AND EXISTS 
		(SELECT src.CalendarKey,src.StoreKey, src.TitleKey, src.Qty, src.GrossTotal, src.DiscountTotal, src.NetTotal
		 except
		 SELECT tgt.CalendarKey,tgt.StoreKey, tgt.TitleKey, tgt.QTY, tgt.GrossTotal, tgt.DiscountTotal, tgt.NetTotal)
		THEN UPDATE
		SET 
			tgt.CalendarKey = src.CalendarKey,
			tgt.StoreKey = src.StoreKey,
			tgt.TitleKey = src.TitleKey,
			tgt.Qty = src.Qty,
			tgt.GrossTotal = src.GrossTotal,
			tgt.DiscountTotal = src.DiscountTotal,
			tgt.NetTotal = src.NetTotal

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		    CalendarKey ,
			StoreKey ,
			TitleKey ,
			Qty ,
			GrossTotal ,
			DiscountTotal ,
			NetTotal
		)
		VALUES
		(
			src.CalendarKey ,
			src.StoreKey ,
			src.TitleKey ,
			src.Qty ,
			src.GrossTotal ,
			src.DiscountTotal ,
			src.NetTotal
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount;
	
END
GO