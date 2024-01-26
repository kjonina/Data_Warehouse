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
- update the original Publisher database to see Type 1 and Type 3 changes in the occuring with ETL 
*/

USE Publisher

-----------------------------------------------------------------
----------------Update Publisher and Run First ETL---------------
-----------------------------------------------------------------


-- Adding more datat into the sales table
insert sales values('7066', 'SA7442.3', '06/13/20', 55, 'ON invoice','PS2091')
insert sales values('7067', 'DS4482', '06/14/20', 35, 'Net 60','PS2091')
insert sales values('7131', 'NS914008', '06/14/20', 10, 'Net 30','PS2091')
insert sales values('7131', 'NS914014', '06/14/20', 65, 'Net 30','MC3021')
insert sales values('8042', '4S23LL922', '06/14/20', 37, 'ON invoice','MC3021')
insert sales values('8042', 'S423LL930', '06/14/20', 58, 'ON invoice','BU1032')
insert sales values('6380', 'S722a', '06/13/20', 36, 'Net 60','PS2091')
insert sales values('6380', '6S871', '06/14/20', 52, 'Net 60','BU1032')
insert sales values('8042','PS723', '07/11/20', 75, 'Net 30', 'BU1111')
insert sales values('7896','XS999', '07/21/20', 58, 'ON invoice', 'BU2075')
insert sales values('7896','QSQ2299', '07/28/20', 5, 'Net 60', 'BU7832')
insert sales values('7896','TSQ456', '07/12/20', 19, 'Net 60', 'MC2222')
insert sales values('8042','QSA879.1', '07/22/20', 24, 'Net 30', 'PC1035')
insert sales values('7066','AS2976', '07/24/20', 26, 'Net 30', 'PC8888')
insert sales values('7131','PS3087a', '07/29/20', 12, 'Net 60', 'PS1372')
insert sales values('7131','PS3087a', '07/29/20', 23, 'Net 60', 'PS2106')
insert sales values('7131','PS3087a', '07/29/20', 25, 'Net 60', 'PS3333')
insert sales values('7131','PS3087a', '07/29/20', 20, 'Net 60', 'PS7777')
insert sales values('7067','PS2121', '07/15/20', 30, 'Net 30', 'TC3218')
insert sales values('7067','PS2121', '07/15/20', 10, 'Net 30', 'TC4203')
insert sales values('7067','PS2121', '07/15/20', 20, 'Net 30', 'TC7777')

insert sales values('7066', 'QA7442b', '10/13/20', 55, 'ON invoice','PS2091')
insert sales values('7067', 'D4482b', '10/14/20', 20, 'Net 60','PS2091')
insert sales values('7131', 'N914008b', '10/14/20', 10, 'Net 30','PS2091')
insert sales values('7131', 'N914014b', '10/14/20', 25, 'Net 30','MC3021')
insert sales values('8042', '423LL922b', '10/14/20', 25, 'ON invoice','MC3021')
insert sales values('8042', '423LL930b', '10/14/20', 20, 'ON invoice','BU1032')
insert sales values('6380', '722ab', '09/13/20', 8, 'Net 60','PS2091')
insert sales values('6380', '6871b', '09/14/20', 15, 'Net 60','BU1032')
insert sales values('8042','P723b', '09/11/20', 50, 'Net 30', 'BU1111')
insert sales values('7896','X999b', '09/21/20', 85, 'ON invoice', 'BU2075')
insert sales values('7896','QQ2299b', '09/28/20', 5, 'Net 60', 'BU7832')
insert sales values('7896','TQ456b', '09/12/20', 20, 'Net 60', 'MC2222')
insert sales values('8042','QA879b', '09/22/20', 50, 'Net 30', 'PC1035')
insert sales values('7066','A2976b', '09/24/20', 30, 'Net 30', 'PC8888')
insert sales values('7131','P3087ab', '09/29/20', 10, 'Net 60', 'PS1372')
insert sales values('7131','P3087ab', '09/29/20', 15, 'Net 60', 'PS2106')
insert sales values('7131','P3087ab', '09/29/20', 25, 'Net 60', 'PS3333')
insert sales values('7131','P3087ab', '09/29/20', 15, 'Net 60', 'PS7777')
insert sales values('7067','P2121b', '09/15/20', 20, 'Net 30', 'TC3218')
insert sales values('7067','P2121b', '09/15/20', 40, 'Net 30', 'TC4203')
insert sales values('7067','P2121', '09/15/20', 30, 'Net 30', 'TC7777')

GO



--Checking that Type 1 and Type 3 changes have worked.
UPDATE titles
SET title = 'The Secret of Silicon Valley' 
WHERE title = 'Secrets of Silicon Valley'

UPDATE titles
SET type = 'beg_cook'
WHERE type = 'trad_cook'


UPDATE locations
SET city = 'Paris', state = Null, country = 'France'
WHERE  city = 'Chicago' and state = 'IL' and country = 'USA'

UPDATE locations
SET city = 'Vancouver', country = 'Canada'
WHERE city = 'MÅunich'and country = 'Germany'


--run this first and then update with ETL.
UPDATE stores
SET stor_name = 'Welcome to Hogwarts', city = 'Los Angelos', state = 'CA'
WHERE stor_name = 'Eric the Read Books'

-----------------------------------------------------------------
----------------Update Publisher and Run Second ETL--------------
-----------------------------------------------------------------
UPDATE stores
SET city = 'Dallas', state = 'TX'
WHERE stor_name = 'News & Brews'
