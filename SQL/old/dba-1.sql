use [master]
GO

CREATE DATABASE [DBA]
  CONTAINMENT = NONE
  ON PRIMARY
(
    NAME = N'DBA'
  , FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\DBA.mdf'
  -- D: on PROD
  --, FILENAME = N'D:\SQLData\DBA.mdf'
  , SIZE = 10MB
  , MAXSIZE = UNLIMITED
  , FILEGROWTH = 1024KB
)
LOG 
  ON
(
    NAME = N'DBA_log'
  , FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\DBA.ldf'
  -- D: on PROD
  --, FILENAME = N'D:\SQLData\DBA.ldf'
  , SIZE = 10240KB
  , MAXSIZE = 2048GB
  , FILEGROWTH = 10%
)
GO

USE [DBA]
GO

--DROP TABLE [DBA].[dbo].[MacheteConMapping]
CREATE TABLE [DBA].[dbo].[MacheteConMapping] (
  MacheteConMappingID INT NOT NULL IDENTITY (1, 1) PRIMARY KEY CLUSTERED,
  UserLogin NVARCHAR(512),
  ConnectionString NVARCHAR(2048)
)

--DROP TABLE [DBA].[dbo].[Center]
CREATE TABLE [DBA].[dbo].[Center] (
  ID INT NOT NULL PRIMARY KEY CLUSTERED,
  Name NVARCHAR(128),
  Description NVARCHAR(2048),
  Address1 NVARCHAR(256),
  Address2 NVARCHAR(16),
  City NVARCHAR(32),
  State NVARCHAR(16),
  zipcode NVARCHAR(16),
  phone NVARCHAR(32),
  Center_contact_firstname1 NVARCHAR(64),
  Center_contact_lastname1 NVARCHAR(64)
)

ALTER TABLE [dbo].[Center] WITH CHECK ADD CONSTRAINT [FK_Center_MacheteConMapping]
FOREIGN KEY([ID]) REFERENCES [dbo].[MacheteConMapping] ([MacheteConMappingID])
ON DELETE CASCADE
GO

USE [DBA]
GO
CREATE USER [MACHETE-STAGING\SSRS_USERS] FOR LOGIN [MACHETE-STAGING\SSRS_USERS]
GO
