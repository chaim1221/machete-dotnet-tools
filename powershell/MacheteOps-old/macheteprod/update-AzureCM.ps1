<#
 .NOTES
   visit https://docs.microsoft.com/en-in/azure/backup/backup-azure-vms-first-look-arm
   this script sort of assumes you've run the agent MSI yourself,
   AND that you've dropped the file you got from running
   Get-AzurePublishSettingsFile in this directory."
 #>
param (
  [Parameter(Mandatory=$true)]
  [string]$vmName,
  [Parameter(Mandatory=$true)]
  [string]$publishSettingsFile
)

push-location
Import-AzurePublishSettingsFile $publishSettingsFile
Select-AzureSubscription -SubscriptionId "e89e34ab-4cb2-40e7-b374-5ec0a4b9c57d" -Default
$vm = get-azurevm -ServiceName $key -Name $key
$vm.VM.ProvisionGuestAgent = $true
Update-AzureVM -Name $vm.Name -VM $vm.VM -ServiceName $vm.ServiceName
Get-AzureVM -ServiceName $key -Name $key
