#get all service in kube-system
k get service --namespace=kube-system

# get all deployments in kube-system
k get deployments --namespace=kube-system

# describe coredns deployment
k describe deployments coredns --namespace=kube-system 

# 2 replicas volumes config-volume (mount /etc/coredns) and custom-config-volume(/etc/codedns/custom-config-volume)