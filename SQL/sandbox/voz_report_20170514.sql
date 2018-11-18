/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT TOP (1000) [ID]
--      ,[workerAssignedID]
--      ,[workOrderID]
--      ,[workerSigninID]
--      ,[active]
--      ,[pseudoID]
--      ,[description]
--      ,[englishLevelID]
--      ,[skillID]
--      ,[surcharge]
--      ,[hourlyWage]
--      ,[hours]
--      ,[hourRange]
--      ,[days]
--      ,[qualityOfWork]
--      ,[followDirections]
--      ,[attitude]
--      ,[reliability]
--      ,[transportProgram]
--      ,[comments]
--      ,[datecreated]
--      ,[dateupdated]
--      ,[Createdby]
--      ,[Updatedby]
--      ,[workerRating]
--      ,[workerRatingComments]
--      ,[weightLifted]
--      ,[skillEN]
--      ,[skillES]
--      ,[fullWAID]
--      ,[minEarnings]
--      ,[maxEarnings]
--  FROM [dbo].[WorkAssignments]

declare @startDate as datetime = '2016-01-01 00:00:00.000'
declare @endDate as datetime = '2016-12-31 23:59:59.999'

--drop table #tt
create table #tt
(
  [SkillID] int,
  [Skill] nvarchar(50),
  [Month] int,
  [Count] int
);

insert into #tt
  select 
    skillID as 'SkillID'
  , text_EN as 'Skill'
  , datepart(month, dateTimeOfWork) as 'Month'
  , count(*) as 'Count'
  from dbo.workAssignments A
  join dbo.workOrders O on A.workOrderID = O.ID
  join dbo.Lookups L on A.skillID = L.ID
  where dateTimeOfWork >= @startDate
    and dateTimeOfWork <= @endDate
  group by text_EN, skillID, datepart(month,dateTimeOfWork)
  order by datepart(month,dateTimeOfWork)

--select * from #tt

--drop table #lookupsTemp
create table #lookupsTemp (
  [SkillID] int,
  [Skill] varchar(50),
  [January] int,
  [February] int,
  [March] int,
  [April] int,
  [May] int,
  [June] int,
  [July] int,
  [August] int,
  [September] int,
  [October] int,
  [November] int,
  [December] int
)

insert into #lookupsTemp
  select --*
    [SkillID]
  , [Skill]
  , case when [1] is NULL then 0 else [1] end as 'January'
  , case when [2] is NULL then 0 else [2] end as 'February'
  , case when [3] is NULL then 0 else [3] end as 'March'
  , case when [4] is NULL then 0 else [4] end as 'April'
  , case when [5] is NULL then 0 else [5] end as 'May'
  , case when [6] is NULL then 0 else [6] end as 'June'
  , case when [7] is NULL then 0 else [7] end as 'July'
  , case when [8] is NULL then 0 else [8] end as 'August'
  , case when [9] is NULL then 0 else [9] end as 'September'
  , case when [10] is NULL then 0 else [10] end as 'October'
  , case when [11] is NULL then 0 else [11] end as 'November'
  , case when [12] is NULL then 0 else [12] end as 'December'
  from (
    select [SkillID],[Skill],[Month],[Count]
    from #tt
  ) src
  pivot
  (
    sum([Count])
    for [Month] in ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
  ) piv;

--select * from #lookupsTemp

--select count(*) from dbo.workers where skill1 = 65 
--select count(*) from dbo.workers where skill2 = 65
--select count(*) from dbo.workers where skill3 = 65
--select count(*) from dbo.workers where skill1 = 65 or skill2 = 65 or skill3 = 65
;with cte as (
  select
    L.ID as 'ID'
  , L.text_EN 'English'
  , count(*) as 'SkillCount'
  from dbo.workers W
  join dbo.lookups L on L.ID = W.skill1 or L.ID = W.skill2 or L.ID = W.skill3
  group by L.ID, L.text_EN
)

select 
  L.Skill as 'Job Title'
, A.SkillID as 'ID'
, January
, February
, March
, April
, May
, June
, July
, August
, September
, October
, November
, December
, count(*) as 'Total This Year'
, convert(decimal(16,2),avg(hourlyWage)) as 'Average Wage'
, case when SkillCount is null then 0 else SkillCount end as 'Number of Workers With Skill'
from dbo.WorkAssignments A
join [dbo].[WorkOrders] W on A.workOrderID = W.ID 
join #lookupsTemp L on A.skillID = L.SkillID
left join cte on A.skillID = cte.ID
where dateTimeOfWork >= @startDate
  and dateTimeOfWork <= @endDate
group by  L.Skill, A.SkillID, January, February, March, April, May, June, July, August, September, October, November, December, SkillCount
order by 'Total This Year' desc

drop table #tt
drop table #lookupsTemp
