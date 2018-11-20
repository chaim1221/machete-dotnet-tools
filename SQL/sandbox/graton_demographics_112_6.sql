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

declare @name nvarchar(max) = N'GratonDemographicsWorkerSigninsByRacialCategory'
declare @commonName nvarchar(max) = N'Graton Demographics: Worker Signins by Racial Category'
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
ROLLBACK TRANSACTION
--COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
