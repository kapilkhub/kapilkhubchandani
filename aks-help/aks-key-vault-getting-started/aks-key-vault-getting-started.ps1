# set variables to be used 
$Region="westeurope"
$RG="kapilkhubchandaniorg"
$Sub="3e4e586a-a0ff-49db-bb07-e8cb8fa5601a"
$AKSCluster="acrkhubchandani"

az login

az account set -s $Sub

# First, we need a Key Vault
$KVName="AKSKeyVault"+(Get-Random -Minimum 100000000 -Maximum 99999999999)

az keyvault create --name $KVName --resource-group $RG --location $Region

# Let's save a secret
az keyvault secret set --vault-name $KVName --name "TestKey" --value "TestSecret"
az keyvault secret show --name "TestKey" --vault-name $KVName --query "value"

set-alias -name k -value kubectl

k create namespace keyvault

k config set-context --current --namespace keyvault

# Install CSI Driver including auto rotation
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts/
helm repo update
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --set enableSecretRotation=True


# And the CSI Azure Provider
kubectl apply -f https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/deployment/provider-azure-installer.yaml

#secret provider
code secret-provide-class-dist.yaml


# We can automate modifying all  settings in YAML through PowerShell
$SPC = Get-Content "secret-provide-class-dist.yaml" | ConvertFrom-YAML
$SPC.spec.parameters.keyvaultName=$KVName
$SPC.spec.parameters.resourceGroup=$RG
$SPC.spec.parameters.subscriptionId=$Sub
$SPC.spec.parameters.tenantId=(az account show --query tenantId -o tsv)
$SPC=ConvertTo-YAML $SPC
Set-Content "secret-provide-class.yaml" -Value $SPC

# The order has changed - but that doesn't matter!
code --diff secret-provide-class.yaml secret-provide-class-dist.yaml 

# Create the class
kubectl apply -f secret-provide-class.yaml 

$SP="http://azakvsp"

$SP_Result=(az ad sp create-for-rbac -n $SP) | ConvertFrom-JSON

$SP_Key=$SP_Result.password
$SP_ClientId=$SP_Result.appId

# Role Assignment for AKV
az role assignment create --role Reader --assignee $SP_ClientID `
        --scope /subscriptions/$Sub/resourcegroups/$RG/providers/Microsoft.KeyVault/vaults/$KVName


# Set permissions to read secrets
az keyvault set-policy -n $KVName --secret-permissions get --spn $SP_ClientID

# Let's add Key and Cert permissions, too
az keyvault set-policy -n $KVName --key-permissions get --spn $SP_ClientID
az keyvault set-policy -n $KVName --certificate-permissions get --spn $SP_ClientID


# The SP needs it's credentials stored in (one single) secret (other auth types don't require that)
kubectl create secret generic akv-creds --from-literal clientid=$SP_ClientID --from-literal clientsecret=$SP_Key


kubectl apply -f nginx-secrets-store.yaml

kubectl get pods
kubectl describe pod nginx-secrets-store


# We can see the Secret in the Pod
kubectl exec -it nginx-secrets-store -- ls -l /mnt/secrets-store/


# What if we upgrade the key?
# Currently, AKS and AKV are in sync
kubectl get secretproviderclasspodstatus `
        (kubectl get secretproviderclasspodstatus -o custom-columns=":metadata.name" ) -o yaml | grep version:

az keyvault secret show --name "TestKey" --vault-name $KVName --query "id" -o tsv

# Set a new value for the secret
az keyvault secret set --vault-name $KVName --name "TestKey" --value "NewSecret"
az keyvault secret show --name "TestKey" --vault-name $KVName --query "value"

kubectl exec -it nginx-secrets-store -- bash -c "cat /mnt/secrets-store/TestKey"


kubectl get secretproviderclasspodstatus `
        (kubectl get secretproviderclasspodstatus -o custom-columns=":metadata.name" ) -o yaml 


az keyvault secret show --name "TestKey" --vault-name $KVName --query "id" -o 






# How about using the VM Identity instead of a Service Principal?
# Delete the existing deployment, secret and also the SP
kubectl delete pod nginx-secrets-store
kubectl delete secret akv-creds
az ad sp delete --id $SP

# Let's change the config to VMM Identity
kubectl edit SecretProviderClass azure-kv-provider

# And create another Pod with a new manifest
# Let's compare the two manifests first!
code --diff nginx-secrets-store.yaml nginx-secrets-store-vmm.yaml

kubectl apply -f nginx-secrets-store-vmm.yaml

# But the Pod isn't starting
kubectl get pod nginx-secrets-store
kubectl describe pod nginx-secrets-store

# We need to grant this Identity permissions first
kubectl delete pod nginx-secrets-store

# Get the AKS Cluster's client ID and grant permissions to it
az aks show -n $AKSCluster -g $RG --query identityProfile

$clientId=(az aks show -n $AKSCluster -g $RG --query identityProfile.kubeletidentity.clientId -o tsv)

az keyvault set-policy -n $KVName --secret-permissions get --spn $clientId

# Let's try again
kubectl apply -f nginx-secrets-store-vmm.yaml

kubectl get pod nginx-secrets-store

# Cleanup
kubectl delete namespace keyvault
Clear-Host
