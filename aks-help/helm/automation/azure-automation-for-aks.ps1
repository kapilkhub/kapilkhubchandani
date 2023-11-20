az login

az extension add --name automation

az automation account create -n acrkhubchandani-aks-start-stop -g kapilkhubchandaniorg

#enable system managed identity for auto-aks-start-stop
$AKS_ID=$(az aks show --name acrkhubchandani -g kapilkhubchandaniorg --query id --output tsv)

az role assignment create --role "Contributor" --assignee-object-id "eb646fc3-1c00-4bf1-9af8-a2802c03f33e" --scope $AKS_ID