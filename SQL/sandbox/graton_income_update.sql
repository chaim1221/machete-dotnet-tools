select * from dbo.Lookups where category = 'income'


update dbo.lookups set 
    text_en = 'Extremely low, $17,400 or less'
  , text_es = 'Sumamente bajo, menos de $17,400'
where id = 17

update dbo.lookups set
    text_en = 'Very Low, $17,400 to $28,949'
  , text_es = 'Muy bajo, de $17,400 a $28,949'
where id = 18

update dbo.lookups set
    text_en = 'Low, $28,950 to $46,150'
  , text_es = 'Bajo, de $28,950 a $46,150'
where id = 19

update dbo.lookups set
    text_en = 'Moderate, $46,151 to $57,800'
  , text_es = 'Moderado, de $46,151 a $57,800'
where id = 84

update dbo.lookups set
    text_en = 'Unknown'
  , text_es = 'Desconocido'
where id = 85
