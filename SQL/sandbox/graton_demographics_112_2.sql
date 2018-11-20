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

declare @name nvarchar(max) = N'GratonDemographicsEarningsByGender'
declare @commonName nvarchar(max) = N'Graton Demographics: Worker Earnings by Gender'
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
select gender_EN as [Gender], sum(earned) as [Earned], count(gender_EN) as [Assignment Count] 
from earnings 
group by gender_EN

union all 

select ''Total'' as [Gender], sum(earned) as [Earned], count(*) as [Assignment Count]
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
