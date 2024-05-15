#!/bin/bash

set -x

# This script is run on the primary/control plane node
# install-step2.sh

sudo kubeadm config images pull

IP_ADDR=`hostname -I | awk '{print $1}'`

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --apiserver-advertise-address=${IP_ADDR}

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

sudo cp ./crictl.yaml /etc/crictl.yaml

sudo crictl images

watch -n 5 "kubectl get nodes"

