#!/bin/bash

echo "[TASK 1] Join node to Kubernetes Cluster"
apt install -qq -y sshpass >/dev/null 2>&1
sshpass -p "root@1234" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.demo:/joincluster.sh /joincluster.sh 2>/dev/null
bash /joincluster.sh >/dev/null 2>&1
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/kubelet.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config