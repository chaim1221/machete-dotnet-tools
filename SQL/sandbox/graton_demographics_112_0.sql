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
declare @commonName nvarchar(max) = N'Worker Signins By Skill'
declare @title nvarchar(max) = NULL
declare @description nvarchar(max) = N'Enumerates the skills values from the lookup table. For each, does a count by month of dispatches for that skill. Totals and adds select of how many workers have that skill. Created 5/14/2017'

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
