# Setup the Azure powershell extension
# RM stands for Resource Manager
Install-Module AzureRM.NetCore

# Import the module into the PowerShell session
Import-Module AzureRM.Netcore

# Connect to Azure with an interactive dialog for sign-in
Connect-AzureRmAccount

# subscription problems?
# https://stackoverflow.com/a/47675981/2496266

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
# https://docs.microsoft.com/en-us/powershell/azure/context-persistence?view=azurermps-6.8.1

