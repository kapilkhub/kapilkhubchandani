#Deploying a cluster to new virtual network
az login
az account set --subscription "subscription id"


# create a resource group
az group create --location westeurope --resource-group kapilkhubchandaniorg

#create AKS cluster with default setting with kubenet networking model
az aks create \
  -- resource-group kapilkhubchandaniorg
  -- generate-ssh-keys \
  -- name akskhubchandani

#Get the kubeconfig

az aks get-credentials --resource-group kapilkhubchandaniorg --name acrkhubchandani

# about nodes
k get nodes -o wide

k describe nodes


az delete --resource-group MyResourceGroup