sudo docker pull mcr.microsoft.com/mssql/server
sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=passw0rD!' -p 1433:1433 \
  --name sql1 -d mcr.microsoft.com/mssql/server:2017-latest


