#!/bin/bash

set -x

export VERSION="v1.19.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

sudo crictl images

#default location for crictl configuration
sudo cp ./crictl.yaml /etc/crictl.yaml

