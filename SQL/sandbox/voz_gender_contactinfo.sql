
;with cte as(
  select workerID, max(dateforsignin) as lastsignin
  from dbo.workersignins
  where dateforsignin >= '2016-01-01'
    and dateforsignin <= '2016-12-31'
  group by workerID
--  order by lastsignin
)

select 
    workerID
  , l.text_en as gender
  , firstname1
  , COALESCE(firstname2,'') AS firstname2
  , lastname1
  , COALESCE(lastname2,'') AS lastname2
  , COALESCE(phone,'') AS phone
  , COALESCE(cellphone,'') AS cellphone
  , lastsignin
from cte
join dbo.persons p on p.id = cte.workerID
join dbo.lookups l on l.id = p.gender
order by text_en
go

;with cte2 as (
  select
      w.id as workerID
    , case when memberReactivateDate is null then dateOfMembership else memberReactivateDate end as dateRegistered
	, dateupdated
    --, *
  from dbo.workers w
)

select 
    cte2.workerID
  , l.text_en as gender
  , cte2.dateRegistered
  , firstname1
  , COALESCE(firstname2,'') AS firstname2
  , lastname1
  , COALESCE(lastname2,'') AS lastname2
  , COALESCE(phone,'') AS phone
  , COALESCE(cellphone,'') AS cellphone
  , cte2.dateupdated
from cte2
join dbo.persons p on p.id = cte2.workerID
join dbo.lookups l on l.id = p.gender
where cte2.dateRegistered >= '2016-01-01'
  and cte2.dateRegistered <= '2016-12-31'
order by text_en, cte2.dateregistered
go

;with cte3 as (
  select
      employerID
	, max(dateTimeofWork) as lastWorkDate
  from dbo.WorkOrders
  where dateTimeofWork >= '2016-01-01'
    and dateTimeofWork <= '2016-12-31'
  group by employerID
)

select
    cte3.employerID
  , e.name
  , e.address1
  , COALESCE(e.address2,'') AS address2
  , e.city
  , e.state
  , e.zipcode
  , e.phone
  , COALESCE(e.cellphone,'') AS cellphone
  , lastWorkDate
from cte3
join dbo.employers e on cte3.employerid = e.id
