USE [master]
GO

-- Chaim Eliyah and machete_sqlserver should already exist, so...
CREATE LOGIN [MACHETE-STAGING\machete] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO


-- then, add the admins as such
ALTER SERVER ROLE [sysadmin] ADD MEMBER [MACHETE-STAGING\Chaim Eliyah]
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [MACHETE-STAGING\machete_sqlserver]
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [MACHETE-STAGING\machete]
GO


-- reboot the computer 