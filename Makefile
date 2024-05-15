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


	kubeadm join 192.168.122.58:6443 --token swq4mw.7gv3t3hkrp96uus1 --discovery-token-ca-cert-hash sha256:aa18191a48728422a1248d16ce9cde6ead8f89d2b8f9cf5fe29e5453c2b81497

