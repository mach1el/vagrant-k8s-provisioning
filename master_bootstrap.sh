#!/bin/bash

KUBE_VERSION=1.24.0

echo "[TASK 1] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK 2] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=10.25.1.10 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 3] Deploy Calico network"
kubectl apply -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1
# kubectl taint nodes --all node-role.kubernetes.io/master- >/dev/null 2>&1

echo "[TASK 4] Generate and save cluster join command to /joincluster.sh"
kubeadm token create --print-join-command > /joincluster.sh