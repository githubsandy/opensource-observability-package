# **Technical User Design Document: Kubernetes Observability Stack**

## **Overview**
This document provides a step-by-step guide to set up a comprehensive observability stack using Kubernetes and Helm. The solution provides complete monitoring and logging capabilities for modern applications, especially test automation platforms and Kubernetes clusters.

**Components Include:**
- **Core Stack**: Prometheus, Grafana, Loki, Promtail
- **Infrastructure Exporters**: Node Exporter, Blackbox Exporter  
- **Foundation Exporters (Week 1-2)**: kube-state-metrics, MongoDB Exporter, PostgreSQL Exporter
- **Application Layer (Week 3-4)**: Custom FastAPI metrics, Jenkins Exporter, Redis Exporter

**Complete 12-Service Enterprise Observability Platform** for modern test automation and Kubernetes monitoring.

---

## **Prerequisites**
Before starting, ensure the following tools are installed and configured:
1. **kubectl**: Kubernetes command-line tool.
   - Install: [kubectl installation guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
2. **Helm**: Kubernetes package manager.
   - Install: [Helm installation guide](https://helm.sh/docs/intro/install/)
3. **Minikube** (optional): Local Kubernetes cluster for testing.
   - Install: [Minikube installation guide](https://minikube.sigs.k8s.io/docs/start/)

---

## **Directory Structure**
Here is the directory structure of the Helm chart used for the observability stack:

```
helm-kube-observability-stack/
├── charts/
├── templates/
│   ├── # Core Stack
│   ├── grafana-deployment.yaml
│   ├── grafana-service.yaml
│   ├── loki-deployment.yaml
│   ├── loki-service.yaml
│   ├── prometheus-deployment.yaml
│   ├── prometheus-service.yaml
│   ├── prometheus-config.yaml
│   ├── promtail-deployment.yaml
│   ├── promtail-service.yaml
│   ├── promtail-config.yaml
│   ├── promtail-rbac.yaml
│   ├── # Infrastructure Exporters  
│   ├── node-exporter-daemonset.yaml
│   ├── node-exporter-service.yaml
│   ├── blackbox-exporter-deployment.yaml
│   ├── blackbox-exporter-service.yaml
│   ├── blackbox-exporter-config.yaml
│   ├── # Foundation Exporters  
│   ├── kube-state-metrics-deployment.yaml
│   ├── kube-state-metrics-service.yaml
│   ├── kube-state-metrics-rbac.yaml
│   ├── mongodb-exporter-deployment.yaml
│   ├── mongodb-exporter-service.yaml
│   ├── mongodb-exporter-secret.yaml
│   ├── postgres-exporter-deployment.yaml
│   ├── postgres-exporter-service.yaml
│   ├── postgres-exporter-secret.yaml
│   ├── # Application Layer (Week 3-4)
│   ├── jenkins-exporter-deployment.yaml
│   ├── jenkins-exporter-service.yaml
│   ├── jenkins-exporter-secret.yaml
│   ├── redis-exporter-deployment.yaml
│   ├── redis-exporter-service.yaml
│   ├── redis-exporter-secret.yaml
│   ├── fastapi-metrics-deployment.yaml
│   ├── fastapi-metrics-service.yaml
│   ├── fastapi-metrics-config.yaml
│   ├── # Kubernetes Resources
│   ├── namespace.yaml
│   ├── ingress.yaml
│   ├── NOTES.txt
├── values.yaml
├── Chart.yaml
```

---
## **Architecture**

<img src="architecture.png" alt="alt text" width="400px" />


## **Purpose of Each File**

### **Deployment Files**
#### 1. **grafana-deployment.yaml**
- Deploys Grafana pods.
- Configures Grafana container image, resource limits, and environment variables.
- Exposes Grafana on port `3000`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: {{ .Values.namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: {{ .Values.grafana.image }}
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: {{ .Values.grafana.adminPassword }}
        resources:
          limits:
            cpu: {{ .Values.grafana.resources.limits.cpu }}
            memory: {{ .Values.grafana.resources.limits.memory }}
          requests:
            cpu: {{ .Values.grafana.resources.requests.cpu }}
            memory: {{ .Values.grafana.resources.requests.memory }}
```

#### 2. **loki-deployment.yaml**:
   - Deploys Loki pods.
   - Configures Loki container image and resource limits.
   - Exposes Loki on port `3100`.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.loki.replicas }}
  selector:
    matchLabels:
      app: loki
  template:
    metadata:
      labels:
        app: loki
    spec:
      containers:
      - name: loki
        image: {{ .Values.loki.image }}
        ports:
        - containerPort: 3100
          name: http
        resources:
          limits:
            cpu: {{ .Values.loki.resources.limits.cpu }}
            memory: {{ .Values.loki.resources.limits.memory }}
          requests:
            cpu: {{ .Values.loki.resources.requests.cpu }}
            memory: {{ .Values.loki.resources.requests.memory }}
```
#### 3. **prometheus-deployment.yaml**:
   - Deploys Prometheus pods.
   - Configures Prometheus container image and resource limits.
   - Exposes Prometheus on port `9090`.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.prometheus.replicas }}
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: {{ .Values.prometheus.image }}
        resources:
          limits:
            cpu: {{ .Values.prometheus.resources.limits.cpu }}
            memory: {{ .Values.prometheus.resources.limits.memory }}
          requests:
            cpu: {{ .Values.prometheus.resources.requests.cpu }}
            memory: {{ .Values.prometheus.resources.requests.memory }}
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
```
#### 4. **promtail-deployment.yaml**:
   - Deploys Promtail pods.
   - Configures Promtail container image and resource limits.
   - Mounts the Promtail configuration file.
```yaml
// filepath: /Users/skumark5/Documents/opensource-observability-package/Kubernetes Approach/helm-kube-observability-stack/templates/promtail-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: promtail
  namespace: {{ .Values.namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: promtail
  template:
    metadata:
      labels:
        app: promtail
    spec:
      containers:
      - name: promtail
        image: {{ .Values.promtail.image }}
        ports:
        - containerPort: 9080
          name: http
        resources:
          limits:
            cpu: {{ .Values.promtail.resources.limits.cpu }}
            memory: {{ .Values.promtail.resources.limits.memory }}
          requests:
            cpu: {{ .Values.promtail.resources.requests.cpu }}
            memory: {{ .Values.promtail.resources.requests.memory }}
        args:
        - -config.file=/etc/promtail/promtail-config.yaml
        volumeMounts:
        - name: promtail-config
          mountPath: /etc/promtail
      volumes:
      - name: promtail-config
        configMap:
          name: promtail-config
```
#### 5. **node-exporter-daemonset.yaml**:
   - Deploys Node Exporter as a DaemonSet to collect node-level metrics.
   - Exposes Node Exporter on port `9100`.
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: {{ .Values.namespace }}
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: {{ .Values.nodeExporter.image }}
        ports:
        - containerPort: 9100
          name: http
        resources:
          limits:
            cpu: {{ .Values.nodeExporter.resources.limits.cpu }}
            memory: {{ .Values.nodeExporter.resources.limits.memory }}
          requests:
            cpu: {{ .Values.nodeExporter.resources.requests.cpu }}
            memory: {{ .Values.nodeExporter.resources.requests.memory }}
```

#### 6. **blackbox-exporter-deployment.yaml**:
   - Deploys Blackbox Exporter pods for external endpoint monitoring.
   - Configures Blackbox Exporter container image and resource limits.
   - Mounts the Blackbox Exporter configuration file.
   - Exposes Blackbox Exporter on port `9115`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blackbox-exporter
  namespace: {{ .Values.namespace }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blackbox-exporter
  template:
    metadata:
      labels:
        app: blackbox-exporter
    spec:
      containers:
      - name: blackbox-exporter
        image: prom/blackbox-exporter:latest
        ports:
        - containerPort: 9115
          name: http
        resources:
          limits:
            cpu: {{ .Values.blackboxExporter.resources.limits.cpu }}
            memory: {{ .Values.blackboxExporter.resources.limits.memory }}
          requests:
            cpu: {{ .Values.blackboxExporter.resources.requests.cpu }}
            memory: {{ .Values.blackboxExporter.resources.requests.memory }}
        volumeMounts:
        - name: blackbox-config
          mountPath: /etc/blackbox
      volumes:
      - name: blackbox-config
        configMap:
          name: blackbox-exporter-config
```

### **Foundation Exporters  **

#### 7. **kube-state-metrics-deployment.yaml**:
   - Deploys kube-state-metrics for Kubernetes cluster health monitoring.
   - Provides comprehensive metrics about Kubernetes objects (pods, deployments, services, etc.).
   - Essential for monitoring test automation infrastructure.
   - Exposes metrics on port `8080`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kube-state-metrics
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.kubeStateMetrics.replicas }}
  selector:
    matchLabels:
      app: kube-state-metrics
  template:
    metadata:
      labels:
        app: kube-state-metrics
    spec:
      serviceAccount: kube-state-metrics
      containers:
      - name: kube-state-metrics
        image: {{ .Values.kubeStateMetrics.image }}
        ports:
        - containerPort: 8080
          name: http-metrics
        - containerPort: 8081
          name: telemetry
        resources:
          limits:
            cpu: {{ .Values.kubeStateMetrics.resources.limits.cpu }}
            memory: {{ .Values.kubeStateMetrics.resources.limits.memory }}
          requests:
            cpu: {{ .Values.kubeStateMetrics.resources.requests.cpu }}
            memory: {{ .Values.kubeStateMetrics.resources.requests.memory }}
```

#### 8. **mongodb-exporter-deployment.yaml**:
   - Deploys MongoDB Exporter for NoSQL database monitoring.
   - Critical for monitoring test results and metadata storage.
   - Tracks database performance, connections, and operations.
   - Exposes metrics on port `9216`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb-exporter
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.mongodbExporter.replicas }}
  selector:
    matchLabels:
      app: mongodb-exporter
  template:
    metadata:
      labels:
        app: mongodb-exporter
    spec:
      containers:
      - name: mongodb-exporter
        image: {{ .Values.mongodbExporter.image }}
        ports:
        - containerPort: 9216
          name: http-metrics
        env:
        - name: MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: mongodb-exporter-secret
              key: mongodb-uri
        resources:
          limits:
            cpu: {{ .Values.mongodbExporter.resources.limits.cpu }}
            memory: {{ .Values.mongodbExporter.resources.limits.memory }}
          requests:
            cpu: {{ .Values.mongodbExporter.resources.requests.cpu }}
            memory: {{ .Values.mongodbExporter.resources.requests.memory }}
```

#### 9. **postgres-exporter-deployment.yaml**:
   - Deploys PostgreSQL Exporter for relational database monitoring.
   - Essential for monitoring user management and relational data.
   - Tracks database connections, query performance, and health.
   - Exposes metrics on port `9187`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-exporter
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.postgresExporter.replicas }}
  selector:
    matchLabels:
      app: postgres-exporter
  template:
    metadata:
      labels:
        app: postgres-exporter
    spec:
      containers:
      - name: postgres-exporter
        image: {{ .Values.postgresExporter.image }}
        ports:
        - containerPort: 9187
          name: http-metrics
        env:
        - name: DATA_SOURCE_NAME
          valueFrom:
            secretKeyRef:
              name: postgres-exporter-secret
              key: data-source-name
        resources:
          limits:
            cpu: {{ .Values.postgresExporter.resources.limits.cpu }}
            memory: {{ .Values.postgresExporter.resources.limits.memory }}
          requests:
            cpu: {{ .Values.postgresExporter.resources.requests.cpu }}
            memory: {{ .Values.postgresExporter.resources.requests.memory }}
```

### **Application Layer Exporters (Week 3-4)**

#### 10. **jenkins-exporter-deployment.yaml**:
   - Deploys Jenkins Exporter for CI/CD pipeline monitoring.
   - Critical for monitoring test automation pipeline health and build success rates.
   - Tracks build durations, queue sizes, and job success/failure metrics.
   - Exposes metrics on port `9118`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-exporter
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.jenkinsExporter.replicas }}
  selector:
    matchLabels:
      app: jenkins-exporter
  template:
    metadata:
      labels:
        app: jenkins-exporter
    spec:
      containers:
      - name: jenkins-exporter
        image: {{ .Values.jenkinsExporter.image }}
        ports:
        - containerPort: 9118
          name: http-metrics
        env:
        - name: JENKINS_SERVER
          valueFrom:
            secretKeyRef:
              name: jenkins-exporter-secret
              key: jenkins-server
        - name: JENKINS_USERNAME
          valueFrom:
            secretKeyRef:
              name: jenkins-exporter-secret
              key: jenkins-username
        - name: JENKINS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: jenkins-exporter-secret
              key: jenkins-password
        resources:
          limits:
            cpu: {{ .Values.jenkinsExporter.resources.limits.cpu }}
            memory: {{ .Values.jenkinsExporter.resources.limits.memory }}
          requests:
            cpu: {{ .Values.jenkinsExporter.resources.requests.cpu }}
            memory: {{ .Values.jenkinsExporter.resources.requests.memory }}
```

#### 11. **redis-exporter-deployment.yaml**:
   - Deploys Redis Exporter for cache and session monitoring.
   - Essential for monitoring test session caching and task queue performance.
   - Tracks Redis connection counts, memory usage, and operations per second.
   - Exposes metrics on port `9121`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-exporter
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.redisExporter.replicas }}
  selector:
    matchLabels:
      app: redis-exporter
  template:
    metadata:
      labels:
        app: redis-exporter
    spec:
      containers:
      - name: redis-exporter
        image: {{ .Values.redisExporter.image }}
        ports:
        - containerPort: 9121
          name: http-metrics
        env:
        - name: REDIS_ADDR
          valueFrom:
            secretKeyRef:
              name: redis-exporter-secret
              key: redis-addr
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: redis-exporter-secret
              key: redis-password
              optional: true
        resources:
          limits:
            cpu: {{ .Values.redisExporter.resources.limits.cpu }}
            memory: {{ .Values.redisExporter.resources.limits.memory }}
          requests:
            cpu: {{ .Values.redisExporter.resources.requests.cpu }}
            memory: {{ .Values.redisExporter.resources.requests.memory }}
```

#### 12. **fastapi-metrics-deployment.yaml**:
   - Deploys custom FastAPI application with comprehensive test automation metrics.
   - Provides business logic monitoring for CXTAF/CXTM frameworks.
   - Includes sample metrics for test execution, device connections, and workflow management.
   - Exposes application on port `8000` and metrics on port `8001`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-metrics
  namespace: {{ .Values.namespace }}
spec:
  replicas: {{ .Values.fastApiMetrics.replicas }}
  selector:
    matchLabels:
      app: fastapi-metrics
  template:
    metadata:
      labels:
        app: fastapi-metrics
    spec:
      containers:
      - name: fastapi-metrics
        image: {{ .Values.fastApiMetrics.image }}
        ports:
        - containerPort: 8000
          name: http-app
        - containerPort: 8001
          name: http-metrics
        env:
        - name: METRICS_PORT
          value: "8001"
        - name: APP_PORT
          value: "8000"
        - name: LOG_LEVEL
          value: {{ .Values.fastApiMetrics.logLevel | quote }}
        resources:
          limits:
            cpu: {{ .Values.fastApiMetrics.resources.limits.cpu }}
            memory: {{ .Values.fastApiMetrics.resources.limits.memory }}
          requests:
            cpu: {{ .Values.fastApiMetrics.resources.requests.cpu }}
            memory: {{ .Values.fastApiMetrics.resources.requests.memory }}
```
---

### **Service Files**
#### 1. **grafana-service.yaml**:
   - Exposes Grafana internally via `ClusterIP` or externally via `NodePort`.
   - Port: `3000`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: {{ .Values.namespace }}
spec:
  selector:
    app: grafana
  ports:
    - name: http
      port: 3000
      targetPort: 3000
  type: ClusterIP
```
#### 2. **loki-service.yaml**:
   - Exposes Loki internally via `ClusterIP`.
   - Port: `3100`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: loki
  namespace: {{ .Values.namespace }}
spec:
  selector:
    app: loki
  ports:
    - name: http
      port: 3100
      targetPort: 3100
  type: ClusterIP
```
#### 3. **prometheus-service.yaml**:
   - Exposes Prometheus internally via `ClusterIP`.
   - Port: `9090`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: {{ .Values.namespace }}
spec:
  selector:
    app: prometheus
  ports:
    - name: http
      port: 9090
      targetPort: 9090
  type: ClusterIP
```
#### 4. **promtail-service.yaml**:
   - Exposes Promtail internally via `ClusterIP`.
   - Port: `9080`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: promtail
  namespace: {{ .Values.namespace }}
spec:
  selector:
    app: promtail
  ports:
    - name: http
      port: 9080
      targetPort: 9080
  type: ClusterIP
```
#### 5. **node-exporter-service.yaml**:
   - Exposes Node Exporter internally via `ClusterIP`.
   - Port: `9100`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: {{ .Values.namespace }}
spec:
  selector:
    app: node-exporter
  ports:
    - name: http
      port: 9100
      targetPort: 9100
  type: ClusterIP
```
#### 6. **blackbox-exporter-service.yaml**:
   - Exposes Blackbox Exporter internally via `ClusterIP`.
   - Port: `9115`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: blackbox-exporter
  namespace: {{ .Values.namespace }}
spec:
  selector:
    app: blackbox-exporter
  ports:
    - name: http
      port: 9115
      targetPort: 9115
  type: ClusterIP
```

### **Foundation Exporter Services**

#### 7. **kube-state-metrics-service.yaml**:
   - Exposes kube-state-metrics internally via `ClusterIP`.
   - Ports: `8080` (metrics), `8081` (telemetry).
```yaml
apiVersion: v1
kind: Service
metadata:
  name: kube-state-metrics
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.kubeStateMetrics.service.type }}
  ports:
  - name: http-metrics
    port: {{ .Values.kubeStateMetrics.service.port }}
    targetPort: 8080
    protocol: TCP
  - name: telemetry
    port: 8081
    targetPort: 8081
    protocol: TCP
  selector:
    app: kube-state-metrics
```

#### 8. **mongodb-exporter-service.yaml**:
   - Exposes MongoDB Exporter internally via `ClusterIP`.
   - Port: `9216`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongodb-exporter
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.mongodbExporter.service.type }}
  ports:
  - name: http-metrics
    port: {{ .Values.mongodbExporter.service.port }}
    targetPort: 9216
    protocol: TCP
  selector:
    app: mongodb-exporter
```

#### 9. **postgres-exporter-service.yaml**:
   - Exposes PostgreSQL Exporter internally via `ClusterIP`.
   - Port: `9187`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-exporter
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.postgresExporter.service.type }}
  ports:
  - name: http-metrics
    port: {{ .Values.postgresExporter.service.port }}
    targetPort: 9187
    protocol: TCP
  selector:
    app: postgres-exporter
```

### **Application Layer Exporter Services (Week 3-4)**

#### 10. **jenkins-exporter-service.yaml**:
   - Exposes Jenkins Exporter internally via `ClusterIP`.
   - Port: `9118`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: jenkins-exporter
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.jenkinsExporter.service.type }}
  ports:
  - name: http-metrics
    port: {{ .Values.jenkinsExporter.service.port }}
    targetPort: 9118
    protocol: TCP
  selector:
    app: jenkins-exporter
```

#### 11. **redis-exporter-service.yaml**:
   - Exposes Redis Exporter internally via `ClusterIP`.
   - Port: `9121`.
```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-exporter
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.redisExporter.service.type }}
  ports:
  - name: http-metrics
    port: {{ .Values.redisExporter.service.port }}
    targetPort: 9121
    protocol: TCP
  selector:
    app: redis-exporter
```

#### 12. **fastapi-metrics-service.yaml**:
   - Exposes FastAPI Metrics application and metrics endpoints.
   - Ports: `8000` (application), `8001` (metrics).
```yaml
apiVersion: v1
kind: Service
metadata:
  name: fastapi-metrics
  namespace: {{ .Values.namespace }}
spec:
  type: {{ .Values.fastApiMetrics.service.type }}
  ports:
  - name: http-app
    port: {{ .Values.fastApiMetrics.service.appPort }}
    targetPort: 8000
    protocol: TCP
  - name: http-metrics
    port: {{ .Values.fastApiMetrics.service.metricsPort }}
    targetPort: 8001
    protocol: TCP
  selector:
    app: fastapi-metrics
```
---

### **Configuration Files**
#### 1. **promtail-config.yaml**:
   - Defines Promtail scrape targets and labels.
   - Configures Promtail to send logs to Loki.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: promtail-config
  namespace: {{ .Values.namespace }}
data:
  promtail-config.yaml: |
    server:
      http_listen_port: 9080
    clients:
      - url: http://loki:3100/loki/api/v1/push
    scrape_configs:
      - job_name: "varlogs"
        static_configs:
          - targets:
              - localhost
            labels:
              job: "varlogs"
              __path__: /var/log/*log
```
#### 2. **blackbox-exporter-config.yaml**:
   - Defines Blackbox Exporter modules for probing endpoints.
   - Configures HTTP probing with the http_2xx module.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: blackbox-exporter-config
  namespace: {{ .Values.namespace }}
data:
  blackbox.yml: |
    modules:
      http_2xx:
        prober: http
        timeout: 5s
        http:
          method: GET
          valid_http_versions: ["HTTP/1.1", "HTTP/2"]
          fail_if_ssl: false
          fail_if_not_ssl: false
          valid_status_codes: []
```
#### 2. **prometheus-config.yaml**:
   - Configures Prometheus to scrape metrics from all exporters.
   - Defines scrape jobs for core services, infrastructure, and foundation exporters.
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: {{ .Values.namespace }}
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      # Default Prometheus scrape job
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      # Blackbox Exporter scrape job
      - job_name: 'blackbox'
        metrics_path: /probe
        params:
          module: [http_2xx]
        static_configs:
          - targets:
              - https://www.google.com
              - https://www.github.com
              - https://www.example.com
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: blackbox-exporter:9115

      # kube-state-metrics scrape job
      - job_name: 'kube-state-metrics'
        static_configs:
          - targets: ['kube-state-metrics:8080']
        scrape_interval: 30s
        scrape_timeout: 10s

      # MongoDB Exporter scrape job  
      - job_name: 'mongodb-exporter'
        static_configs:
          - targets: ['mongodb-exporter:9216']
        scrape_interval: 30s
        scrape_timeout: 10s

      # PostgreSQL Exporter scrape job
      - job_name: 'postgres-exporter' 
        static_configs:
          - targets: ['postgres-exporter:9187']
        scrape_interval: 30s
        scrape_timeout: 10s

      # Node Exporter scrape job
      - job_name: 'node-exporter'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_endpoints_name]
            regex: 'node-exporter'
            action: keep

      # Application Layer Exporters (Week 3-4)
      # Jenkins Exporter scrape job
      - job_name: 'jenkins-exporter'
        static_configs:
          - targets: ['jenkins-exporter:9118']
        scrape_interval: 30s
        scrape_timeout: 10s

      # Redis Exporter scrape job  
      - job_name: 'redis-exporter'
        static_configs:
          - targets: ['redis-exporter:9121']
        scrape_interval: 30s
        scrape_timeout: 10s

      # FastAPI Metrics scrape job
      - job_name: 'fastapi-metrics'
        static_configs:
          - targets: ['fastapi-metrics:8001']
        scrape_interval: 15s
        scrape_timeout: 5s
```
####  2. **values.yaml**:
   - Centralized configuration for the Helm chart.
   - Defines replicas, resource limits, container images, and other parameters.

```yaml
## Existring code ...

#*************************************************************
# Observability stack-specific configurations
#*************************************************************

namespace: kube-observability-stack

prometheus:
  image: prom/prometheus:v2.45.0
  replicas: 1
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

nodeExporter:
  image: prom/node-exporter:v1.6.1
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi

loki:
  image: grafana/loki:2.9.7
  replicas: 1
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi

promtail:
  image: grafana/promtail:2.9.7
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi

grafana:
  image: grafana/grafana:10.0.3
  adminPassword: admin
  resources:
    limits:
      cpu: 500m
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
blackboxExporter:
  resources:
    limits:
      cpu: "500m"
      memory: "128Mi"
    requests:
      cpu: "250m"
      memory: "64Mi"

# Foundation Exporters Configuration
kubeStateMetrics:
  image: registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.10.1
  replicas: 1
  resources:
    limits:
      cpu: 250m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
  service:
    type: ClusterIP
    port: 8080

mongodbExporter:
  image: percona/mongodb_exporter:0.40.0
  replicas: 1
  mongodbUri: "mongodb://username:password@mongodb-host:27017"  # Change to your MongoDB URI
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi
  service:
    type: ClusterIP
    port: 9216

postgresExporter:
  image: prometheuscommunity/postgres-exporter:v0.15.0
  replicas: 1
  dataSourceName: "postgresql://username:password@postgres-host:5432/dbname?sslmode=disable"  # Change to your PostgreSQL connection string
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi
  service:
    type: ClusterIP
    port: 9187

# Application Layer Exporters Configuration (Week 3-4)
jenkinsExporter:
  image: lovoo/jenkins_exporter:latest
  replicas: 1
  jenkinsServer: "http://your-jenkins-host:8080"  # Change to your Jenkins URL
  jenkinsUsername: "your-jenkins-username"        # Change to your Jenkins username
  jenkinsPassword: "your-jenkins-password"        # Change to your Jenkins password/token
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi
  service:
    type: ClusterIP
    port: 9118

redisExporter:
  image: oliver006/redis_exporter:latest
  replicas: 1
  redisAddr: "redis://your-redis-host:6379"       # Change to your Redis address
  redisPassword: ""                                # Add Redis password if required
  resources:
    limits:
      cpu: 200m
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 64Mi
  service:
    type: ClusterIP
    port: 9121

fastApiMetrics:
  image: python:3.11-slim                         # Custom FastAPI app with metrics
  replicas: 1
  logLevel: "INFO"
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 250m
      memory: 128Mi
  service:
    type: ClusterIP
    appPort: 8000
    metricsPort: 8001
```
---

### **Other Files**
#### 1. **namespace.yaml**:
   - Creates a dedicated namespace for the observability stack.
```yaml
# filepath: namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kube-observability-stack
```
#### 2. **ingress.yaml**:
   - Configures ingress rules for external access (optional).
```yaml
Keep it as it is
```
#### 3. **Chart.yaml**:
   - Metadata for the Helm chart (name, version, description).
```yaml
Keep it as it is
```
####  4. **NOTES.txt**:
   - Provides post-installation instructions.
```yaml
Keep it as it is
```
---

## **Steps to Build the Solution**

### **Step 1: Create Namespace**
Apply the namespace file:
```bash
kubectl apply -f templates/namespace.yaml
```

---

### **Step 2: Deploy the Helm Chart**
Install the Helm chart:
```bash
cd --> same directory as helm
helm install observability-stack helm-kube-observability-stack --namespace kube-observability-stack

# Once you modify anything then 
helm upgrade observability-stack helm-kube-observability-stack --namespace kube-observability-stack

```


---

### **Step 3: Verify Deployments and Services**
Check the status of deployments:
```bash
kubectl get deployments -n kube-observability-stack
```

Check the status of services:
```bash
kubectl get services -n kube-observability-stack
```

---

### **Step 4: Port forwarding & Access Applications**
Port forwarding is used to temporarily expose a Kubernetes service running inside the cluster to your local machine. This allows you to access applications like Grafana, Prometheus, and Loki through your web browser or other tools without needing external access or ingress configurations.

Kubernetes services (like Grafana, Prometheus, Loki) are typically accessible only within the cluster.
Port forwarding creates a tunnel between your local machine and the Kubernetes service, mapping the service's port to your local machine's port.
This lets you access the service using ttp://localhost:<local-port>.

#### **Grafana**
1. Port-forward Grafana:
   ```bash
   kubectl port-forward svc/grafana 3000:3000 -n kube-observability-stack
   ```
2. Access Grafana at `http://localhost:3000`.

#### **Prometheus**
1. Port-forward Prometheus:
   ```bash
   kubectl port-forward svc/prometheus 9090:9090 -n kube-observability-stack
   ```
2. Access Prometheus at `http://localhost:9090`.

#### **Loki**
1. Port-forward Loki:
   ```bash
   kubectl port-forward svc/loki 3100:3100 -n kube-observability-stack
   ```
2. Access Loki at `http://localhost:3100`.

#### **Blackbox**
1. Port-forward Loki:
   ```bash
   kubectl port-forward svc/blackbox-exporter 9115:9115 -n kube-observability-stack
   ```
2. Access Loki at `http://localhost:9115`.

---

### **Step 4.1: Automated Multi Port Forwarding Solution**

Instead of running multiple individual port forwarding commands, you can use automated scripts for easier management of all observability services.

#### **Multi Port Forwarding Script (`start-observability.sh`)**

This script automatically starts port forwarding for all observability services in the background, allowing you to access all services without keeping multiple terminal sessions open.

**Script Content:**
```bash
#!/bin/bash
echo "🚀 Starting Comprehensive Observability Stack..."
echo "=============================================="
echo
echo "📊 Core Services:"
echo "   • Grafana: http://localhost:3000"
echo "   • Prometheus: http://localhost:9090"
echo "   • Loki: http://localhost:3100"
echo
echo "🔍 Infrastructure Exporters:"
echo "   • Blackbox Exporter: http://localhost:9115"
echo "   • Node Exporter: http://localhost:9100"
echo "   • Promtail: http://localhost:9080"
echo
echo "⚡ Foundation Exporters  :"
echo "   • kube-state-metrics: http://localhost:8080"
echo "   • MongoDB Exporter: http://localhost:9216"
echo "   • PostgreSQL Exporter: http://localhost:9187"
echo
echo "Press Ctrl+C to stop all services"
echo "=============================================="

# Start Core Services
echo "Starting core services..."
kubectl port-forward svc/grafana 3000:3000 -n kube-observability-stack &
PID1=$!

kubectl port-forward svc/prometheus 9090:9090 -n kube-observability-stack &
PID2=$!

kubectl port-forward svc/loki 3100:3100 -n kube-observability-stack &
PID3=$!

# Start Infrastructure Exporters
echo "Starting infrastructure exporters..."
kubectl port-forward svc/blackbox-exporter 9115:9115 -n kube-observability-stack &
PID4=$!

kubectl port-forward svc/node-exporter 9100:9100 -n kube-observability-stack &
PID5=$!

kubectl port-forward svc/promtail 9080:9080 -n kube-observability-stack &
PID6=$!

# Start Foundation Exporters
echo "Starting foundation exporters..."
kubectl port-forward svc/kube-state-metrics 8080:8080 -n kube-observability-stack &
PID7=$!

kubectl port-forward svc/mongodb-exporter 9216:9216 -n kube-observability-stack &
PID8=$!

kubectl port-forward svc/postgres-exporter 9187:9187 -n kube-observability-stack &
PID9=$!

# Start Application Layer Exporters
echo "Starting application layer exporters..."
kubectl port-forward svc/jenkins-exporter 9118:9118 -n kube-observability-stack &
PID10=$!

kubectl port-forward svc/redis-exporter 9121:9121 -n kube-observability-stack &
PID11=$!

kubectl port-forward svc/fastapi-metrics 8001:8001 -n kube-observability-stack &
PID12=$!

echo "✅ All services started! Use ./check-services.sh to verify status"

# Wait for interrupt
trap "echo 'Stopping all services...'; kill $PID1 $PID2 $PID3 $PID4 $PID5 $PID6 $PID7 $PID8 $PID9 $PID10 $PID11 $PID12; exit" INT
wait
```

**Usage:**
```bash
# Make script executable
chmod +x start-observability.sh

# Run the script
./start-observability.sh
```

**Key Features:**
- Starts all services simultaneously in background processes
- Provides clear URLs for each service
- Gracefully handles script termination (Ctrl+C kills all port forwards)
- No need to keep terminal session open - processes run in background

#### **Service Health Check Script (`check-services.sh`)**

This script checks the health status of all observability services and provides quick access links.

**Script Content:**
```bash
#!/bin/bash
echo "🔍 Checking Observability Services Status"
echo "=========================================="
echo

# Function to check service
check_service() {
    local name=$1
    local url=$2
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    if [ "$response" = "200" ] || [ "$response" = "302" ] || [ "$response" = "405" ]; then
        echo "✅ $name: Running (http://localhost:${url##*:})"
    else
        echo "❌ $name: Not accessible"
    fi
}

# Check Core Observability Services
echo "🔹 Core Observability Services:"
check_service "Grafana        " "http://localhost:3000"
check_service "Prometheus     " "http://localhost:9090"
check_service "Loki           " "http://localhost:3100/metrics"

echo
echo "🔹 Infrastructure Exporters:"
check_service "Blackbox Export" "http://localhost:9115"
check_service "Node Exporter  " "http://localhost:9100"
check_service "Promtail       " "http://localhost:9080"

echo
echo "🔹 Foundation Exporters (Week 1-2):"
check_service "kube-state-metrics" "http://localhost:8080"
check_service "MongoDB Exporter  " "http://localhost:9216"
check_service "PostgreSQL Exporter" "http://localhost:9187"

echo
echo "🔹 Application Layer Exporters (Week 3-4):"
check_service "Jenkins Exporter  " "http://localhost:9118"
check_service "Redis Exporter    " "http://localhost:9121"
check_service "FastAPI Metrics   " "http://localhost:8001"

echo
echo "📋 Default Credentials:"
echo "   Grafana: admin/admin"
echo
echo "🔗 Quick Links:"
echo "   • Grafana Dashboard: http://localhost:3000"
echo "   • Prometheus Targets: http://localhost:9090/targets"
echo "   • Prometheus Graph: http://localhost:9090/graph"
echo "   • Loki Labels: http://localhost:3100/loki/api/v1/labels"
echo "   • Blackbox Metrics: http://localhost:9115/metrics"
echo "   • Kubernetes Metrics: http://localhost:8080/metrics"
echo "   • Node Metrics: http://localhost:9100/metrics"
echo "   • Promtail Metrics: http://localhost:9080/metrics"
echo "   • Jenkins Metrics: http://localhost:9118/metrics"
echo "   • Redis Metrics: http://localhost:9121/metrics"
echo "   • FastAPI Metrics: http://localhost:8001/metrics"
echo "   • FastAPI App: http://localhost:8000"
```

**Usage:**
```bash
# Make script executable
chmod +x check-services.sh

# Run the health check
./check-services.sh
```

**Sample Output:**
```
🔍 Checking Observability Services Status
==========================================

🔹 Core Observability Services:
✅ Grafana        : Running (http://localhost:3000)
✅ Prometheus     : Running (http://localhost:9090)
✅ Loki           : Running (http://localhost:3100/metrics)

🔹 Infrastructure Exporters:
✅ Blackbox Export: Running (http://localhost:9115)
✅ Node Exporter  : Running (http://localhost:9100)
✅ Promtail       : Running (http://localhost:9080)

🔹 Foundation Exporters  :
✅ kube-state-metrics: Running (http://localhost:8080)
✅ MongoDB Exporter  : Running (http://localhost:9216)
✅ PostgreSQL Exporter: Running (http://localhost:9187)

📋 Default Credentials:
   Grafana: admin/admin

🔗 Quick Links:
   • Grafana Dashboard: http://localhost:3000
   • Prometheus Targets: http://localhost:9090/targets
   • Prometheus Graph: http://localhost:9090/graph
   • Loki Labels: http://localhost:3100/loki/api/v1/labels
   • Blackbox Metrics: http://localhost:9115/metrics
   • Kubernetes Metrics: http://localhost:8080/metrics
   • Node Metrics: http://localhost:9100/metrics
   • Promtail Metrics: http://localhost:9080/metrics
```

#### **Advantages of Automated Scripts**

| **Aspect** | **Manual Port Forwarding** | **Automated Scripts** |
|------------|----------------------------|----------------------|
| **Setup Time** | Multiple commands, multiple terminals | Single command execution |
| **Management** | Need to track multiple processes | Centralized process management |
| **Status Checking** | Manual testing of each service | Automated health checks with visual status |
| **Termination** | Kill processes individually | Graceful shutdown of all services |
| **User Experience** | Complex, error-prone | Simple, user-friendly |
| **Documentation** | Need to remember multiple URLs | Built-in quick links and credentials |

#### **Best Practices for Script Usage**

1. **Starting Services:**
   ```bash
   # Always check cluster status first
   minikube status
   
   # Start all services
   ./start-observability.sh
   ```

2. **Health Monitoring:**
   ```bash
   # Run periodic health checks
   ./check-services.sh
   
   # Or run continuously
   watch -n 30 ./check-services.sh
   ```

3. **Stopping Services:**
   ```bash
   # If using start-observability.sh interactively
   # Press Ctrl+C to stop all services gracefully
   
   # Or kill all port forwards manually
   pkill -f "kubectl port-forward"
   ```

4. **Troubleshooting:**
   ```bash
   # Check running port forwards
   ps aux | grep "kubectl port-forward"
   
   # Check pod status
   kubectl get pods -n kube-observability-stack
   
   # Run health check
   ./check-services.sh
   ```

---

### **Step 4: Port forwarding replacement | Permanent solution **
If port forwarding is temporary, the permanent solution for exposing Kubernetes services to external users is to use Ingress or LoadBalancer service types. These methods provide stable and permanent access to services running inside the cluster.

## Permanent Solutions
#### Ingress
What It Does:
Ingress is a Kubernetes resource that manages external access to services in a cluster.
It provides HTTP and HTTPS routing based on hostnames and paths.
How It Works:
You define rules in an Ingress resource to route traffic to specific services.
Requires an Ingress Controller (e.g., NGINX, Traefik) to handle the routing.
Example:

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
```bash
Access Grafana at http://grafana.example.com.
```

#### LoadBalancer Service
What It Does:
A LoadBalancer service exposes the application to the internet by provisioning a cloud provider's load balancer.
Commonly used in cloud environments (e.g., AWS, Azure, GCP).
How It Works:
Kubernetes automatically provisions a load balancer and assigns an external IP to the service.
Example:

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

#### NodePort Service
What It Does:
Exposes the service on a specific port of each node in the cluster.
Accessible via <node-ip>:<node-port>.
How It Works:
The service is mapped to a port on the node, and traffic is routed to the pods.
Example:

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
    nodePort: 32000
  type: NodePort
```

```bash
Access Grafana at http://<node-ip>:32000.
```

## Comparison of Methods
### **Comparison of Methods**

| **Method**      | **Use Case**                    | **Pros**                                 | **Cons**                              |
|-----------------|----------------------------------|-------------------------------------------|----------------------------------------|
| Ingress         | HTTP/HTTPS routing              | Flexible routing, hostname-based          | Requires Ingress Controller            |
| LoadBalancer    | Cloud environments              | External IP, easy setup                   | Cloud provider dependency              |
| NodePort        | Local testing or small clusters | Simple setup                              | Limited scalability, manual IP use     |

### Recommendation
- Use Ingress for production environments where you need hostname-based routing and HTTPS support.
- Use LoadBalancer in cloud environments for direct external access.
- Use NodePort for testing or small-scale setups.




### **Step 5: Configure Foundation Exporters (Week 1-2)**

Before using the MongoDB and PostgreSQL exporters, configure their database connections in `values.yaml`:

#### **MongoDB Configuration**
```yaml
mongodbExporter:
  mongodbUri: "mongodb://your-username:your-password@your-mongodb-host:27017/admin"
```

#### **PostgreSQL Configuration**  
```yaml
postgresExporter:
  dataSourceName: "postgresql://your-username:your-password@your-postgres-host:5432/your-database?sslmode=disable"
```

#### **Update and Redeploy**
```bash
# Update the configuration
helm upgrade observability-stack ./helm-kube-observability-stack --namespace kube-observability-stack
```

### **Step 6: Configure Application Layer Exporters (Week 3-4)**

Before using the Application Layer exporters, configure their connections in `values.yaml`:

#### **Jenkins Exporter Configuration**
```yaml
jenkinsExporter:
  jenkinsServer: "http://your-jenkins-host:8080"
  jenkinsUsername: "your-jenkins-username"  
  jenkinsPassword: "your-jenkins-password"  # Use API token for security
```

#### **Redis Exporter Configuration**
```yaml
redisExporter:
  redisAddr: "redis://your-redis-host:6379"
  redisPassword: ""  # Add Redis password if required
```

#### **FastAPI Metrics Configuration**
The FastAPI metrics service provides sample test automation metrics. You can customize the application by modifying the ConfigMap in `fastapi-metrics-config.yaml`. The sample includes:

- **Test execution metrics** (CXTAF/CXTM frameworks)
- **API performance monitoring**
- **Device connection tracking** 
- **Workflow management metrics**

```yaml
fastApiMetrics:
  image: python:3.11-slim
  logLevel: "INFO"
```

#### **Update and Redeploy**
```bash
# Update the configuration
helm upgrade observability-stack ./helm-kube-observability-stack --namespace kube-observability-stack
```

### **Step 7: Query Data in Grafana**

#### **Logs (Loki)**
1. Add Loki as a data source in Grafana.
2. Use queries like:
   - `{job="varlogs"}` - All container logs
   - `{job="varlogs"} |= "error"` - Error logs only
   - `{namespace="kube-observability-stack"}` - Logs from observability namespace

#### **Metrics (Prometheus)**  
1. Add Prometheus as a data source in Grafana.
2. **Core Infrastructure Queries**:
   - `up` - Service availability
   - `probe_success{job="blackbox"}` - External endpoint health
   - `kube_pod_status_phase` - Pod status across cluster
   - `mongodb_up` - MongoDB connection status
   - `pg_up` - PostgreSQL connection status

3. **Kubernetes Health Queries**:
   - `kube_deployment_status_replicas` - Deployment replica status
   - `kube_node_status_condition` - Node health status
   - `kube_pod_container_status_restarts_total` - Container restart rates

4. **Application Layer Queries (Week 3-4)**:
   **CI/CD Pipeline Metrics (Jenkins)**:
   - `jenkins_job_success_percentage` - Build success rates
   - `jenkins_queue_size` - Build queue backlogs
   - `jenkins_job_duration_milliseconds` - Pipeline execution times
   - `jenkins_builds_duration_milliseconds_summary` - Build duration summary

   **Cache & Session Metrics (Redis)**:
   - `redis_connected_clients` - Active Redis connections
   - `redis_memory_used_bytes` - Memory usage
   - `redis_commands_processed_total` - Commands processed per second
   - `redis_up` - Redis connection status

   **Test Automation Metrics (FastAPI)**:
   - `test_executions_total{framework="cxtaf"}` - CXTAF test executions
   - `test_executions_total{framework="cxtm"}` - CXTM test executions
   - `cxtaf_device_connections_active` - Active device connections
   - `cxtm_workflows_active` - Active test workflows
   - `active_test_sessions_total` - Concurrent test capacity
   - `fastapi_request_duration_seconds` - API response times
   - `test_execution_duration_seconds` - Test execution duration

---

## **Why Helm Chart Over Bash Scripts?**
1. **Modularity**:
   - Helm charts allow modular configuration and deployment.
   - Easy to update individual components.

2. **Reusability**:
   - Helm charts can be reused across environments (e.g., dev, prod).

3. **Scalability**:
   - Helm simplifies scaling and upgrading applications.

4. **Declarative Approach**:
   - Helm uses YAML files for declarative configuration, making it easier to manage.

---

## **Ports and Access**

### **Core Observability Services**
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| Grafana       | 3000  | Port-forward or NodePort| Visualization & Dashboards |
| Prometheus    | 9090  | Port-forward            | Metrics Collection & Query |
| Loki          | 3100  | Port-forward            | Log Aggregation |

### **Infrastructure Exporters**  
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| Node Exporter | 9100  | Port-forward / Internal | System Metrics (CPU, Memory, Disk) |
| Promtail      | 9080  | Port-forward / Internal | Log Collection Agent |
| Blackbox      | 9115  | Port-forward / Internal | External Endpoint Monitoring |

### **Foundation Exporters (Week 1-2)**
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| kube-state-metrics | 8080  | Port-forward / Internal | Kubernetes Cluster Health |
| MongoDB Exporter   | 9216  | Port-forward / Internal | NoSQL Database Metrics |
| PostgreSQL Exporter| 9187  | Port-forward / Internal | Relational Database Metrics |

### **Application Layer Exporters (Week 3-4)**
| Application   | Port  | Access Method           | Description |
|---------------|-------|-------------------------|-------------|
| Jenkins Exporter   | 9118  | Port-forward / Internal | CI/CD Pipeline Monitoring |
| Redis Exporter     | 9121  | Port-forward / Internal | Cache & Session Metrics |
| FastAPI Metrics    | 8001  | Port-forward / Internal | Test Automation Application Metrics |
| FastAPI App        | 8000  | Port-forward / Internal | FastAPI Application Interface |

---

## **Commands Summary**
### **Install Helm Chart that you have created**
```bash
helm install observability-stack helm-kube-observability-stack --namespace kube-observability-stack
```

### **Upgrade Helm Chart**
```bash
helm upgrade observability-stack helm-kube-observability-stack --namespace kube-observability-stack
```

### **Check Deployments**
```bash
kubectl get deployments -n kube-observability-stack
```

### **Check Services**
```bash
kubectl get services -n kube-observability-stack
```

### **Multi Port Forwarding (Automated)**
```bash
# Start all observability services
./start-observability.sh

# Check service health status
./check-services.sh

# Kill all port forwards
pkill -f "kubectl port-forward"
```

---