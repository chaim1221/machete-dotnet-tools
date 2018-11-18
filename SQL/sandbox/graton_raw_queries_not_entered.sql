
select count(distinct(w.id)) as 'Registered count' from persons p
join workers w on (w.id = p.id)
join workersignins wsi on (w.id = wsi.workerID)
where wsi.dateforsignin >=  @beginDate and
wsi.dateforsignin <= @endDate

select count(distinct(w.id)) as 'assigned count' from persons p
join workers w on (w.id = p.id)
join workassignments wa on (w.id = wa.workerassignedid)
join workorders wo on (wa.workorderid = wo.id)
where wo.datetimeofwork >= @beginDate
and wo.datetimeofwork <= @endDate;

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
select gender_EN, sum(earned) earned, count(gender_EN) total_count from earnings group by gender_EN

select lg.gender_EN, count(distinct(w.id)) unique_signins, count(w.id) total_signins
from persons w 
inner join workersignins wsi on wsi.workerid = w.id
inner join db_datareader.Lookups_Gender lg on lg.id = w.gender
where   wsi.dateforsignin >= @beginDate and 
wsi.dateforsignin <= @endDate
group by gender_EN

select count(*) 'all work assignments count'
from workassignments wa
inner join workorders wo on wa.workorderid = wo.id
where wo.dateTimeofWork >= @beginDate and
 wo.dateTimeofWork <= @endDate
 and wa.workerassignedid is not null


select count(*) as 'all workorders count'
 from workorders wo
 where wo.dateTimeofWork >= @beginDate and
 wo.dateTimeofWork <= @endDate
 
 
 
