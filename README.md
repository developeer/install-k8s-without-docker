# Install Kubernetes without Docker

Based on article

https://www.techrepublic.com/article/how-to-install-kubernetes-on-ubuntu-server-without-docker/

requirements - cilium-cli 

```
  brew instal cilium-cli
```

##  Installs containerd, kubernetes and initialize k8s
  - Run on all nodes

  `install-step1.sh`

  ```
sudo apt-get install containerd -y

sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml

sudo systemctl stop containerd

curl -LO https://github.com/containerd/containerd/releases/download/v1.7.16/containerd-1.7.16-linux-amd64.tar.gz

tar xvf containerd-1.7.16-linux-amd64.tar.gz

rm containerd-1.7.16-linux-amd64.tar.gz

sudo cp bin/* /usr/bin/

sudo systemctl start containerd

rm -rf bin

sudo systemctl status containerd --lines 1

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

sudo apt-add-repository "deb http://pkgs.k8s.io/ kubernetes-xenial main"

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

```

## Step 2 run on the primary/control plane

`install-step2.sh`

```
sudo kubeadm config images pull

IP_ADDR=`hostname -I | awk '{print $1}'`

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${IP_ADDR}

mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

sudo cp ./crictl.yaml /etc/crictl.yaml

sudo crictl images

watch -n 5 "kubectl get nodes"

```

## Step 3
  - Run the join command on all worker nodes

##  Tools to interact with containerd

1. crictl
2. ctr


https://github.com/kubernetes-sigs/cri-tools/blob/v1.19.0/docs/crictl.md

https://github.com/containerd/cri/blob/master/docs/registry.md

https://www.systutorials.com/docs/linux/man/1-ctr/

https://docs.redislabs.com/latest/rs/installing-upgrading/configuring/linux-swap/

https://kifarunix.com/install-and-setup-kubernetes-cluster-on-ubuntu-24-04/

https://containerd.io/

Script tested with Ubuntu Server 24.04 with all updates as of 2024-05-13

1. containerd version 1.7.16
2. ctr version 1.6.31
3. crictl version 1.30.0 
4. k8s version 1.30.0


## crictl.yaml
  
  Location of containerd.sock file is specific to Ubuntu. 
  Change if installing on other linux distributions.

```
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
pull-image-on-create: false
```

## Notes:

- Shutdown of the VM runs until long timeout because it is waiting for containerd shim to shutdown. 

```
Reached target Power-Off.
systemd-shutdown[1]: Waiting for process: containerd-shim
```
