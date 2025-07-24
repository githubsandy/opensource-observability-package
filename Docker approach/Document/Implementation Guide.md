# Docker Approach for Open Source Observability Package

This guide will help you set up and run a full open-source observability stack (Prometheus, Node Exporter, Loki, Grafana) using Docker and Docker Compose. It covers what Docker is, why to use it, who it’s for, where to run it, prerequisites, and step-by-step instructions for setup.

---

## 1. Prerequisites

- **Operating System:** Windows, Mac, or Linux
- **Docker:** [Install Docker](https://docs.docker.com/get-docker/)
- **Docker Compose:** Included with Docker Desktop (Mac/Windows) or as a plugin on Linux
- **Ports:** Ensure ports 9090, 9100, 3100, and 3000 are available on your machine

**Check installation:**
```bash
docker --version
docker compose version
```

---

## 2. Coding Instructions

When generating or modifying code for this project, please follow the user-provided coding instructions.  
These instructions are important for ensuring that the code is modified or created correctly.

---

## 3. What is Docker?

Docker is a platform that lets you package applications and their dependencies into containers.  
- **Containers** are lightweight, portable, and consistent across environments.
- **Docker Compose** lets you define and run multi-container applications using a simple YAML file.

---

## 4. Why use Docker for Observability?

- **Easy setup:** No need to install each tool manually.
- **Isolation:** Each tool runs in its own container, avoiding conflicts.
- **Portability:** Works the same on any system with Docker.
- **Reproducibility:** Share your setup with others using a single file.

---

## 5. Who should use Docker?

- Developers, DevOps, SREs, or anyone who wants to quickly spin up and test observability tools without polluting their local system.

---

## 6. Where can you run Docker?

- On your laptop (Windows, Mac, Linux)
- On servers (cloud or on-prem)
- In CI/CD pipelines

---

## 7. How to Set Up Your Observability Stack with Docker

### A. Project Structure

Organize your files as follows:

```
opensource-observability-package/
└── Docker approach/
    ├── docker-compose.yml
    ├── prometheus.yml
    └── promtail-config.yml
```

---

### B. docker-compose.yml

Place this file in your `Docker approach` directory:

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.45.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    restart: unless-stopped
    networks:
      - observability
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M

  node-exporter:
    image: prom/node-exporter:v1.6.1
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: unless-stopped
    networks:
      - observability
    deploy:
      resources:
        limits:
          memory: 256M

  loki:
    image: grafana/loki:2.9.7
    container_name: loki
    ports:
      - "3100:3100"
    command: -config.file=/etc/loki/local-config.yaml
    restart: unless-stopped
    networks:
      - observability
    deploy:
      resources:
        limits:
          memory: 512M

  grafana:
    image: grafana/grafana:10.0.3
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    restart: unless-stopped
    networks:
      - observability
    deploy:
      resources:
        limits:
          memory: 512M

  promtail:
    image: grafana/promtail:2.9.7
    container_name: promtail
    ports:
      - "9080:9080"
    volumes:
      - ./promtail-config.yml:/etc/promtail/config.yml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    command: -config.file=/etc/promtail/config.yml
    depends_on:
      - loki
    networks:
      - observability
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M

networks:
  observability:
    driver: bridge
```

---
### C. promtail-config.yml

Place this file in the same directory as your `docker-compose.yml`:

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*-json.log
    pipeline_stages:
      - json:
          expressions:
            output: log
            stream: stream
            timestamp: time
      - labels:
          stream:
      - output:
          source: output
```

---


### C. prometheus.yml

Place this file in the same directory as your `docker-compose.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

---

### D. Start the Stack

From your `Docker approach` directory, run:

```bash
# Navigate to project directory
cd "Docker approach"

# Pull images
docker compose pull

# Start the stack
docker compose up -d

# Stop the stack
docker compose down

# Verify services
docker ps
```

- This will pull the images (if not already present) and start all services in the background.

---

### E. Access the Tools

- **Prometheus:** [http://localhost:9090](http://localhost:9090)
- **Grafana:** [http://localhost:3000](http://localhost:3000) (login: `admin` / `admin`)
- **Loki:** [http://localhost:3100](http://localhost:3100)
- **Node Exporter:** [http://localhost:9100/metrics](http://localhost:9100/metrics)

---

### F. Stopping and Cleaning Up

- **Stop the stack:**  
  ```bash
  docker compose down
  ```
- **Remove all data (if you added volumes):**  
  ```bash
  docker compose down -v
  ```

---
## 8. Do I need config files for Loki, Grafana, etc.?

- **Prometheus**: Needs `prometheus.yml` (provided above).
- **Loki**: Uses a default config for basic use. You can add your own if needed.
- **Grafana**: Uses internal config by default. For custom dashboards or datasources, you can mount provisioning files.
- **Node Exporter**: No config needed for basic use.

---

## 9. Why Docker Compose vs. Kubernetes/Helm?

- **Docker Compose** is simpler and faster for local development and testing.
- **Kubernetes/Helm** is better for production, scaling, and advanced orchestration.
- **Docker Compose** is great for “try it out” and “single machine” use cases.

---

## 10. Who Should Use This Guide?

- Anyone wanting to quickly test or demo an observability stack on their laptop or server, without learning Kubernetes.

---

## 11. Where to Run?

- Any machine with Docker installed (your laptop, a VM, a cloud server).

---

## 12. Next Steps

- Add more configuration (dashboards, alerting, etc.) as needed.
- Share your `docker-compose.yml` and config files with your team for easy onboarding.

---

**Let me know if you want ready-to-use config files for Loki or Grafana, or help