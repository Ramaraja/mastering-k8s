Creating a **Kubernetes cluster in AWS using `kubeadm`** 

---

## Overview

| Step | Description                                 |
| ---- | ------------------------------------------- |
| 1    | Launch AWS EC2 instances (master & workers) |
| 2    | Set Hostnames and Update Hosts              |
| 3    | Install container runtime (docker)          |
| 4    | Install kubeadm, kubelet, kubectl           |
| 5    | Initialize master node with kubeadm         |
| 6    | Join worker nodes to the cluster            |
| 7    | Set up networking (CNI plugin like Calico)  |

---

## Prerequisites

* 2 or more EC2 instances (Ubuntu 22.04 recommended)
* Security Group allowing:

  * TCP: 22 (SSH), 6443 (API), 10250, 10255
  * UDP: 8472 (flannel or calico), etc.

---

## Step 1: Launch EC2 Instances

* One master node: `k8s-master`
* One or more worker nodes: `k8s-worker-1`, `k8s-worker-2`, etc.

Use **Ubuntu 22.04**, and at least **2 vCPUs + 2 GB RAM** (t3.small or above).

---

## Step 2: Set Hostnames and Update Hosts

On each node:

```bash
sudo hostnamectl set-hostname <k8s-master or k8s-worker-N>
```

Edit `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Add entries:

```bash
<private-ip-master>   k8s-master
<private-ip-worker1>  k8s-worker-1
<private-ip-worker2>  k8s-worker-2
```

---

## Step 3: Install Docker or Containerd (Recommended: containerd)

```bash
sudo apt-get update
sudo apt-get install -y \
    ca-certificates curl gnupg lsb-release software-properties-common

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

```
Enable Docker:
```
sudo systemctl enable docker
sudo systemctl start docker
```

Disable swap:

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

---

## Step 4: Install kubeadm, kubelet, kubectl

```bash
sudo apt update && sudo apt install -y apt-transport-https curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## Step 5: Initialize Kubernetes Master Node

On **`k8s-master`**:

```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

(Use `--control-plane-endpoint` if HA is needed.)

Once it completes, copy the `kubeadm join` command and **save it**.

Set up `kubectl` access:

```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## Step 6: Join Worker Nodes

On **each worker node**, run the `kubeadm join ...` command you got from the master.

Example:

```bash
sudo kubeadm join <master-private-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

---

## Step 7: Deploy Network Plugin (Calico)

Back on the **master node**:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

---

## Step 8: Verify Cluster

```bash
kubectl get nodes
kubectl get pods -A
```

