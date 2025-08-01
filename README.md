# Fullstack Observability Stack

This repository provides a step-by-step guide to set up an observability stack using Kubernetes and Helm. The stack includes Prometheus, Grafana, Loki, Promtail, Node Exporter, and Blackbox Exporter.

---

## Prerequisites

Before starting, ensure the following tools are installed and configured:

1. **kubectl**: Kubernetes command-line tool.  
   [Installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. **Helm**: Kubernetes package manager.  
   [Installation guide](https://helm.sh/docs/intro/install/)
3. **Minikube** (optional): Local Kubernetes cluster for testing.  
   [Installation guide](https://minikube.sigs.k8s.io/docs/start/)

---

## Directory Structure

```
helm-kube-observability-stack/
├── charts/
├── templates/
│   ├── grafana-deployment.yaml
│   ├── grafana-service.yaml
│   ├── loki-deployment.yaml
│   ├── loki-service.yaml
│   ├── node-exporter-daemonset.yaml
│   ├── node-exporter-service.yaml
│   ├── prometheus-deployment.yaml
│   ├── prometheus-service.yaml
│   ├── prometheus-config.yaml
│   ├── promtail-deployment.yaml
│   ├── promtail-service.yaml
│   ├── promtail-config.yaml
│   ├── blackbox-exporter-deployment.yaml
│   ├── blackbox-exporter-service.yaml
│   ├── blackbox-exporter-config.yaml
│   ├── namespace.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
├── values.yaml
├── Chart.yaml
```

---

## Installation Steps

### Step 1: Create Namespace
Apply the namespace file:
```bash
kubectl apply -f templates/namespace.yaml
```

### Step 2: Deploy the Helm Chart
Install the Helm chart using the command below. The `--create-namespace` flag will automatically create the `kube-observability-stack` namespace for you if it doesn't exist.

```bash
helm install observability-stack ./helm-kube-observability-stack --namespace kube-observability-stack --create-namespace
```

If you need to upgrade the chart after making changes, use this command:

```bash
helm upgrade observability-stack ./helm-kube-observability-stack --namespace kube-observability-stack
```

### Step 3: Verify Deployments and Services
Check the status of deployments:
```bash
kubectl get deployments -n kube-observability-stack
```

Check the status of services:
```bash
kubectl get services -n kube-observability-stack
```

### Step 4: Access Applications via Port Forwarding
#### Grafana
```bash
kubectl port-forward svc/grafana 3000:3000 -n kube-observability-stack
```
Access Grafana at `http://localhost:3000`.

#### Prometheus
```bash
kubectl port-forward svc/prometheus 9090:9090 -n kube-observability-stack
```
Access Prometheus at `http://localhost:9090`.

#### Loki
```bash
kubectl port-forward svc/loki 3100:3100 -n kube-observability-stack
```
Access Loki at `http://localhost:3100`.

#### Blackbox Exporter
```bash
kubectl port-forward svc/blackbox-exporter 9115:9115 -n kube-observability-stack
```
Access Blackbox Exporter at `http://localhost:9115`.

#### Promtail (If Needed)
```bash
kubectl port-forward -n kube-observability-stack svc/promtail 9080:9080
```
Access Blackbox Exporter at `http://localhost:9115`.
---

### Step : Access the Services
Once the ports are forwarded, you can access the services locally using the following URLs:

```bash
Prometheus: http://localhost:9090
Grafana: http://localhost:3000
Loki: http://localhost:3100
Promtail: http://localhost:9080
Blackbox Exporter: http://localhost:9115
```

## Adding Data Sources in Grafana

### Prometheus
1. **Access Grafana**:
   Run the following command to port-forward Grafana:
   ```bash
   kubectl port-forward svc/grafana 3000:3000 -n kube-observability-stack
   ```
   Open your browser and navigate to `http://localhost:3000`.

2. **Login to Grafana**:
   Use the default credentials:
   - Username: `admin`
   - Password: `admin` (or the value set in `values.yaml` under `grafana.adminPassword`).

3. **Add Prometheus Data Source**:
   - Go to **Configuration** > **Data Sources** > **Add Data Source**.
   - Select **Prometheus**.
   - Set the URL to `http://prometheus:9090` (internal service name and port for Prometheus in Kubernetes).
   - Click **Save & Test**.

---

### Loki
1. **Add Loki Data Source**:
   - Go to **Configuration** > **Data Sources** > **Add Data Source**.
   - Select **Loki**.
   - Set the URL to `http://loki:3100` (internal service name and port for Loki in Kubernetes).
   - Click **Save & Test**.

---

## Permanent Access Solutions

### Ingress
Use an Ingress resource for hostname-based routing:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: kube-observability-stack
spec:
  rules:
  - host: grafana.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 3000
```

### LoadBalancer
Expose services using a LoadBalancer:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: kube-observability-stack
spec:
  selector:
    app: grafana
  ports:
  - name: http
    port: 3000
    targetPort: 3000
  type: LoadBalancer
```

---

## Ports and Access

| Application   | Port  | Access Method           |
|---------------|-------|-------------------------|
| Grafana       | 3000  | Port-forward or NodePort|
| Prometheus    | 9090  | Port-forward            |
| Loki          | 3100  | Port-forward            |
| Node Exporter | 9100  | Internal ClusterIP      |
| Promtail      | 9080  | Internal ClusterIP      |
| Blackbox      | 9115  | Internal ClusterIP      |

---

## Why Helm Chart?

1. **Modularity**: Easy to update individual components.
2. **Reusability**: Can be reused across environments.
3. **Scalability**: Simplifies scaling and upgrading applications.
4. **Declarative Approach**: YAML-based configuration for easier management.

---

## Commands Summary

### Install Helm Chart
```bash
helm install observability-stack helm-kube-observability-stack --namespace kube-observability-stack
```

### Upgrade Helm Chart
```bash
helm upgrade observability-stack helm-kube-observability-stack --namespace kube-observability-stack
```

### Check Deployments
```bash
kubectl get deployments -n kube-observability-stack
```

### Check Services
```bash
kubectl get services -n kube-observability-stack
```