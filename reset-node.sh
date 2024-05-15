#!/bin/bash

kubectl drain jiku02 --delete-emptydir-data --force --ignore-daemonsets 
kubectl delete node jiku02

kubectl drain jiku03 --delete-emptydir-data --force --ignore-daemonsets 
kubectl delete node jiku03

kubectl drain jiku04 --delete-emptydir-data --force --ignore-daemonsets 
kubectl delete node jiku04




 # on each node run sudo kubeadm reset and reboot