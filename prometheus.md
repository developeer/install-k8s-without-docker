


Install Prometheus on k8s

https://devapo.io/blog/technology/how-to-set-up-prometheus-on-kubernetes-with-helm-charts/

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus

helm list


kubectl port-forward &lt;prometheus-pod-name&gt; 9090 

