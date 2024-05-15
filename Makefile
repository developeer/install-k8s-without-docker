#!/bin/bash

reset:
	sudo ./reset-k8s.sh

step1:
	./install-step1.sh

step2:
	./install-step2.sh

join:
	kubeadm token create --print-join-command