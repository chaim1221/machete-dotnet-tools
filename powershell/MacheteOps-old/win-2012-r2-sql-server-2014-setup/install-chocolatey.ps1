$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”)
if (-not $isAdmin)
{
    throw "admin rights are required"
}


write-host "Testing execution policy..."
if ($(Get-ExecutionPolicy) -ne "RemoteSigned") { throw "Set execution policy..." } else { write-host "OK" -f green }
write-host "Installing chocolatey..."
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
if (-not $?) { write-host "OK" -f green }