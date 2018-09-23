# DO ALL THE THINGS!
$containerName = "handycontainer"
$resourceGroupName = "macheteTest"
$storageAccountName = "fuckingazurestoragebro"
$file = "nonsense.zip"
$path = ".\payloads\"

try {

$context = (Get-AzureRmStorageAccount -Name $storageAccountName `
  -ResourceGroupName $resourceGroupName).Context

Set-AzureStorageBlobContent -File (Join-Path $path $file) `
  -Container $containerName `
  -Blob $file `
  -Context $context

Write-Host "Success"

} catch {

Write-Host -ForegroundColor Yellow "Well, that didn't work very well."
Write-Host -ForegroundColor Yellow "Exception message:"
Write-Host -ForegroundColor Red $_.Exception.Message

}
