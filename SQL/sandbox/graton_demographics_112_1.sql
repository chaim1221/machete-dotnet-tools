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
