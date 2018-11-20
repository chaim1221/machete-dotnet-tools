
; with cte as ( 
    select
        wa.Id as waId
	  , wa.workerAssignedId as waWorkerId
      , wa.workersigninid as waWsiId
      , wa.hourlyWage as waWage
      , wa.hours as waHours
      , convert(date, wo.datetimeofwork) as woDate
	from dbo.WorkOrders wo 
	inner join dbo.WorkAssignments wa
      on wa.WorkOrderId = wo.Id
)

select
    wsi.dwccardnum as wsiCardNumber
  , convert(date,wsi.dateforsignin) as wsiDate
  , cast(assigned.waWage as money) as waWage
  , assigned.waHours
  , personsLookups.text_EN as gender
  , workersLookups.text_EN as ethnicity
  , convert(date,w.dateofbirth) as dob
  , case w.englishLevelId
      when 0 then 'None'
      when 1 then 'Basic'
      when 2 then 'Conversational'
      when 3 then 'Fluent'
    end as englishLevel
  , convert(date,w.dateInUsa) as dateImmigrated
  , convert(date,w.dateofmembership) as dateJoined
  from dbo.WorkerSignins wsi
  left join cte as assigned 
    on assigned.waWsiId = wsi.Id
  left join persons p on wsi.workerId = p.Id
  left join workers w on wsi.workerId = w.Id
  left join lookups personsLookups on p.gender = personsLookups.Id
  left join lookups workersLookups on w.raceid = workersLookups.Id
order by wsiCardNumber
