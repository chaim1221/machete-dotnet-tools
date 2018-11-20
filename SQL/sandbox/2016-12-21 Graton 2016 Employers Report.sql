--update dbo.employers
--   set zipcode = '94928' where zipcode = ' 94928'

select 
    ee.name as 'Name'
  , ee.address1 as 'Address Line 1'
  , case when ee.address2 is null then '' else ee.address2 end as 'Address Line 2'
  , ee.city + ', ' + ee.state + ' ' + ee.zipcode as 'Address Line 3'
  --, state
  --, zipcode
  --, active
  , case when ee.receiveUpdates = '0' then 'No' else 'Yes' end as 'Has Opted to Receive Mail'
  , ee.phone as 'Home Phone'
  , case when ee.cellphone is null then '' else ee.cellphone end as 'Cell'
  , max(wo.dateTimeofWork) as 'Date Last Hired'
from dbo.Employers ee
join dbo.WorkOrders wo on wo.EmployerID = ee.ID
where wo.dateTimeofWork >= '2016-01-01'
group by
    ee.name
  , ee.address1
  , ee.address2
  , ee.city
  , ee.state
  , ee.zipcode
  --, active
  , ee.receiveUpdates
  , ee.phone
  , ee.cellphone
order by ee.zipcode asc