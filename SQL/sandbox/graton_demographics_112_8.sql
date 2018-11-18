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
ROLLBACK TRANSACTION
--COMMIT TRANSACTION
--GO

SELECT * FROM [dbo].[ReportDefinitions] WHERE [name] = @name
GO
