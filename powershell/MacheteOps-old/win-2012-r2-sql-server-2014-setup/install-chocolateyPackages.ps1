write-host "Configuring chocolatey packages..."
if ($?) { choco install -y chromium }
if ($?) { choco install -y git }
if ($?) { choco install -y nano }
if ($?) { choco install -y notepadplusplus }
if ($?) { choco install -y dotnet3.5 } # req for sql svr
# TODO
# if ($?) { choco install mssqlserver2014express } 
# problem is we do not know if it contains the 
# reporting tools, and I am in a hurry.

$gitBinEnv = ";C:\Program Files\git\usr\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path + $gitBinEnv, [System.EnvironmentVariableTarget]::Machine )
$env:Path += $gitBinEnv

write-host "...done." -f green
write-host "Please don't forget to make a public/private SSH key pair for GitHub."
write-host "Please don't forget to install SQL Server 2014 Express."
