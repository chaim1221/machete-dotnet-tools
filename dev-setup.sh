sudo docker pull mcr.microsoft.com/mssql/server
sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=passw0rD!' -p 1433:1433 \
  --name sql1 -d mcr.microsoft.com/mssql/server:2017-latest
sudo docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd -S localhost \
  -U SA -P 'passw0rD!' -Q 'CREATE USER dev WITH PASSWORD 'passw0rD!'
sudo docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd -S localhost \
  -U SA -P 'passw0rD!' \
  -Q 'EXEC sys.sp_addsrvrolemember @loginame = N'dev', @rolename = N'sysadmin';'
sudo docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd -S localhost \
  -U SA -P 'passw0rD!' \
  -Q 'ALTER SERVER ROLE [sysadmin] ADD MEMBER [dev]'
# docker exec -it sql1 bash
