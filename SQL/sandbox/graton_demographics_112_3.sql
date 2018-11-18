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

declare @name nvarchar(max) = N'GratonDemographicsWorkerSigninsByGender'
declare @commonName nvarchar(max) = N'Graton Demographics: Worker Signins by Gender'
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
ROLLBACK TRANSACTION
--COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
