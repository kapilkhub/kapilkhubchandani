#get all service in kube-system
k get service --namespace=kube-system

# get all deployments in kube-system
k get deployments --namespace=kube-system

# describe coredns deployment
k describe deployments coredns --namespace=kube-system 

# 2 replicas volumes config-volume (mount /etc/coredns) and custom-config-volume(/etc/codedns/custom-config-volume)


#3 config map for core dns
k get cm --namespace=kube-system coredns -o yaml


#4 To check if service is getting mapped correctly to pod

#a. get the IP of coredns
SERVICEIP=$(k get service --namespace kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')

 get the pod of coredns
nslookup 10-244-0-44.default.pod.cluster.local $SERVICEIP

#b do nslookup on pod A record
nslookup 10-244-0-44.default.pod.cluster.local $SERVICEIP


k get endpoints $serviceName

#output of the above command must equal to pod