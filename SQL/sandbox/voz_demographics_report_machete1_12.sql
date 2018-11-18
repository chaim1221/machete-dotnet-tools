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
