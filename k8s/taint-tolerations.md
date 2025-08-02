## Tain & Tolerations

---


### 1. Taint the node

```bash
kubectl taint nodes minikube team=ml:NoSchedule
```

This adds a taint `team=ml:NoSchedule` to the node — **no pod** will be scheduled on it unless it has the matching toleration.

---

### 2. Deploy a pod *without* toleration

Save this as `no-toleration.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-no-toleration
spec:
  containers:
  - name: nginx
    image: nginx
```

Apply:

```bash
kubectl apply -f no-toleration.yaml
```

Check status:

```bash
kubectl get pods
kubectl describe pod nginx-no-toleration
```

The pod will be stuck in `Pending` state with scheduling errors.

---

### 3. Deploy a pod *with* toleration

Save this as `with-toleration.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-with-toleration
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "team"
    operator: "Equal"
    value: "ml"
    effect: "NoSchedule"
```

Apply:

```bash
kubectl apply -f with-toleration.yaml
```

Check:

```bash
kubectl get pods -o wide
```

This pod should be scheduled successfully on the tainted node.

---


## Taint with `NoExecute` – Eviction


* Pods **without toleration** are **evicted immediately**.
* Pods **with toleration**:

  * Can run if already running.
  * Stay for the defined `tolerationSeconds`.

---


### 1. Apply a pod (no toleration)

`noexecute-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-noexecute
spec:
  containers:
  - name: nginx
    image: nginx
```

```bash
kubectl apply -f noexecute-pod.yaml
```

Wait until it's running:

```bash
kubectl get pods -w
```

---

### 2. Taint node with `NoExecute`

```bash
kubectl taint nodes minikube evict=true:NoExecute
```

Now watch the pod:

```bash
kubectl get pods -w
```

The pod will be **immediately evicted**.

---

### 3. Pod with `tolerationSeconds`

`pod-tolerate-eviction.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-tolerate
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "evict"
    operator: "Equal"
    value: "true"
    effect: "NoExecute"
    tolerationSeconds: 20
```

```bash
kubectl apply -f pod-tolerate-eviction.yaml
```

Watch:

```bash
kubectl get pods -w
```

The pod will run for \~20 seconds, then be **evicted** automatically.

---

### 4. Pod that tolerates `NoExecute` forever

`pod-persistent.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-persistent
spec:
  containers:
  - name: nginx
    image: nginx
  tolerations:
  - key: "evict"
    operator: "Equal"
    value: "true"
    effect: "NoExecute"
```

```bash
kubectl apply -f pod-persistent.yaml
```

This pod will not be evicted and will stay running.

---


