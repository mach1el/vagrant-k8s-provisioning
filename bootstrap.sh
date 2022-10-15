#!/bin/bash

echo "[ZSH] Update latest version"
sudo -H -u vagrant zsh -ic "omz update -y" >/dev/null 2>&1
zsh -ic "omz update" >/dev/null 2>&1

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

echo "[TASK 5] Install and Configure containerd"
apt update >/dev/null 2>&1 && apt install -yqq containerd >/dev/null 2>&1
wget -O /etc/containerd/config.toml https://gist.githubusercontent.com/mach1el/35d457d624395c85ac63ce73b7337f86/raw/a753c3c34d56f2c30150aa38a29028e84a889061/config.toml >/dev/null 2>&1
systemctl restart containerd >/dev/null 2>&1
systemctl enable containerd >/dev/null 2>&1

echo "[TASK 6] Install Kubernetes components (kubeadm, kubelet and kubectl)"
curl -s -N https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1
apt update -qq >/dev/null 2>&1
apt install -qq -y kubelet kubeadm kubectl >/dev/null 2>&1

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