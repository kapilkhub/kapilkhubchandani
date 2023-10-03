important links 


Containers on azure 

https://azure.microsoft.com/en-us/products/category/containers/


https://learn.microsoft.com/en-us/training/modules/aks-deploy-container-app/3-exercise-create-aks-cluster?tabs=linux

step 1  create resource group 

az group create --name=$RG_NAME --location=$RG_LOCATION


step 2 create cluster  with one master node

az aks create \                                        
    --resource-group $RG_NAME \
    --name $ACR_NAME \
    --node-count 1 \
    --enable-addons http_application_routing \
    --generate-ssh-keys \
    --node-vm-size Standard_B2s \
    --network-plugin azure \
    --attach-acr $ACR_NAME \
    --service-principal $SP_ID --client-secret $SP_PASSWORD



step 3  add one worker node 

az aks nodepool add \
    --resource-group $RG_NAME \
    --cluster-name $ACR_NAME \
    --name userpool \
    --node-count 1 \
    --node-vm-size Standard_B2s


step 4 get credentials to connect kube environment

az aks get-credentials --name $ACR_NAME --resource-group $RG_NAME