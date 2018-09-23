# just an example; TODO flesh this out with args

$container = "handycontainer"
$location = "westus"
$name = "fuckingazurestoragebro"
$resourceGroup = "macheteTest"

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
    "y" { Create-StorageAccount; break }
    "n" { exit 0; break }
    default { write-host "`nwtf!? dude you pressed `"$($response.character)`"!"; Get-Response; break }
  }
}

function Create-StorageAccount {
  try { # I stop the world! World
    $ErrorActionPreference = "Stop"
    Write-Host ""
    New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
      -Name $name `
      -Location $location `
      -SkuName Standard_LRS `
      -Kind StorageV2
  } catch {
    write-host "dude! that storage account already exists!"
  } finally {
    $ErrorActionPreference = "Continue" # Carry on...
    Create-Container
  }
}

function Create-Container {
  try { # not to remember any more Nikki Minaj lyrics
    $ErrorActionPreference = "Stop"
    $accountContext = (Get-AzureRmStorageAccount -Name $name -ResourceGroupName $resourceGroup).Context
    New-AzureStorageContainer -Name $container -Context $accountContext -Permission blob
  } catch {
    Write-Host "also, the container appears to already exist."
  } finally {
    $ErrorActionPreference = "Continue" # Kitty on pink, pretty on fleek
  }
}

Get-Response
