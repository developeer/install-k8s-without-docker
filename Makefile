#!/bin/bash

reset:
	sudo ./reset-k8s.sh

reset-node:
	sudo ./reset-nodes.sh

step1:
	./install-step1.sh

step2:
	./install-step2.sh

join:
	kubeadm token create --print-join-command

pool:
	kubectl apply -f ./addresspool.yaml

