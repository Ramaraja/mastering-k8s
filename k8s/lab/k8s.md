### Kubernetes Exercises: 

---

### **1. Basic Pod Creation**

#### **Objective:**
Create a pod using a manifest file and verify its status.

#### **Steps:**
1. Create a file named `nginx-pod.yaml`:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: nginx-pod
   spec:
     containers:
       - name: nginx-container
         image: nginx:1.21
         ports:
           - containerPort: 80
   ```

2. Apply the manifest:
   ```bash
   kubectl apply -f nginx-pod.yaml
   ```

3. Verify the pod status:
   ```bash
   kubectl get pods
   kubectl describe pod nginx-pod
   ```

4. Access the pod logs:
   ```bash
   kubectl logs nginx-pod
   ```

---

### **2. Expose Pod Using a Service**

#### **Objective:**
Expose the nginx pod using a **ClusterIP** service and access it within the cluster.

#### **Steps:**
1. Create a service definition named `nginx-service.yaml`:
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: nginx-service
   spec:
     selector:
       app: nginx
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
     type: ClusterIP
   ```

2. Add the `app` label to the pod for service discovery. Edit the pod manifest (`nginx-pod.yaml`) or use:
   ```bash
   kubectl label pod nginx-pod app=nginx
   ```

3. Apply the service:
   ```bash
   kubectl apply -f nginx-service.yaml
   ```

4. Verify the service:
   ```bash
   kubectl get service nginx-service
   ```

5. Access the service:
   ```bash
   kubectl exec -it <another-pod> -- curl nginx-service
   ```

---

### **3. Create a NodePort Service**

#### **Objective:**
Expose a pod using a **NodePort** service to make it accessible on a node's IP.

#### **Steps:**
1. Create a NodePort service definition:
   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: nginx-nodeport
   spec:
     selector:
       app: nginx
     ports:
       - protocol: TCP
         port: 80
         targetPort: 80
         nodePort: 30080
     type: NodePort
   ```

2. Apply the service:
   ```bash
   kubectl apply -f nginx-nodeport.yaml
   ```

3. Test the service:
   ```bash
   curl http://<node-ip>:30080
   ```

---

### **4. ReplicaSet Exercise**
#### **Objective:**  
Create a ReplicaSet with three replicas of an Nginx pod.

#### **Steps:**
1. Create a `replicaset.yaml` file:
   ```yaml
   apiVersion: apps/v1
   kind: ReplicaSet
   metadata:
     name: nginx-replicaset
   spec:
     replicas: 3
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
           - name: nginx
             image: nginx:1.21
             ports:
               - containerPort: 80
   ```

2. Apply the ReplicaSet:
   ```bash
   kubectl apply -f replicaset.yaml
   ```

3. Verify the ReplicaSet:
   ```bash
   kubectl get replicaset
   kubectl get pods -l app=nginx
   ```

4. Scale the ReplicaSet to 5 replicas:
   ```bash
   kubectl scale replicaset nginx-replicaset --replicas=5
   ```

5. Delete the ReplicaSet:
   ```bash
   kubectl delete -f replicaset.yaml
   ```

---

### **5. Deployment Exercise**
#### **Objective:**  
Create a Deployment for an **Apache web server**, update the image, and scale it.

#### **Steps:**
1. Create a `deployment.yaml` file:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: apache-deployment
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: apache
     template:
       metadata:
         labels:
           app: apache
       spec:
         containers:
           - name: apache
             image: httpd:2.4
             ports:
               - containerPort: 80
   ```

2. Apply the Deployment:
   ```bash
   kubectl apply -f deployment.yaml
   ```

3. Verify the Deployment:
   ```bash
   kubectl get deployments
   kubectl get pods -l app=apache
   ```

4. Update the Deployment (change the image to `httpd:2.4.58`):
   ```bash
   kubectl set image deployment/apache-deployment apache=httpd:2.4.58
   ```

5. Verify the update:
   ```bash
   kubectl rollout status deployment/apache-deployment
   ```

6. Rollback the Deployment:
   ```bash
   kubectl rollout undo deployment/apache-deployment
   ```

7. Scale the Deployment to 4 replicas:
   ```bash
   kubectl scale deployment apache-deployment --replicas=4
   ```

8. Delete the Deployment:
   ```bash
   kubectl delete -f deployment.yaml
   ```

---

### **6. ConfigMap Exercise**
#### **Objective:**  
Create a ConfigMap and use it inside a pod.

#### **Steps:**
1. Create a ConfigMap from a file:
   ```bash
   echo "message=Welcome to Kubernetes ConfigMaps!" > config.txt
   kubectl create configmap app-config --from-file=config.txt
   ```

2. Verify the ConfigMap:
   ```bash
   kubectl get configmap app-config -o yaml
   ```

3. Create a pod that uses the ConfigMap:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: configmap-pod
   spec:
     containers:
       - name: alpine
         image: alpine
         command: ["sleep", "3600"]
         env:
           - name: APP_MESSAGE
             valueFrom:
               configMapKeyRef:
                 name: app-config
                 key: message
   ```

4. Apply the pod:
   ```bash
   kubectl apply -f configmap-pod.yaml
   ```

5. Verify that the pod has access to the ConfigMap:
   ```bash
   kubectl exec configmap-pod -- env | grep APP_MESSAGE
   ```

6. Delete the ConfigMap and Pod:
   ```bash
   kubectl delete configmap app-config
   kubectl delete pod configmap-pod
   ```

---

### **7. Secret Exercise**
#### **Objective:**  
Create a Secret and use it inside a pod.

#### **Steps:**
1. Create a Secret from CLI:
   ```bash
   kubectl create secret generic db-secret --from-literal=username=admin --from-literal=password=pass123
   ```

2. Verify the Secret:
   ```bash
   kubectl get secrets db-secret -o yaml
   ```

3. Create a pod that uses the Secret:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: secret-pod
   spec:
     containers:
       - name: alpine
         image: alpine
         command: ["sleep", "3600"]
         env:
           - name: DB_USERNAME
             valueFrom:
               secretKeyRef:
                 name: db-secret
                 key: username
           - name: DB_PASSWORD
             valueFrom:
               secretKeyRef:
                 name: db-secret
                 key: password
   ```

4. Apply the pod:
   ```bash
   kubectl apply -f secret-pod.yaml
   ```

5. Verify that the pod has access to the Secret:
   ```bash
   kubectl exec secret-pod -- env | grep DB_
   ```

6. Delete the Secret and Pod:
   ```bash
   kubectl delete secret db-secret
   kubectl delete pod secret-pod
   ```

---

### **8. Combine ConfigMap & Secret in a Deployment**
#### **Objective:**  
Use both a **ConfigMap and Secret** inside a Deployment.

#### **Steps:**
1. Create a ConfigMap:
   ```bash
   kubectl create configmap app-config --from-literal=app_name=MyApp
   ```

2. Create a Secret:
   ```bash
   kubectl create secret generic db-secret --from-literal=db_user=root --from-literal=db_pass=secret
   ```

3. Create a Deployment that uses them:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: app-deployment
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: myapp
     template:
       metadata:
         labels:
           app: myapp
       spec:
         containers:
           - name: app-container
             image: alpine
             command: ["sleep", "3600"]
             env:
               - name: APP_NAME
                 valueFrom:
                   configMapKeyRef:
                     name: app-config
                     key: app_name
               - name: DB_USER
                 valueFrom:
                   secretKeyRef:
                     name: db-secret
                     key: db_user
               - name: DB_PASS
                 valueFrom:
                   secretKeyRef:
                     name: db-secret
                     key: db_pass
   ```

4. Apply the Deployment:
   ```bash
   kubectl apply -f app-deployment.yaml
   ```

5. Verify that the environment variables are set:
   ```bash
   kubectl exec -it <pod-name> -- env | grep APP_
   kubectl exec -it <pod-name> -- env | grep DB_
   ```

6. Clean up:
   ```bash
   kubectl delete deployment app-deployment
   kubectl delete configmap app-config
   kubectl delete secret db-secret
   ```

---
**short and efficient way to create Kubernetes resource definitions** 

`kubectl run` or `kubectl expose` for quick testing

---

## **Quick Commands reference** (no YAML needed)

### Create a Pod (with image nginx)

```bash
kubectl run nginx --image=nginx
```

### Expose it as a Service

```bash
kubectl expose pod nginx --port=80 --type=NodePort
```

### Create a Deployment (3 replicas)

```bash
kubectl create deployment web --image=nginx --replicas=3
```

### Create HPA (scale between 2–5 pods based on CPU)

```bash
kubectl autoscale deployment web --cpu-percent=50 --min=2 --max=5
```

### Generate YAML From Commands

```bash
kubectl create deployment demo --image=nginx --dry-run=client -o yaml
```

---

