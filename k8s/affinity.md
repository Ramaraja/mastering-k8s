
* **Node Affinity**
* **Pod Affinity**
* **Pod Anti-Affinity**

---

## 1. Node Affinity (Required and Preferred)

### Label a node:

```bash
kubectl label nodes <node-name> disktype=ssd
```

### Create Pod with Node Affinity

Save as `node-affinity-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
      preferredDuringSchedulingIgnoredDuringExecution:
      - preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
        weight: 1
  containers:
  - name: nginx
    image: nginx
```

Apply:

```bash
kubectl apply -f node-affinity-pod.yaml
```

Pod will be scheduled only on nodes with `disktype=ssd`.

---

## 2. Pod Affinity (Schedule near certain pods)

Save as `pod-affinity.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-affinity
  labels:
    app: myapp
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - myapp
        topologyKey: "kubernetes.io/hostname"
  containers:
  - name: nginx
    image: nginx
```

This pod will be scheduled **on the same node as other pods with `app=myapp`**.

---

## 3. Pod Anti-Affinity (Schedule away from certain pods)

Save as `pod-anti-affinity.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-anti-affinity
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - myapp
        topologyKey: "kubernetes.io/hostname"
  containers:
  - name: nginx
    image: nginx
```

This pod will be scheduled on a different node than pods with `app=myapp`.

---

