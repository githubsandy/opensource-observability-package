#!/bin/bash

NAMESPACE="kube-observability-stack"

# Create namespace
kubectl create namespace $NAMESPACE

# Apply all YAML files in the correct order
kubectl apply -f prometheus-deployment.yaml -n $NAMESPACE
kubectl apply -f node-exporter-daemonset.yaml -n $NAMESPACE
kubectl apply -f loki-deployment.yaml -n $NAMESPACE
kubectl apply -f promtail-deployment.yaml -n $NAMESPACE
kubectl apply -f grafana-deployment.yaml -n $NAMESPACE

echo "Observability stack deployed successfully in namespace: $NAMESPACE"