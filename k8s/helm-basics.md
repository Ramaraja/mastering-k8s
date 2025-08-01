

## 🧑‍💻 **Helm Basics**

---

### **Create a Helm Chart**

```bash
helm create mychart
```

This generates:

```
mychart/
  Chart.yaml          # Chart metadata
  values.yaml         # Default values
  charts/             # Dependencies (empty now)
  templates/          # YAML templates for K8s
  templates/tests/    # Test hook
```

---

### **Understand the Default Structure**

* **Chart.yaml** → Chart metadata
* **values.yaml** → Default config values
* **templates/** → All Kubernetes manifests (Deployment, Service, etc.) but with **placeholders** like:

```yaml
replicas: {{ .Values.replicaCount }}
image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
```

---

### **Customize values.yaml**

Example: Change to **Nginx** and adjust replica count:

```yaml
replicaCount: 2

image:
  repository: nginx
  tag: "1.25"
  pullPolicy: IfNotPresent

service:
  type: NodePort
  port: 80

resources:
  limits:
    cpu: 200m
    memory: 256Mi
```

---

### **Template Rendering (Preview Before Install)**

```bash
helm template mychart
```

This shows the **final Kubernetes YAML** after variables are replaced.

---

### **Install the Chart**

```bash
helm install my-nginx ./mychart
```

Verify:

```bash
helm list
kubectl get pods
kubectl get svc
```

---

### **Override Values at Install Time**

Without editing `values.yaml`:

```bash
helm install my-nginx ./mychart --set replicaCount=3
```

Or use a custom file:

```bash
helm install my-nginx ./mychart -f custom-values.yaml
```

---

### **Upgrade the Release**

```bash
helm upgrade my-nginx ./mychart --set service.type=LoadBalancer
```

---

### **Export Installed Manifest**

```bash
helm get manifest my-nginx > deployed.yaml
```

This gives you the **exact YAML** that Kubernetes is running.

---

### **Uninstall the Release**

```bash
helm uninstall my-nginx
```

