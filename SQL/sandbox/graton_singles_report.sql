;with cte as (
  select 
      w.Id
    , case when l_married.text_EN = 'Married' then 0 else 1 end as single
    , case when w.livewithchildren = 1 then 1 else 0 end as livesWithChildren
    , case when w.dateOfBirth > dateadd(yyyy, -25, getdate()) then 1 else 0 end as under25
  from dbo.workers w
  join dbo.lookups l_married on w.maritalstatus = l_married.id
)

select
    sum(single) as 'Number not Married',
	sum(livesWithChildren) as 'Number Who Live With Children',
	sum(case when under25 = 1 and livesWithChildren = 0 and single = 1 then 1 else 0 end) as 'Unaccompanied Youth Under 25'
from cte
