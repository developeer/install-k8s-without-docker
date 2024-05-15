#!/bin/bash

kubectl drain jiku01 --delete-emptydir-data --force --ignore-daemonsets 
kubectl delete node jiku01

kubeadm reset

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

sudo rm -rf /etc/cni/net.d
