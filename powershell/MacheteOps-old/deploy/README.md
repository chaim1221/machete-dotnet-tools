# Machete Deployment Tool

This tool deploys the Release build of Machete to the websites on the cloud VM using the 
following inputs:
 - msBuildLocation, the location of MSBUILD.EXE on 
the local machine (defaults to "C:\Program Files 
(x86)\MSBuild\14.0\Bin\MSBuild.exe")
 - nugetLocation, the location of NuGet.exe on the 
local machine (defaults to "C:\Program Files 
(x86)\NuGet\Visual Studio 2015\NuGet.exe")
 - macheteRepo, the location of the Machete repository on the local machine (defaults to `c:\git\machete`)
 - centerList, the location of the .txt file containing the centers to which you'd like to deploy. 
 - tagName, the name of the tag to be deployed

Please do not use activeCenters.txt until we develop a better way to test all of the sites 
before going to production. Deployments are currently done in four phases:

1. Jimmy deploys to test.machetessl.org, Casa Latina does UAT.
2. Jimmy deploys to casa.machetessl.org
3. Chaim deploys to test-graton.machetessl.org and test-voz.machetessl.org, those sites do UAT.
4. Chaim deploys to graton.machetessl.org and voz.machetessl.org.
5. Chaim deploys to the rest of the active centers.

This pattern is meant to reduce the risk of bugs hitting all the centers at once, which is 
a resource-intensive problem that has been known to cause downtime.

TODO: a list of files and their purpose
