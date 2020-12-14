# Install Kubernetes without Docker

Based on article

https://www.techrepublic.com/article/how-to-install-kubernetes-on-ubuntu-server-without-docker/

Note:  The scripts only install and configure the primary k8s node.

##  Installs containerd, kubernetes and initialize k8s

  `install-k8s-01.sh`

  ```
  sudo apt-get install containerd -y

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt-get install kubeadm kubelet kubectl -y

sudo apt-mark hold kubeadm kubelet kubectl containerd

SOURCE_FILE="/etc/sysctl.conf"
LINE_INPUT="net.bridge.bridge-nf-call-iptables = 1"

grep -qF "$LINE_INPUT" "$SOURCE_FILE"  || echo "$LINE_INPUT" | sudo tee -a "$SOURCE_FILE"

#echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.conf

sudo echo '1' | sudo tee /proc/sys/net/ipv4/ip_forward

sudo sysctl --system

sudo modprobe overlay
sudo modprobe br_netfilter

sudo swapoff -a

sudo sed -i.bak '/ swap / s/^(.*)$/#1/g' /etc/fstab

sudo kubeadm config images pull

IP_ADDR=$(hostname -i)

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$IP_ADDR
```


## Create kube config and install Network CNI

  `install-k8s-02.sh`
  After kubernetes is installed, Copy the kube config and 
  install Weave CNI. Flannel is also in the script if desired.

```
mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

kubectl get nodes
```



##   Install crictl command line application to interact with containerd.

  `install-cri-tool.sh`

```
export VERSION="v1.19.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

sudo crictl images

#default location for crictl configuration
sudo cp ./crictl.yaml /etc/crictl.yaml
```

Tools to interact with containerd

1. ctrctl
2. ctr


https://github.com/kubernetes-sigs/cri-tools/blob/v1.19.0/docs/crictl.md

https://github.com/containerd/cri/blob/master/docs/registry.md

https://www.systutorials.com/docs/linux/man/1-ctr/

https://docs.redislabs.com/latest/rs/installing-upgrading/configuring/linux-swap/