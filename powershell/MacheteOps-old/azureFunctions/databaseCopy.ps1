
# initial checkin. for a full example see:
# https://docs.microsoft.com/en-us/azure/sql-database/scripts/sql-database-copy-database-to-new-server-powershell

New-AzureRmSqlDatabaseCopy -ResourceGroupName "Default-SQL-WestUS" `
    -ServerName "$serverName" `
    -DatabaseName "adventureworks" `
    -CopyResourceGroupName "Default-SQL-WestUS" `
    -CopyServerName "$serverName" `
    -CopyDatabaseName "adventureworks-test"

