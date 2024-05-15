#!/bin/bash

set -x

# This script is run on the primary/control plane node
# install-step2.sh

#prereq cilium-cli :  brew install cilium-cli

sudo kubeadm config images pull

IP_ADDR=`hostname -I | awk '{print $1}'`

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-advertise-address=${IP_ADDR}

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

# good if you don't need metallb
#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

#cilium - comment out if you are using calico
cilium install --version 1.15.5

sudo cp ./crictl.yaml /etc/crictl.yaml

sudo crictl images

watch -n 5 "kubectl get nodes"

# https://metallb.universe.tf/installation/
# Install metallb for your installation
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

