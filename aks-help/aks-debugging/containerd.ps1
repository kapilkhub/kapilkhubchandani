kubectl debug node/aks-userpool-32898286-vmss000002 -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0

chroot /host

systemctl status containerd

crictl images

crictl pods

crictl ps



