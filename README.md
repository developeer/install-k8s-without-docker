# Install Kubernetes without Docker

Based on article

https://www.techrepublic.com/article/how-to-install-kubernetes-on-ubuntu-server-without-docker/

Note:  The script only installs and configures the primary k8s node.

##  Installs containerd, kubernetes and initialize k8s

  `install-k8s-01.sh`

  ```
sudo apt-get install containerd -y

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl restart containerd

sudo systemctl status containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get install kubeadm kubelet kubectl -y

sudo apt-mark hold kubeadm kubelet kubectl containerd

#echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.conf

SOURCE_FILE="/etc/sysctl.conf"
LINE_INPUT="net.bridge.bridge-nf-call-iptables = 1"

grep -qF "$LINE_INPUT" "$SOURCE_FILE"  || echo "$LINE_INPUT" | sudo tee -a "$SOURCE_FILE"

sudo echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward

cat /proc/sys/net/ipv4/ip_forward

sudo sysctl --system

sudo modprobe overlay
sudo modprobe br_netfilter

sudo swapoff -a

sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

cat /etc/fstab

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

```


##  Tools to interact with containerd

1. crictl
2. ctr


https://github.com/kubernetes-sigs/cri-tools/blob/v1.19.0/docs/crictl.md

https://github.com/containerd/cri/blob/master/docs/registry.md

https://www.systutorials.com/docs/linux/man/1-ctr/

https://docs.redislabs.com/latest/rs/installing-upgrading/configuring/linux-swap/

Script tested with Ubuntu Server 20.4.1 with all updates as of 2020-12-14

1. containerd version 1.3.3
2. ctr version 1.3.3
3. crictl version 1.13.0 
4. k8s version 1.20.0


## crictl.yaml
  
  Location of containerd.sock file is specific to Ubuntu. 
  Change if installing on other linux distributions.

```
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
pull-image-on-create: false
```

