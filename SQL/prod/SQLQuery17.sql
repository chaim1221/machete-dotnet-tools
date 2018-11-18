--__________________________________________/ graton_demographics_8.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id>31
--dbcc checkident('reportdefinitions',reseed,31)
-- test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkersMissingDemographicInformation'
declare @commonName nvarchar(max) = N'Workers Missing Demographic Information'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = 'Finds workers with a raceid, incomeid or dateOfBirth of NULL and reports those members'' card numbers to the user'

-- the query. must cast types. NVARCHAR, DECIMAL not accepted!
declare @sqlquery nvarchar(max) = N'
  select 
    distinct(CAST(w.dwccardnum AS INT)) as [Member ID]
  , CAST(raceid AS INT) as [Race ID]
  , CAST(incomeid AS INT) as [Income ID]
  , CAST(dateOfBirth as DATETIME) as [Date of Birth]
  from workers w
  inner join workersignins wsi on w.id = wsi.workerid
  where wsi.dateforsignin >=  @beginDate and
  wsi.dateforsignin <= @endDate and (
  raceid is null
  or incomeid is null 
  or dateOfBirth is null
)
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
-- test values for the web
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be EXACT, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Member ID",
      "header": "Member ID",
      "visible": true
    },
    {
      "field": "Race ID",
      "header": "Race ID",
      "visible": true
    },
    {
      "field": "Income ID",
      "header": "Income ID",
      "visible": true
    },
	{
	  "field": "Date of Birth",
	  "header": "Date of Birth",
	  "visible": true
	}
  ]
'

declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_7.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 32
--dbcc checkident('reportdefinitions',reseed,32)

--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByAgeGroup'
declare @commonName nvarchar(max) = N'Worker Signins by Age Group'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Part of a series. For each member status, counts worker signins by age group.'

declare @sqlquery nvarchar(max) = N'
;with cte as (
  SELECT
    CASE when age between 12 and 17 then ''12 to 17''
         when age between 18 and 23 then ''18 to 23''
         when age between 24 and 44 then ''24 to 44''
         when age between 45 and 54 then ''45 to 54''
         when age between 55 and 69 then ''55 to 69''
         when age >= 70 then ''70+''
         else ''unknown''
         END AS [Age]
  , piv.[Active]	  
  , piv.[Expelled]  
  , piv.[Expired]	  
  , piv.[Inactive]  
  , piv.[Incomplete] 
  from (
    SELECT
      workers.ID
     ,DATEDIFF(YEAR, Workers.dateOfBirth, GETDATE()) as [Age]
     ,Lookups_MemberStatus.memberStatus_EN as [MemberStatus]
    FROM
      db_datareader.Lookups_MemberStatus AS Lookups_MemberStatus
      INNER JOIN Workers
        ON Lookups_MemberStatus.ID = Workers.memberStatus
      INNER JOIN WorkerSignins
        ON Workers.ID = WorkerSignins.WorkerID
      INNER JOIN Persons
        ON Persons.ID = Workers.ID
      INNER JOIN db_datareader.Lookups_Gender AS Lookups_Gender
        ON Lookups_Gender.ID = Persons.gender
    WHERE
      WorkerSignins.dateforsignin >= @beginDate and
      WorkerSignins.dateforsignin <= @endDate	  
  ) src 
  pivot (
    count(ID)
    for [MemberStatus] in ([Active], [Expelled], [Expired], [Inactive], [Incomplete])
  ) piv
)

select 
  CAST([Age] AS VARCHAR(20)) AS [Age]
 ,CAST(SUM([Active])	 AS INT) AS [Active]
 ,CAST(SUM([Expelled])	 AS INT) AS [Expelled]
 ,CAST(SUM([Expired])	 AS INT) AS [Expired]
 ,CAST(SUM([Inactive])	 AS INT) AS [Inactive]
 ,CAST(SUM([Incomplete]) AS INT) AS [Incomplete] 
from cte
GROUP BY [Age]
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Age",
      "header": "Age",
      "visible": true
    },
    {
      "field": "Active",
      "header": "Active",
      "visible": true
    },
    {
      "field": "Expelled",
      "header": "Expelled",
      "visible": true
    },
    {
      "field": "Expired",
      "header": "Expired",
      "visible": true
    },
    {
      "field": "Inactive",
      "header": "Inactive",
      "visible": true
    },
    {
      "field": "Incomplete",
      "header": "Incomplete",
      "visible": true
    }
  ]
'

declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_6.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 33
--dbcc checkident('reportdefinitions',reseed,33)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByRacialCategory'
declare @commonName nvarchar(max) = N'Worker Signins by Racial Category'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Part of a series. For each member status, counts worker signins by racial category.'

declare @sqlquery nvarchar(max) = N'
;with cte as (
  SELECT
    [Race]
  , piv.[Active]	  
  , piv.[Expelled]  
  , piv.[Expired]	  
  , piv.[Inactive]  
  , piv.[Incomplete] 
  from (
    SELECT
      workers.ID
     ,Lookups_Race.race_EN as [Race]
     ,Lookups_MemberStatus.memberStatus_EN as [MemberStatus]
    FROM
      db_datareader.Lookups_MemberStatus AS Lookups_MemberStatus
      INNER JOIN Workers
        ON Lookups_MemberStatus.ID = Workers.memberStatus
      INNER JOIN WorkerSignins
        ON Workers.ID = WorkerSignins.WorkerID
      INNER JOIN Persons
        ON Persons.ID = Workers.ID
      INNER JOIN db_datareader.Lookups_Race AS Lookups_Race
        ON Lookups_Race.ID = Workers.raceid
    WHERE
      WorkerSignins.dateforsignin >= @beginDate and
      WorkerSignins.dateforsignin <= @endDate	  
  ) src 
  pivot (
    count(ID)
    for [MemberStatus] in ([Active], [Expelled], [Expired], [Inactive], [Incomplete])
  ) piv
)

select 
  CAST([Race] AS VARCHAR(20)) AS [Race]
 ,CAST(SUM([Active])	 AS INT) AS [Active]
 ,CAST(SUM([Expelled])	 AS INT) AS [Expelled]
 ,CAST(SUM([Expired])	 AS INT) AS [Expired]
 ,CAST(SUM([Inactive])	 AS INT) AS [Inactive]
 ,CAST(SUM([Incomplete]) AS INT) AS [Incomplete] 
from cte
GROUP BY [Race]
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Race",
      "header": "Racial Category",
      "visible": true
    },
    {
      "field": "Active",
      "header": "Active",
      "visible": true
    },
    {
      "field": "Expelled",
      "header": "Expelled",
      "visible": true
    },
    {
      "field": "Expired",
      "header": "Expired",
      "visible": true
    },
    {
      "field": "Inactive",
      "header": "Inactive",
      "visible": true
    },
    {
      "field": "Incomplete",
      "header": "Incomplete",
      "visible": true
    }
  ]
'

declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'



-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_5.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 34
--dbcc checkident('reportdefinitions',reseed,34)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByIncome'
declare @commonName nvarchar(max) = N'Worker Signins by Income'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Part of a series. For each member status, counts worker signins by income.'

declare @sqlquery nvarchar(max) = N'
;with cte as (
  SELECT
    [Income]
  , piv.[Active]	  
  , piv.[Expelled]  
  , piv.[Expired]	  
  , piv.[Inactive]  
  , piv.[Incomplete] 
  from (
    SELECT
      workers.ID
     ,Lookups_Income.income_EN as [Income]
     ,Lookups_MemberStatus.memberStatus_EN as [MemberStatus]
    FROM
      db_datareader.Lookups_MemberStatus AS Lookups_MemberStatus
      INNER JOIN Workers
        ON Lookups_MemberStatus.ID = Workers.memberStatus
      INNER JOIN WorkerSignins
        ON Workers.ID = WorkerSignins.WorkerID
      INNER JOIN Persons
        ON Persons.ID = Workers.ID
      INNER JOIN db_datareader.Lookups_Income AS Lookups_Income
        ON Lookups_Income.ID = Workers.incomeid
    WHERE
      WorkerSignins.dateforsignin >= @beginDate and
      WorkerSignins.dateforsignin <= @endDate	  
  ) src 
  pivot (
    count(ID)
    for [MemberStatus] in ([Active], [Expelled], [Expired], [Inactive], [Incomplete])
  ) piv
)

select 
  CAST([Income] AS VARCHAR(40)) AS [Income]
 ,CAST(SUM([Active])	 AS INT) AS [Active]
 ,CAST(SUM([Expelled])	 AS INT) AS [Expelled]
 ,CAST(SUM([Expired])	 AS INT) AS [Expired]
 ,CAST(SUM([Inactive])	 AS INT) AS [Inactive]
 ,CAST(SUM([Incomplete]) AS INT) AS [Incomplete] 
from cte
GROUP BY [Income]
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Income",
      "header": "Income Category",
      "visible": true
    },
    {
      "field": "Active",
      "header": "Active",
      "visible": true
    },
    {
      "field": "Expelled",
      "header": "Expelled",
      "visible": true
    },
    {
      "field": "Expired",
      "header": "Expired",
      "visible": true
    },
    {
      "field": "Inactive",
      "header": "Inactive",
      "visible": true
    },
    {
      "field": "Incomplete",
      "header": "Incomplete",
      "visible": true
    }
  ]
'

declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_4.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 35
--dbcc checkident('reportdefinitions',reseed,35)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByGenderAndStatus'
declare @commonName nvarchar(max) = N'Worker Signins by Gender and Status'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Part of a series. For each member status, counts worker signins by gender.'

declare @sqlquery nvarchar(max) = N'
;with cte as (
  SELECT
    [Gender]
  , piv.[Active]	  
  , piv.[Expelled]  
  , piv.[Expired]	  
  , piv.[Inactive]  
  , piv.[Incomplete] 
  from (
    SELECT
      workers.ID
     ,Lookups_Gender.gender_EN as [Gender]
     ,Lookups_MemberStatus.memberStatus_EN as [MemberStatus]
    FROM
      db_datareader.Lookups_MemberStatus AS Lookups_MemberStatus
      INNER JOIN Workers
        ON Lookups_MemberStatus.ID = Workers.memberStatus
      INNER JOIN WorkerSignins
        ON Workers.ID = WorkerSignins.WorkerID
      INNER JOIN Persons
        ON Persons.ID = Workers.ID
      INNER JOIN db_datareader.Lookups_Gender AS Lookups_Gender
        ON Lookups_Gender.ID = Persons.gender
    WHERE
      WorkerSignins.dateforsignin >= @beginDate and
      WorkerSignins.dateforsignin <= @endDate	  
  ) src 
  pivot (
    count(ID)
    for [MemberStatus] in ([Active], [Expelled], [Expired], [Inactive], [Incomplete])
  ) piv
)

select 
  CAST([Gender] AS VARCHAR(20)) AS [Gender]
 ,CAST(SUM([Active])	 AS INT) AS [Active]
 ,CAST(SUM([Expelled])	 AS INT) AS [Expelled]
 ,CAST(SUM([Expired])	 AS INT) AS [Expired]
 ,CAST(SUM([Inactive])	 AS INT) AS [Inactive]
 ,CAST(SUM([Incomplete]) AS INT) AS [Incomplete] 
from cte
GROUP BY [Gender]
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Gender",
      "header": "Gender",
      "visible": true
    },
    {
      "field": "Active",
      "header": "Active",
      "visible": true
    },
    {
      "field": "Expelled",
      "header": "Expelled",
      "visible": true
    },
    {
      "field": "Expired",
      "header": "Expired",
      "visible": true
    },
    {
      "field": "Inactive",
      "header": "Inactive",
      "visible": true
    },
    {
      "field": "Incomplete",
      "header": "Incomplete",
      "visible": true
    }
  ]
'

declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_3.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 36
--dbcc checkident('reportdefinitions',reseed,36)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByGender'
declare @commonName nvarchar(max) = N'Worker Signins by Gender'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Part of a series. For each member status, counts worker signins by gender.'

declare @sqlquery nvarchar(max) = N'
;with cte as (
  SELECT  
    count(WorkerSignins.dateforsignin) as [WorkerSignins]
   ,Lookups_Gender.gender_EN as [Gender]
   ,Workers.dwccardnum as [MemberID]
  FROM
    db_datareader.Lookups_MemberStatus AS Lookups_MemberStatus
    INNER JOIN Workers
      ON Lookups_MemberStatus.ID = Workers.memberStatus
    INNER JOIN WorkerSignins
      ON Workers.ID = WorkerSignins.WorkerID
    INNER JOIN Persons
      ON Persons.ID = Workers.ID
    INNER JOIN db_datareader.Lookups_Gender AS Lookups_Gender
      ON Lookups_Gender.ID = Persons.gender
    INNER JOIN db_datareader.Lookups_Race AS Lookups_Race
      ON Lookups_race.ID = Workers.raceID
    INNER JOIN db_datareader.Lookups_Income AS Lookups_Income
      ON Lookups_income.ID = Workers.incomeID
  WHERE
    WorkerSignins.dateforsignin >= @beginDate and
    WorkerSignins.dateforsignin <= @endDate
  group by gender_EN, workers.dwccardnum
)

select 
  sum(case when Gender = ''Male'' then WorkerSignins else 0 end) as [Total Male]
, sum(case when Gender = ''Female'' then WorkerSignins else 0 end) as [Total Female]
, count(case when Gender = ''Male'' then 1 else 0 end) as [Unique Male]
, count(case when Gender = ''Female'' then 1 else 0 end) as [Unique Female]
, count(WorkerSignins) as [Total Unique]
, sum(WorkerSignins) as [Total Signins]
from cte
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Total Male",
      "header": "Total Male",
      "visible": true
    },
    {
      "field": "Total Female",
      "header": "Total Female",
      "visible": true
    },
    {
      "field": "Unique Male",
      "header": "Unique Male",
      "visible": true
    },
    {
      "field": "Unique Female",
      "header": "Unique Female",
      "visible": true
    },
    {
      "field": "Total Unique",
      "header": "Total Unique",
      "visible": true
    },
    {
      "field": "Total Signins",
      "header": "Total Signins",
      "visible": true
    }
  ]
'
declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_3.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 37
--dbcc checkident('reportdefinitions',reseed,37)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'EarningsByGender'
declare @commonName nvarchar(max) = N'Worker Earnings by Gender'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Part of a series. For each member status, counts worker earnings by gender.'

declare @sqlquery nvarchar(max) = N'
;with earnings as
(
SELECT
 lg.gender_EN, ((wa.hourlywage * wa.hours * wa.days)) as earned
FROM  workorders wo
inner join workassignments wa on wo.id = wa.workorderid
inner join workers w on wa.workerassignedID = w.id
inner join persons p on w.id = p.id
inner join db_datareader.Lookups_Gender lg on lg.id = p.gender
where wo.dateTimeofWork >= @beginDate and
 wo.dateTimeofWork <= @endDate
)
select 
  CAST(gender_EN AS VARCHAR(10)) as [Gender]
, cast(convert(decimal(16,2), sum(earned)) as float) as [Earned]
, CAST(count(gender_EN) AS INT) as [Assignment Count] 
from earnings 
group by gender_EN

union all 

select 
  CAST(''Total'' AS VARCHAR(10)) as [Gender]
, CAST(CONVERT(DECIMAL(16,2), sum(earned)) AS FLOAT) as [Earned]
, CAST(count(*) AS INT) as [Assignment Count]
from earnings
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Gender",
      "header": "Gender",
      "visible": true
    },
    {
      "field": "Earned",
      "header": "Earned",
      "visible": true
    },
    {
      "field": "Assignment Count",
      "header": "Assignment Count",
      "visible": true
    }
  ]
'
declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_1.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 38
--dbcc checkident('reportdefinitions',reseed,38)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByGender'
declare @commonName nvarchar(max) = N'Worker Signins By Gender'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Enumerates the gender values from the lookup table. For each, does a count of signins for that gender.'

-- the query. must cast types. NVARCHAR, DECIMAL not accepted!
declare @sqlquery nvarchar(max) = N'
select
  CAST(lg.gender_EN AS VARCHAR(10)) as [Gender]
, CAST(count(distinct(w.id)) AS INT) as [Unique Signins]
, CAST(count(w.id) AS INT) as [Total Signins]
from persons w 
inner join workersignins wsi on wsi.workerid = w.id
inner join db_datareader.Lookups_Gender lg on lg.id = w.gender
where   wsi.dateforsignin >= @beginDate and 
wsi.dateforsignin <= @endDate
group by gender_EN
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Gender",
      "header": "Gender",
      "visible": true
    },
	{
      "field": "Unique Signins",
      "header": "Unique Signins",
      "visible": true
    },
	{
      "field": "Total Signins",
      "header": "Total Signins",
      "visible": true
    }
  ]
'
declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'
-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_1.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 38
--dbcc checkident('reportdefinitions',reseed,38)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsByGender'
declare @commonName nvarchar(max) = N'Worker Signins By Gender'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Enumerates the gender values from the lookup table. For each, does a count of signins for that gender.'

-- the query. must cast types. NVARCHAR, DECIMAL not accepted!
declare @sqlquery nvarchar(max) = N'
select
  CAST(lg.gender_EN AS VARCHAR(10)) as [Gender]
, CAST(count(distinct(w.id)) AS INT) as [Unique Signins]
, CAST(count(w.id) AS INT) as [Total Signins]
from persons w 
inner join workersignins wsi on wsi.workerid = w.id
inner join db_datareader.Lookups_Gender lg on lg.id = w.gender
where   wsi.dateforsignin >= @beginDate and 
wsi.dateforsignin <= @endDate
group by gender_EN
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Gender",
      "header": "Gender",
      "visible": true
    },
	{
      "field": "Unique Signins",
      "header": "Unique Signins",
      "visible": true
    },
	{
      "field": "Total Signins",
      "header": "Total Signins",
      "visible": true
    }
  ]
'
declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'
-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--__________________________________________/ graton_demographics_0.sql \
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
-- NOTE: was Graton Demographics 0/8                                     |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id > 39
--dbcc checkident('reportdefinitions',reseed,39)
--test values
declare @beginDate datetime = '2017-01-01'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkerSigninsTotalCount'
declare @commonName nvarchar(max) = N'Worker Signins Total Count'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Total Counts for Registered Workers, Assigned Workers, Work Assignments and Work Orders'

-- the query. must cast types. NVARCHAR, DECIMAL not accepted!
declare @sqlquery nvarchar(max) = N'
select 
  CAST(''Registered workers'' AS VARCHAR(40)) as [Category]
, CAST(count(distinct(w.id)) AS INT) as [Count] 
from persons p
join workers w on (w.id = p.id)
join workersignins wsi on (w.id = wsi.workerID)
where wsi.dateforsignin >=  @beginDate and
wsi.dateforsignin <= @endDate

union all

select
  CAST(''Assigned workers'' AS VARCHAR(40)) as [Category]
, CAST(count(distinct(w.id)) AS INT)  as [Count] 
from persons p
join workers w on (w.id = p.id)
join workassignments wa on (w.id = wa.workerassignedid)
join workorders wo on (wa.workorderid = wo.id)
where wo.datetimeofwork >= @beginDate
and wo.datetimeofwork <= @endDate

union all

select
  CAST(''Individual work assignments'' AS VARCHAR(40)) as [Category]
, CAST(count(*) AS INT) as [Count]
from workassignments wa
inner join workorders wo on wa.workorderid = wo.id
where wo.dateTimeofWork >= @beginDate and
 wo.dateTimeofWork <= @endDate
 and wa.workerassignedid is not null

union all

select
  CAST(''Individual work orders'' AS VARCHAR(40)) as [Category]
, CAST(count(*) AS INT) as [Count]
 from workorders wo
 where wo.dateTimeofWork >= @beginDate and
 wo.dateTimeofWork <= @endDate
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    {
      "field": "Category",
      "header": "Category",
      "visible": true
    },
	{
      "field": "Count",
      "header": "Count",
      "visible": true
    }
  ]
'
declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
--______________________________/ voz_demographics_report_machete1_12.sql\
/****** Script for INSERT INTO command for MACHETE REPORTS (v1.12) ******|
-- Purpose: To add the Voz Demographics Report to Machete.               |
-- Author: Chaim Eliyah                                                  |
-- Synopsis: Since v1.12 includes in-app reporting, we are trying to add |
-- the reports that we have been doing for the centers directly to their |
-- databases. This script does that for one report. It can be reused to  |
-- generate other reports in the same fashion.                           |
--                                                                       |
-- NOTE: this was originally the "Voz Demographics Report"               |
\******                                             opsCard 2 (tm) ******/

--delete from dbo.reportdefinitions where id>40
--dbcc checkident('reportdefinitions',reseed,40)
-- test values
declare @beginDate datetime = '2017-01-01T00:00:00'
declare @endDate datetime = GETDATE()

declare @name nvarchar(max) = N'WorkAssignmentsBySkill'
declare @commonName nvarchar(max) = N'Work Assignments By Skill'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Enumerates the skills values from the lookup table. For each, does a count by month of dispatches for that skill. Totals and adds select of how many workers have that skill. Created 5/14/2017'

-- the query. must cast types. NVARCHAR, DECIMAL not accepted!
declare @sqlquery nvarchar(max) = N'
select
  convert(varchar(50), L.Skill) as ''Job Title''
, cast(A.SkillID as int) as ''ID''
, cast(January   as int) as ''January''
, cast(February  as int) as ''February''
, cast(March     as int) as ''March''
, cast(April     as int) as ''April''
, cast(May       as int) as ''May''
, cast(June      as int) as ''June''
, cast(July      as int) as ''July''
, cast(August    as int) as ''August''
, cast(September as int) as ''September''
, cast(October   as int) as ''October''
, cast(November  as int) as ''November''
, cast(December  as int) as ''December''
, cast(count(*)  as int) as ''Total This Year''
, cast(convert(decimal(16,2), avg(hourlyWage)) as float) as ''Average Wage''
, case when SkillCount is null then 0 else SkillCount end as ''Number of Workers With Skill''
from dbo.WorkAssignments A
join [dbo].[WorkOrders] W on A.workOrderID = W.ID 
join (
  select --*
    [SkillID]
  , [Skill]
  , case when [1] is NULL then 0 else [1] end as ''January''
  , case when [2] is NULL then 0 else [2] end as ''February''
  , case when [3] is NULL then 0 else [3] end as ''March''
  , case when [4] is NULL then 0 else [4] end as ''April''
  , case when [5] is NULL then 0 else [5] end as ''May''
  , case when [6] is NULL then 0 else [6] end as ''June''
  , case when [7] is NULL then 0 else [7] end as ''July''
  , case when [8] is NULL then 0 else [8] end as ''August''
  , case when [9] is NULL then 0 else [9] end as ''September''
  , case when [10] is NULL then 0 else [10] end as ''October''
  , case when [11] is NULL then 0 else [11] end as ''November''
  , case when [12] is NULL then 0 else [12] end as ''December''
  from (
      select 
          skillID as ''SkillID''
        , text_EN as ''Skill''
        , datepart(month, dateTimeOfWork) as ''Month''
        , count(*) as ''Count''
        from dbo.workAssignments A
        join dbo.workOrders O on A.workOrderID = O.ID
        join dbo.Lookups L on A.skillID = L.ID
        where dateTimeOfWork >= @beginDate
          and dateTimeOfWork <= @endDate
        group by text_EN, skillID, datepart(month,dateTimeOfWork)
        --order by datepart(month,dateTimeOfWork)
  ) src
  pivot
  (
    sum([Count])
    for [Month] in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
  ) piv
) L on A.skillID = L.SkillID
left join (
  select
    L.ID as ''ID''
  , L.text_EN ''English''
  , count(*) as ''SkillCount''
  from dbo.workers W
  join dbo.lookups L on L.ID = W.skill1 or L.ID = W.skill2 or L.ID = W.skill3
  group by L.ID, L.text_EN
) cte on A.skillID = cte.ID
where dateTimeOfWork >= @beginDate
  and dateTimeOfWork <= @endDate
group by  L.Skill, A.SkillID, January, February, March, April, May, June, July, August, September, October, November, December, SkillCount
order by count(*) desc
'
exec sp_executesql @sqlquery, N'@beginDate datetime, @endDate datetime', @beginDate, @endDate

declare @category nvarchar(max) = N'Demographics'
declare @subcategory nvarchar(max) = NULL
--test values for the web; don't touch
declare @inputsJson nvarchar(max) = N'{"beginDate":true,"beginDateDefault":"2016-01-01T00:00:00","endDate":true,"endDateDefault":"2017-01-01T00:00:00","memberNumber":false}'

-- single JSON array with three properties, "field" (string), "header" (string), and "visible" (bool)
-- "field" entries must be exact, "header" can vary
declare @columnsJson nvarchar(max)= N'
  [
    { 
      "field": "Job Title",
      "header": "Job",
      "visible": true
    },
    {
      "field": "ID",
      "header": "ID",
      "visible": false
    },
    {
      "field": "January",
      "header": "Jan",
      "visible": true
    },
    {
      "field": "February",
      "header": "Feb",
      "visible": true
    },
    {
      "field": "March",
      "header": "Mar",
      "visible": true
    },
    {
      "field": "April",
      "header": "Apr",
      "visible": true
    },
    {
      "field": "May",
      "header": "May",
      "visible": true
    },
    {
      "field": "June",
      "header": "Jun",
      "visible": true
    },
    {
      "field": "July",
      "header": "Jul",
      "visible": true
    },
    {
      "field": "August",
      "header": "Aug",
      "visible": true
    },
    {
      "field": "September",
      "header": "Sep",
      "visible": true
    },
    {
      "field": "October",
      "header": "Oct",
      "visible": true
    },
    {
      "field": "November",
      "header": "Nov",
      "visible": true
    },
    {
      "field": "December",
      "header": "Dec",
      "visible": true
    },
    {
      "field": "Total This Year",
      "header": "Total This Year",
      "visible": true
    },
    {
      "field": "Average Wage",
      "header": "Average Wage",
      "visible": true
    },
    {
      "field": "Number of Workers With Skill",
      "header": "Workers With Skill",
      "visible": true
    }
  ]
'
declare @dateCreated datetime = GETDATE()
declare @dateUpdated datetime = GETDATE()
declare @Createdby nvarchar(30) = 'Chaim Eliyah'
declare @Updatedby nvarchar(30) = 'Chaim Eliyah'

-------------------------------------------------
BEGIN TRANSACTION
INSERT INTO [dbo].[ReportDefinitions] (
     --[ID],
       [name]
      ,[commonName]
      ,[title]
      ,[description]
      ,[sqlquery]
      ,[category]
      ,[subcategory]
      ,[inputsJson]
      ,[columnsJson]
      ,[datecreated]
      ,[dateupdated]
      ,[Createdby]
      ,[Updatedby]
)
VALUES (
       @name
      ,@commonName
      ,@title
      ,@description
      ,@sqlquery
      ,@category
      ,@subcategory
      ,@inputsJson
      ,@columnsJson
      ,@datecreated
      ,@dateupdated
      ,@Createdby
      ,@Updatedby
)
--ROLLBACK TRANSACTION
COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
