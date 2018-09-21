# just an example; TODO flesh this out with args

$resourceGroup = "storage-quickstart-resource-group"
$location = "westus"
$name = "fucking-storage-bro"

$account = (Get-AzureRmContext).Name
if ([string]::IsNullOrEmpty($account)) {
 Write-Host "Wait a second. You're not even *connected* to Azure."
 Write-Host "Try running setup-azure-powershell.ps1 first."
 exit 1
}

Write-Host "Are you sure you want to create this Storage Account in Azure?"
Write-Host "  Name:           $name"
Write-Host "  Location:       $location"
Write-Host "  Resource Group: $resourceGroup"
Write-Host ""
Write-Host "In account $($account)? [y/n]"

function Get-Response {
  $response = $host.UI.RawUI.ReadKey("IncludeKeyDown")
  switch ($response.character) {
    "y" { Do-It; break }
    "n" { exit 0; break }
    default { write-host "`nwtf!? dude you pressed `"$($response.character)`"!"; Get-Response; break }
  }
}

function Do-It {
  exit 0
  New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
    -Name $name `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2
}

Get-Response
