#!/bin/bash

set -x

# This script is run on the primary/control plane node
# install-step2.sh

sudo kubeadm config images pull

IP_ADDR=`hostname -I | awk '{print $1}'`

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${IP_ADDR}

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

sudo cp ./crictl.yaml /etc/crictl.yaml

sudo crictl images

watch -n 5 "kubectl get nodes"

