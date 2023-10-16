# Deploying a cluster to existing resource group

az login
az account set --subscription "subscription id"


# create a resource group
az group create --location westeurope --resource-group AKS-CLOUD-EXISTINGNetwork

az network vnet create \
 --resource-group "AKS-CLOUD-EXISTINGNetwork"
 --name network-existing
 --address-prefix 10.0.0.0/12
 --subnet-name subnet-existing
 --subnet-prefix 10.1.0.0/16

 SUBNET_ID=$(az network vnet subnet show --resource-group AKS-CLOUD-EXISTINGNetwork  --vnet-name network-existing --name subnet-existing --query id -o tsv)
 echo $SUBNET_ID


 # create Azure CNI
az aks create \
  --resource-group AKS-CLOUD-EXISTINGNetwork
  --generate-ssh-keys \
  --name ExistingNetworkAKS
  --network-plugin azure
  --vnet-subnet-id $SUBNET_ID
  --enable-managed-identity


#Get Kubeconfig

az aks get-credentials --resource-group "AKS-Cloud-ExistingNetwork" --name ExistingNetworkAKS


# create a deployment 
alias k=kubectl

k create deployment hello-world \
  --image=gcr.io/google-samples/hello-app:1.0 \
  --replicas=3


k get pods -o wide

# create load balancer service
k expose deployment hello-world \
  --port=80 \
  --target-port=8080
  --type LoadBalancer

#Test application with curl
LOADBALANCERIP=$(k get service hello-world -o jsonpath='{.status.loadBalancer.ingress[].ip}')

curl http://$LOADBALANCERIP


#clean up 
az group delete AKS-CLOUD-EXISTINGNetwork









