# just an example; TODO flesh this out with args

$resourceGroup = "storage-quickstart-resource-group"
$location = "westus"

New-AzureRmStorageAccount -ResourceGroupName $resourceGroup `
  -Name "storagequickstart" `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind StorageV2
