k config current-context

cd  F:\personal\kapilkhubchandani\aks-help\sql-server
mkdir namespace

cd namespace

k create namespace my-profile --dry-run=client -o yaml > profile.namespace.yaml

cat profile.namespace.yaml

k apply -f profile.namespace.yaml

k get namespace

cd ../services

k create svc clusterip profile-h --tcp=1433:1433 --namespace=my-profile --dry-run=client -o yaml > mssql.headless-services.yaml

cd ../storage
k apply -f mssql.pvc.yaml

cd ../StatefulSet

k create secret generic mssql --from-literal=MSSQL_SA_PASSWORD="*****" --namespace=my-profile

k apply -f mssql.statefulset.yaml


# to verify if sql server is connected, create  a load balancer service
cd ../services

k apply -f mssql.loadbalancer-service.yaml

#get the endpoints 

k get svc mssql-deployment --namespace=my-profile

#once verified delete the loadbalancer service since it's not secured

k delete svc mssql-deployment --namespace=my-profile