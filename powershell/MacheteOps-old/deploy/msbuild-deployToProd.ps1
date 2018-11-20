#!/bin/bash -- just kidding
<#
  .SYNOPSIS deploys Machete website
  .DESCRIPTION deployment wrapper for Machete websites incorporating MSBuild and the test.machetessl.org.pubxml file (you do have that, right?)
  .EXAMPLE .\msbuild-deployToProd.ps1 -msBuildLocation "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" -macheteRepo "c:\git\machete"
  .INPUTS [string]$msBuildLocation, [string]$macheteRepo, [string]$centerList
  .OUTPUTS $null
  .NOTES the example given contains the defaults. the script will walk you through how to use it if you mess it up.
  .LINK https://github.com/chaim1221/MacheteOps
  .ROLE CI/CD
  .FUNCTIONALITY seriously? how many of these damn fields are there? just run the damn thing.
#>
param (
  [string]$msBuildLocation = 'msbuild',
  [string]$nugetLocation = 'nuget',
  [string]$macheteRepo = 'c:\git\machete',
  [string]$centerList = '.\testCenters.txt',
  [string]$tagName = $(throw('tagName is required!'))
)

function pollDirectories([string]$rootDir, [int]$depth) {
  --$depth
  push-location
  set-location $rootDir
  [string[]]$possibleLocations = @()
  $(ls -Directory).FullName | % {
    if ($_ -match 'machete') {
      $possibleLocations += $_
    }
    if ($depth -gt 0) { 
      pollDirectories -rootDir $_ -depth $depth
    }
  }
  pop-location
  return $possibleLocations
}

[System.Security.SecureString]$password = read-host -prompt "Enter password" -AsSecureString

[string[]]$activeCenters = @()
cat $centerList | % { if ($_) { $activeCenters += $_ } }

where.exe $msBuildLocation
if ($?) {
  write-host "MSBuild.exe found." -f Green 
} else {
  $bestGuess = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
  if ([System.IO.File]::Exists($bestGuess)) {
    $msBuildLocation = $bestGuess
  } else { throw 'could not find msbuild' }
}

where.exe $nugetLocation
if ($?) {
  write-host "NuGet.exe found." -f Green
} else {
  $bestGuess = "C:\Program Files (x86)\NuGet\Visual Studio 2015\nuget.exe"
  if ([System.IO.File]::Exists($bestGuess)) {
    $nugetLocation = $bestGuess
  } else { throw 'could not find nuget.exe' }
}

if (-not [System.IO.Directory]::Exists($macheteRepo)) {
  push-location
  [string[]]$macheteLocations = @()
  [string]$userPath = $env:HOMEDRIVE + $env:HOMEPATH
  $drives = ([System.IO.DriveInfo]::getdrives() | where DriveType -eq 'Fixed').RootDirectory
  
  $userLocations = pollDirectories -rootDir $userPath -depth 3
  $rootLocations = $drives | % { pollDirectories -rootDir $_ -depth 2 }
  
  $userLocations | % { $macheteLocations += $_ }
  $rootLocations | % { $macheteLocations += $_ }
  
  $i = 0 ; $macheteLocations | % { $i++ ; write-host "$i`: $_"}
  $j = Read-Host -Prompt "Enter the number for the location of your Machete repo"
  $macheteRepo = $macheteLocations[$j - 1]
  pop-location
} else {
  write-host "Machete repository found in $macheteRepo" -f Green
}

push-location
set-location $macheteRepo
git checkout $tagName
if ($?) { write-host "Success!" -f Green } else { throw "cannot find tag $tagName" }
# this would be nice, but it deletes the publish profile...
# git clean -fdx
& $nugetLocation restore
if ($?) { write-host "NuGet packages successfully restored." -f Green } else { throw "error at nuget restore" }
pop-location

$pubxmlPath = join-path -path $macheteRepo -childPath "Machete.Web\Properties\PublishProfiles"

[bool]$existsPubXmlPath = test-path($pubxmlPath)
if (-not $existsPubXmlPath) { throw "you need to create the test PublishProfile named 'test.machetessl.org.pubxml'; you probably are receiving this error because you expected the file to be checked in. it is now .gitignored." }

push-location
set-location $pubxmlPath

$activeCenters | % {
  $profileName = "$_.machetessl.org.pubxml"
  $(get-content test.machetessl.org.pubxml).replace("test","$_") | out-file $profileName -Encoding utf8
  cd ..\..\..
  & $msBuildLocation Machete.sln /m /t:Build /p:configuration=Release /p:DeployOnBuild=true /p:PublishProfile=$profileName /p:Password=$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))
  cd Machete.Web\Properties\PublishProfiles
  rm $profileName
}

write-host "You're welcome." -f Green

pop-location 
