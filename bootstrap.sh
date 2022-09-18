#!/bin/bash

KUBE_VERSION=1.23.0

echo "[TASK 1] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK 2] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK 3] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK 4] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[TASK 5] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt install -qq -y git curl zsh strace gnupg2 software-properties-common >/dev/null 2>&1
curl -s -N https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
apt update -qq >/dev/null 2>&1
apt install -qq -y kubelet=${KUBE_VERSION}-00 kubeadm=${KUBE_VERSION}-00 kubectl=${KUBE_VERSION}-00 kubernetes-cni=0.8.7-00 >/dev/null 2>&1

echo "[TASK 6] Enable cgroup driver"
cat >/etc/docker/daemon.json<<EOF
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

echo "[TASK 7] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 8] Update /etc/resolv.conf"
cat >/etc/resolv.conf<<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo "[TASK 9] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
10.25.1.10   kmaster.demo     kmaster
10.25.1.11   kworker1.demo    kworker1
10.25.1.12   kworker2.demo    kworker2
EOF
