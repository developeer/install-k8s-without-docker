ELL:=/bin/bash

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

metrics:
	kubectl apply -f components.yaml

dashboard:
	helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
	helm repo update
	helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

admin-user:
	kubectl apply -f ./dashboard-admin-user.yaml
	kubectl apply -f ./cluster-role-binding.yaml
	kubectl apply -f ./long-lived-token.yaml
	kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d

prometheus:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	-kubectl create namespace monitoring
	kubectl apply -f kube-prometheus-stack-pv.yaml
	kubectl apply -f kube-prometheus-stack-pvc.yaml
	helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --set=alertmanager.persistentVolume.existingClaim=kube-prometheus-stack-pvc,server.persistentVolume.existingClaim=kube-prometheus-stack-pvc,grafana.persistentVolume.existingClaim=kube-prometheus-stack-pvc
	kubectl get svc -n monitoring

init-spin:
	helm repo add kwasm http://kwasm.sh/kwasm-operator/
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

spin:
	-kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.crds.yaml

	-helm install \
	cert-manager jetstack/cert-manager \
	--namespace cert-manager \
	--create-namespace \
	--version v1.14.5


	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.crds.yaml
	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.runtime-class.yaml
	-kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.shim-executor.yaml

	-helm install spin-operator \
	--namespace spin-operator \
	--create-namespace \
	--version 0.2.0 \
	--wait \
	oci://ghcr.io/spinkube/charts/spin-operator

	-helm install \
	kwasm-operator kwasm/kwasm-operator \
	--namespace kwasm \
	--create-namespace \
	--set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v0.14.1

	-kubectl annotate node --all kwasm.sh/kwasm-node=true

test-spin:
	kubectl apply -f https://raw.githubusercontent.com/spinkube/spin-operator/main/config/samples/simple.yaml
	kubectl -n default port-forward svc/simple-spinapp 8083:80

test-spinapp:
	curl localhost:8083/hello

connect-prometheus:
	kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090

proxy:
	kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

delete-spin:
	-kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.5/cert-manager.crds.yaml --force
	-kubectl delete -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.shim-executor.yaml --force
	-kubectl delete -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.runtime-class.yaml --force
	-kubectl delete -f https://github.com/spinkube/spin-operator/releases/download/v0.2.0/spin-operator.crds.yaml --force
	-kubectl delete namespace kwasm --force
	-kubectl delete namespace cert-manager --force
	-kubectl delete namespace spin-operator --force
	-helm delete spin-operator --namespace spin-operator --force
	-helm delete kwasm-operator --namespace kwasm --force


remove-prometheus:
	kubectl delete namespace monitoring

remove-metrics:
	kubectl delete -f components.yaml

delete-dashboard:
	kubectl delete namespace kubernetes-dashboard


delete-metallb:
	kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml --force