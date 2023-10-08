#!/bin/bash

myhosts() {
echo "192.168.50.20 k8smaster k8smaster.home.lab" >> /etc/cloud/templates/hosts.debian.tmpl
echo "192.168.50.21 k8sworker1 k8sworker1.home.lab" >> /etc/cloud/templates/hosts.debian.tmpl
}

#disable swap
myswapoff(){
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
tee /etc/modules-load.d/containerd.conf <<EOF
	overlay
	br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
tee /etc/sysctl.d/kubernetes.conf <<EOF
	net.bridge.bridge-nf-call-ip6tables = 1
	net.bridge.bridge-nf-call-iptables = 1
	net.ipv4.ip_forward = 1
EOF
sysctl -w net.ipv4.ip_forward=1
}

#install containerd
mycontainerd() {
apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo chown $(id -u):$(id -g) /var/run/docker.sock
systemctl restart containerd
systemctl enable containerd
}

#add kuber repo
mykuberepo(){
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" -y
}

#install kuber
mykubeinst(){
apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
}

#init kuber
mykubeinit() {
sudo kubeadm init --control-plane-endpoint=k8smaster.home.lab
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml -O
kubectl apply -f calico.yaml
}

myhosts
myswapoff
mycontainerd
mykuberepo
mykubeinstscripts
