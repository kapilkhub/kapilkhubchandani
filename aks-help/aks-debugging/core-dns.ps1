k logs --namespace kube-system --selector=k8s-app=kube-dns -f

k run dnsutils --image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 -- sleep infinity

k exec -it dnsutils -- bash