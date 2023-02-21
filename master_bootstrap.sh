#!/bin/bash

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=10.98.1.10 --pod-network-cidr=10.244.0.0/16 >> /root/kubeinit.log 2>/dev/null
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 3] Restart services"
systemctl restart containerd
systemctl restart kubelet

echo "[TASK 4] Deploy Calico network"
# kubectl apply -f "https://docs.projectcalico.org/manifests/calico.yaml" >/dev/null 2>&1
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml >/dev/null 2>&1
kubectl taint nodes --all node-role.kubernetes.io/control-plane- >/dev/null 2>&1

echo "[TASK 5] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh