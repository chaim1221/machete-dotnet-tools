SELECT
  WorkerSignins.dateforsignin
  ,Workers.dateOfBirth
  ,Lookups_Gender.gender_EN
  ,Workers.ID
  ,Lookups_MemberStatus.memberStatus_EN
  ,Lookups_Race.race_EN

  ,Lookups_Income.income_EN
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
  WorkerSignins.dateforsignin &gt;= @beginDate and
  WorkerSignins.dateforsignin &lt;= @endDate
  
;with ages as 
(
SELECT
  workers.ID
  ,ROUND(DATEDIFF(day, Cast(Workers.dateOfBirth as Date), Cast(CURRENT_TIMESTAMP as Date)) / 365, 0) as age
  ,Lookups_Gender.gender_EN
  ,Lookups_MemberStatus.memberStatus_EN
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
  WorkerSignins.dateforsignin &gt;= @beginDate and
  WorkerSignins.dateforsignin &lt;= @endDate
),
 combined as 
(
select 
  ID
  ,gender_EN
  ,memberStatus_EN
  ,case
	when age between 12 and 17 then '12 to 17'
	when age between 18 and 23 then '18 to 23'
    when age between 24 and 44 then '24 to 44'
    when age between 45 and 54 then '45 to 54'
	when age between 55 and 69 then '55 to 69'
    when age &gt;= 70 then '70+'
	else 'unknown'
  end as age_group
from ages

)
select *
from combined

select count(distinct(w.id)) as 'Registered count' from persons p
join workers w on (w.id = p.id)
join workersignins wsi on (w.id = wsi.workerID)
where wsi.dateforsignin &gt;=  @beginDate and
wsi.dateforsignin &lt;= @endDate

select count(distinct(w.id)) as 'assigned count' from persons p
join workers w on (w.id = p.id)
join workassignments wa on (w.id = wa.workerassignedid)
join workorders wo on (wa.workorderid = wo.id)
where wo.datetimeofwork &gt;= @beginDate
and wo.datetimeofwork &lt;= @endDate;

;with earnings as
(
SELECT
 lg.gender_EN, ((wa.hourlywage * wa.hours * wa.days)) as earned
FROM  workorders wo
inner join workassignments wa on wo.id = wa.workorderid
inner join workers w on wa.workerassignedID = w.id
inner join persons p on w.id = p.id
inner join db_datareader.Lookups_Gender lg on lg.id = p.gender
where wo.dateTimeofWork &gt;= @beginDate and
 wo.dateTimeofWork &lt;= @endDate
)
select gender_EN, sum(earned) earned, count(gender_EN) total_count from earnings group by gender_EN

select lg.gender_EN, count(distinct(w.id)) unique_signins, count(w.id) total_signins
from persons w 
inner join workersignins wsi on wsi.workerid = w.id
inner join db_datareader.Lookups_Gender lg on lg.id = w.gender
where   wsi.dateforsignin &gt;= @beginDate and 
wsi.dateforsignin &lt;= @endDate
group by gender_EN

select count(*) 'all work assignments count'
from workassignments wa
inner join workorders wo on wa.workorderid = wo.id
where wo.dateTimeofWork &gt;= @beginDate and
 wo.dateTimeofWork &lt;= @endDate
 and wa.workerassignedid is not null


select count(*) as 'all workorders count'
 from workorders wo
 where wo.dateTimeofWork &gt;= @beginDate and
 wo.dateTimeofWork &lt;= @endDate
 
 
 select distinct(w.dwccardnum), raceid, incomeid from workers w
inner join workersignins wsi on w.id = wsi.workerid
where wsi.dateforsignin &gt;=  @beginDate and
wsi.dateforsignin &lt;= @endDate and (
raceid is null
or incomeid is null 
)
