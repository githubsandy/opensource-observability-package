#!/bin/bash
echo "Starting observability services..."
echo "Grafana will be available at: http://localhost:3000"
echo "Prometheus will be available at: http://localhost:9090" 
echo "Loki will be available at: http://localhost:3100"
echo "Blackbox Exporter will be available at: http://localhost:9115"
echo ""
echo "Press Ctrl+C to stop all services"

# Start all port forwards in background
kubectl port-forward svc/grafana 3000:3000 -n kube-observability-stack &
PID1=$!

kubectl port-forward svc/prometheus 9090:9090 -n kube-observability-stack &
PID2=$!

kubectl port-forward svc/loki 3100:3100 -n kube-observability-stack &
PID3=$!

kubectl port-forward svc/blackbox-exporter 9115:9115 -n kube-observability-stack &
PID4=$!

# Wait for interrupt
trap "kill $PID1 $PID2 $PID3 $PID4; exit" INT
wait