
# Kubernetes CLI (`kubectl`) and Kubeconfig Usage Guide

## Prerequisites
- A running Kubernetes cluster (e.g., Minikube, Kind, EKS, GKE, etc.)
- `kubectl` installed (https://kubernetes.io/docs/tasks/tools/)
- Access to the kubeconfig file (usually located at `~/.kube/config`)

---

## Basic `kubectl` Commands

### Cluster Info
```bash
kubectl cluster-info
kubectl version --short
kubectl get componentstatuses
```

### Current Context
```bash
kubectl config current-context
kubectl config get-contexts
```

### Working with Namespaces
```bash
kubectl get namespaces
kubectl create namespace dev
kubectl config set-context --current --namespace=dev
```

### Pods, Deployments, and Services
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>

kubectl get deployments
kubectl get services
kubectl get all
```

### Create Resources
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl scale deployment nginx --replicas=3
kubectl delete deployment nginx
```

---

## Kubeconfig File

### File Structure
A kubeconfig typically contains:
- `clusters` (e.g., API server endpoints)
- `users` (e.g., credentials or tokens)
- `contexts` (mapping of user + cluster + namespace)

### Location
Default path:
```bash
~/.kube/config
```

Use custom file:
```bash
kubectl --kubeconfig=/path/to/custom-kubeconfig.yaml get pods
```

Merge multiple files:
```bash
KUBECONFIG=~/.kube/config:~/.kube/devconfig kubectl config view --merge --flatten
```

---

## Switching Contexts
```bash
kubectl config use-context <context-name>
```

Rename context:
```bash
kubectl config rename-context old-name new-name
```

Delete context:
```bash
kubectl config delete-context <context-name>
```

---

## Exporting Resources
```bash
kubectl get deployment nginx -o yaml > nginx-deploy.yaml
kubectl get svc nginx -o json
```

---

## Troubleshooting
```bash
kubectl get events
kubectl describe pod <pod-name>
kubectl get pods -A
```

---

## Access Control (RBAC)
```bash
kubectl create role pod-reader --verb=get,list,watch --resource=pods --namespace=dev
kubectl create rolebinding read-pods --role=pod-reader --user=dev-user --namespace=dev
```

---

## Reference
- https://kubernetes.io/docs/reference/kubectl/
- https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
