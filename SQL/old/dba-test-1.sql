--DO NOT run on PROD
--This file tests the capacity of the foreign key relationship

PRINT 'INSERTING MACHETECONMAPPING TEST RECORD...'
INSERT INTO [DBA].[dbo].[MacheteConMapping] (
    [UserLogin]
  , [ConnectionString]
) VALUES (
    'MACHETE-STAGING/ssrs_user'
  , 'Server=tcp:machete0.database.windows.net,1433;Initial Catalog=machete-test;Persist Security Info=False;User ID={your_username};Password={your_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
)

DECLARE @ROWID INT = (SELECT MacheteConMappingID FROM [DBA].[dbo].MacheteConMapping WHERE [UserLogin] = 'MACHETE-STAGING/ssrs_user')

PRINT 'INSERTING CENTER TEST RECORD...'
INSERT INTO [DBA].[dbo].[Center] (
    [ID]
  , [Name]
  , [Description]
  , [Address1]
  , [Address2]
  , [City]
  , [State]
  , [zipcode]
  , [phone]
  , [Center_contact_firstname1]
  , [Center_contact_lastname1]
) VALUES (
    @ROWID
  , 'MY EX'
  , 'A MAJOR HEADACHE'
  , 'HA HA HA'
  , 'YEAH RIGHT'
  , 'SEATTLE'
  , 'WA'
  , '98105'
  , '867-5309'
  , 'JENNY'
  , 'NOPE'
)

PRINT 'DELETING MACHETECONMAPPING RECORD'
DELETE FROM DBA.dbo.MacheteConMapping WHERE MacheteConMappingID = @ROWID

IF (SELECT 1 FROM DBA.dbo.Center WHERE ID = 1) = 1
  RAISERROR (N'GO BACK AND FIX YOUR SQL CODE', 0, 1)
ELSE
  PRINT 'SUCCESS!'
  