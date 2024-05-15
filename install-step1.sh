#!/bin/bash

set -x

# This script is run on both the primary and worker nodes
# install-step1.sh

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

sudo apt-get install containerd -y

sudo mkdir -p /etc/containerd

#containerd config default | sudo tee /etc/containerd/config.toml
sudo containerd config default | sudo tee /etc/containerd/config.toml

sudo sed -i '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml

sudo sed -i '/pause:3.8/s/3.8/3.9/' /etc/containerd/config.toml

sudo systemctl stop containerd

curl -LO https://github.com/containerd/containerd/releases/download/v1.7.16/containerd-1.7.16-linux-amd64.tar.gz

tar xvf containerd-1.7.16-linux-amd64.tar.gz

sudo cp bin/* /usr/bin/

sudo systemctl start containerd

rm -rf bin
rm containerd-1.7.16-linux-amd64.tar.gz

sudo systemctl status containerd --lines 1

sudo apt-get install kubeadm kubelet kubectl -y

sudo apt-mark hold kubeadm kubelet kubectl containerd

sudo systemctl enable --now kubelet

#echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.conf

SOURCE_FILE="/etc/sysctl.conf"
LINE_INPUT="net.bridge.bridge-nf-call-iptables = 1"

grep -qF "$LINE_INPUT" "$SOURCE_FILE"  || echo "$LINE_INPUT" | sudo tee -a "$SOURCE_FILE"

sudo echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward

cat /proc/sys/net/ipv4/ip_forward

sudo sysctl --system

sudo modprobe overlay
sudo modprobe br_netfilter

sudo swapoff -a

sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

cat /etc/fstab

