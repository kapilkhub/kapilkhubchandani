Connect-AZAccount

Set-AzContext -SubscriptionId 3e4e586a-a0ff-49db-bb07-e8cb8fa5601a

Get-Module

New-AZResourceGroup -Name aks-ps-rg -Location eastus

New-AzAksCluster -ResourceGroupName aks-ps-rg -Name aks-ps -NodeCount 1 -GenerateSSHKey

kubectl completion powershell | Out-String | Invoke-Expression

kubectl completion powershell >> $PROFILE

"set-alias -Name k -Value kubectl" >> $PROFILE

"function SetNamespace([string]`$namespace=`"default`"){ kubectl config set-context --current --namespace `$namespace }" >> $PROFILE

"set-alias -Name kn -Value SetNamespace" >> $PROFILE