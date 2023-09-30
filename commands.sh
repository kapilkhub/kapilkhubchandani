az group create --location westeurope --resource-group kapilkhubchandaniorg
RG_ID=$(az group show --name $RG_NAME --query id --output tsv)

#create service principal
az ad sp create-for-rbac --name $SP_NAME --scopes $RG_ID --role Contributor --sdk-auth


 SP_ID=$(az ad sp list --display-name $SP_NAME --query "[].appId" --output tsv)


 #create azure container registry
 az acr create --resource-group $RG_NAME --name $ACR_NAME --sku Basic  
 
 ACR_ID=$(az acr show --name $ACR_NAME --query id --output tsv)

 #assign permission to Service provider for ACR to push image
 az role assignment create --assignee $SP_ID --scope $ACR_ID --role AcrPush


 #assign permission of pulling image to service principal
 az role assignment create --assignee $SP_ID --scope $ACR_ID --role AcrPull

 #create azure kuberenets service
 az aks create --resource-group $RG_NAME --name $AKS_NAME --node-count 1 --generate-ssh-keys --attach-acr $ACR_NAME --service-principal $SP_ID --client-secret $SP_PASSWORD