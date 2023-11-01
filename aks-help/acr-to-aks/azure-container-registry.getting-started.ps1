$ACR_NAME="khubchandanicontainerregistry"

az acr create -n $ACR_NAME -g kapilkhubchandaniorg --sku Basic

# get all acr list
az acr list -o table

#get repository list
az acr repository list -n $ACR_NAME -o table

#import hello-world image from docker repository
az acr import -n $ACR_NAME --source docker.io/library/hello-world:latest -t hello-world-backup:1.0.0

#get repository list again
az acr repository list -n $ACR_NAME -o table
#Result
#------------------
#hello-world-backup

#get image repository details 
az acr repository show -n $ACR_NAME --repository hello-world-backup -o table

###CreatedTime                  ImageName           LastUpdateTime                ManifestCount    Registry                                  TagCount
###---------------------------  ------------------  ----------------------------  ---------------  ----------------------------------------  ----------
###2023-10-17T18:48:52.430557Z  hello-world-backup  2023-10-17T18:48:51.1766026Z  12               khubchandanicontainerregistry.azurecr.io  1

# show tags 
az acr repository show-tags -n $ACR_NAME --repository hello-world-backup -o table
###Result
###--------
###1.0.0

#import again with new tab
az acr import -n $ACR_NAME --source docker.io/library/hello-world:latest -t hello-world-backup:1.1.0

# add another image
az acr import -n $ACR_NAME --source docker.io/library/nginx:latest -t nginx:v1

#check the repository again 
az acr repository list -n $ACR_NAME -o table

###Result
###------------------
###hello-world-backup
###nginx

#show tags 
az acr repository show-tags -n $ACR_NAME --repository hello-world-backup -o table
###Result
###--------
###1.0.0
###1.1.0

## clone a repository
git clone https://github.com/Azure-Samples/acr-build-helloworld-node

### build image 
az acr build --registry $ACR_NAME --image helloacrtasks:v1 .\acr-build-helloworld-node\

### view image again 
az acr repository list -n $ACR_NAME -o table

### delete repo
Remove-Item .\acr-build-helloworld-node\ -Recurse -Force


### get login server 
az acr show -n $ACR_NAME -o table

### get login server
$loginServer=(az acr show -n $ACR_NAME --query loginServer)



###################################### Kubernetes ##########################################
k create namespace acr

## deployment 
## set current context 
k config set-context --current --namespace acr
k create deployment nginx --image=$loginServer/nginx:v1

#it doesn't work, we need to attach acr with aks
az aks update -n $AKSCluster -g $RG --attach-acr $ACR_NAME

#lets do again 
k create deployment nginx --image=$loginServer/nginx:v1


#cleanup
az acr delete -n $ACR_NAME


