#!/bin/bash

set -x

sudo apt-get install containerd -y

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd

sudo systemctl status containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get install kubeadm kubelet kubectl -y

sudo apt-mark hold kubeadm kubelet kubectl containerd

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

