select active, * from dbo.Lookups where category = 'income'

--set active on the incomes Christy wants to use, inactive on the ones she doesn't
--correct the historical data on the changed lookups to reflect reality
update dbo.lookups set 
  text_en = 'Extremely low, $17,400 or less',
  text_es = 'Sumamente bajo, menos de $17,400',
  dateupdated = '2017-01-01 18:49:00.000',
  Updatedby = 'Chaim Eliyah',
  active = 1
where id = 17

update dbo.lookups set
  text_en = 'Very Low, $17,400 to $28,950',
  text_es = 'Muy bajo, de $17,400 a $28,950',
  dateupdated = '2017-01-01 18:49:00.000',
  Updatedby = 'Chaim Eliyah',
  active = 1
where id = 18

update dbo.lookups set
  text_en = 'Low, $28,950 to $46,150',
  text_es = 'Bajo, de $28,950 a $46,150',
  dateupdated = '2017-01-01 18:49:00.000',
  Updatedby = 'Chaim Eliyah',
  active = 0
where id = 19

update dbo.lookups set
  text_en = 'Moderate, $46,151 to $57,800',
  text_es = 'Moderado, de $46,151 a $57,800',
  dateupdated = '2017-01-01 18:49:00.000',
  Updatedby = 'Chaim Eliyah',
  active = 0
where id = 84

--this one didn't change
--update dbo.lookups set
--  text_en = 'Unknown',
--  text_es = 'Desconocido',
--  dateupdated = '2013-09-02 14:11:24.820',
--  Updatedby = 'Init T. Script',
--  active = 1
--where id = 85

--put the originals back (as new entries)
INSERT INTO dbo.Lookups
--ID, 
(category, text_EN, text_ES, selected, subcategory, level, wage, minHour, fixedJob, sortorder, typeOfWorkID, speciality, ltrCode, datecreated, dateupdated, Createdby, Updatedby, emailTemplate, [key], skillDescriptionEn, skillDescriptionEs, minimumCost, active)
VALUES
('income', 'Extremely low, $15,000 or less', 'Sumamente bajo, menos de $15,000', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2013-09-02 14:11:24.820', '2013-09-02 14:11:24.820', 'Init T. Script', 'Init T. Script', NULL, NULL, NULL, NULL, NULL, 0),
('income', 'Very Low, $15,000 to $25,000', 'Muy bajo, de $15,000 a $25,000', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2013-09-02 14:11:24.823', '2013-09-02 14:11:24.823', 'Init T. Script', 'Init T. Script', NULL, NULL, NULL, NULL, NULL, 0),
('income', 'Low, $25,000 to $37,000', 'Bajo, de $25,000 a $37,000', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2013-09-02 14:11:24.823', '2013-09-02 14:11:24.823', 'Init T. Script', 'Init T. Script', NULL, NULL, NULL, NULL, NULL, 0),
('income', 'Above $37,000', 'Por encima de $37,000', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '2013-09-02 14:11:24.823', '2013-09-02 14:11:24.823', 'Init T. Script', 'Init T. Script', NULL, NULL, NULL, NULL, NULL, 0)

--put the new ones Christy is asking for
INSERT INTO dbo.Lookups
----ID, 
(category, text_EN, text_ES, selected, subcategory, level, wage, minHour, fixedJob, sortorder, typeOfWorkID, speciality, ltrCode, datecreated, dateupdated, Createdby, Updatedby, emailTemplate, [key], skillDescriptionEn, skillDescriptionEs, minimumCost, active)
VALUES
('income', 'Low, $28,950 to $34,740', 'Bajo, de $25,000 a $34,740', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, GETDATE(), GETDATE(), 'Chaim Eliyah', 'Chaim Eliyah', NULL, NULL, NULL, NULL, NULL, 1),
('income', 'Moderate, $34,740-$46,150', 'Moderado, de $34,740 a $46,150', 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, GETDATE(), GETDATE(), 'Chaim Eliyah', 'Chaim Eliyah', NULL, NULL, NULL, NULL, NULL, 1)

--get incomes
select id, active, text_en, text_es, selected, dateupdated, updatedby from dbo.Lookups where category = 'income'

--update any workers that should still be using the original values; i.e., those which haven't been updated since Jan. 1
;with cte as (
  select id from dbo.Workers where dateupdated < convert(datetime, '2017-01-01', 111)
)
--should include 17, 18, 19, and 84
select w.incomeid, count(w.id) as numberOfWorkers
from dbo.workers w
inner join cte on cte.id = w.id
--              and cte.income
group by w.incomeid

;with cte as (
  select id from dbo.Workers where dateupdated < convert(datetime, '2017-01-01', 111) and incomeid = 17
)
update w
set incomeid = 367 
from dbo.workers w inner join cte on cte.id = w.id
where incomeid = 17

;with cte as (
  select id from dbo.Workers where dateupdated < convert(datetime, '2017-01-01', 111) and incomeid = 18
)
update w
set incomeid = 368 
from dbo.workers as w inner join cte on cte.id = w.id
where incomeid = 18

;with cte as (
  select id from dbo.Workers where dateupdated < convert(datetime, '2017-01-01', 111) and incomeid = 19
)
update w
set incomeid = 369 
from dbo.workers as w inner join cte on cte.id = w.id
where incomeid = 19

;with cte as (
  select id from dbo.Workers where dateupdated < convert(datetime, '2017-01-01', 111) and incomeid = 84
)
update w
set incomeid = 370 
from dbo.workers as w inner join cte on cte.id = w.id
where incomeid = 84

--should NOT include 17, 18, 19, and 84
;with cte as (
  select id from dbo.Workers where dateupdated < convert(datetime, '2017-01-01', 111)
)
select distinct w.incomeid, count(*) from dbo.workers w
inner join cte on cte.id = w.id
--              and cte.income
group by w.incomeid

--now any NEW or UPDATED workers will have the NEW values that Christy wants (i.e., post-5/14)
--any workers updated between 1/1 and 5/14 will be set to the values she asked for in October
--any workers not updated by 1/1 will have the original values.
