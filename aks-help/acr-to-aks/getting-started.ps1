Install-Module -Name powershell-yaml
Import-Module powershell-yaml

# set variables to be used 
$Region="eastus"
$RG="AKSRG"
$Sub="<get-subscription-id>"
$AKSCluster="AKSCluster"

#Get your tenant name
Start-Process "https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview"
$TenantName="<getyourtennantname>"

az login

az account set -s $Sub

#create an RG and AKS cluster
az group create -l $Region -n $RG
az aks create --resource-group $RG --name $AKSCluster #(run this in cloud shell because of bug)

az aks get-credentials -g kapilkhubchandaniorg -n acrkhubchandani