#!/bin/pwsh

<#
  .SYNOPSIS
    deploys Machete websites from a zipfile obtained from blob sotrage
  .DESCRIPTION
    deployment wrapper for Machete websites
  .EXAMPLE
    ./download-and-deploy.ps1 -containerName coolcontainer `
      -resourceGroupName macheteresourcegroup `
      -storageAccountName superuniquestorage `
      -centerListFile active-centers.txt
  .INPUTS
    [string]$containerName
  , [string]$resourceGroupName
  , [string]$storageAccountName
  , [string]$centerListFile
  , [string]$versionTag
  .OUTPUTS
    An ASP.NET project that has been built, tested, and uploaded to blob storage as a .zip
  .NOTES
    add notes here
  .LINK
    https://github.com/chaim1221/machete-dotnet-tools
  .ROLE
    CI/CD
  .FUNCTIONALITY
    seriously? how many of these damn fields are there? just run the damn thing.
#>

#_
param (
  [string]$containerName = 'handycontainer',
  [string]$resourceGroupName = 'macheteTest',
  [string]$storageAccountName = 'fuckingazurestoragebro',
  [string]$centerListFile = './test-centers.txt',
  [string]$versionTag = '' # not _currently_ required....
)

# declarations
[string[]]$activeCenters = @()
[string]$webserverPath = ""

# assignments
cat $centerListFile | % { if ($_) { $activeCenters += $_ } }
if ( -not $IsWindows ) { # then this is most likely a test
  $webServerPath = "../inetpub/wwwroot"
} else {
  # TODO: Check if we need backslashes;
  # if not, make them forward slashes.
  $webServerPath = "C:\inetpub\wwwroot"
}

# logic
function Main {
  mkdir temp

  $context = (Get-AzureRmStorageAccount -Name $storageAccountName `
    -ResourceGroupName $resourceGroupName).Context

                            # TODO: "naming-convention-$versionTag.zip" `
  Get-AzureStorageBlobContent -Blob "payload.zip" `
    -Container $containerName `
    -Destination (Join-Path $pwd.Path "temp") `
    -Context $context

  Expand-Archive -Path "./temp/payload.zip" -DestinationPath "./temp/payload/"
  mv ./temp/payload/connections.config ./temp
  mv ./temp/payload/identityprovider.config ./temp

  $activeCenters | % {
    # TODO: check how this looks on the webserver
    $websitename = $_
    write-host "Now deploying $websitename...`n"
    cp -Force ./temp/payload/* (Join-Path $webserverPath $websitename)
  }

  rm payload.zip
  rm temp/payload/*
  rm temp/*
  rmdir temp/payload
  rmdir temp
}

Main

Write-Host "End"
