# Setup the Azure powershell extension. RM stands for Resource Manager.
# Install it every single time. "Doesn't hurt anything."
Install-Module AzureRM.NetCore

# Import the module into the PowerShell session (yep, this one):
Import-Module AzureRM.Netcore

# Connect to Azure with an interactive dialog for sign-in:
if ([string]::IsNullOrEmpty((Get-AzureRmContext).Account)) {
  Connect-AzureRmAccount
}

# subscription problems? https://stackoverflow.com/a/47675981/2496266
if ((Get-AzureRmContext).Subscription.Name -ne "Pay-As-You-Go") {
  Get-AzureRmSubscription -SubscriptionName "Pay-As-You-Go" | Select-AzureRmSubscription
}

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles
# https://docs.microsoft.com/en-us/powershell/azure/context-persistence?view=azurermps-6.8.1

echo Success
exit 0
