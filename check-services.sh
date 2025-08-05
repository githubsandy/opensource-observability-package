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

# Check each service
check_service "Grafana        " "http://localhost:3000"
check_service "Prometheus     " "http://localhost:9090"
check_service "Loki           " "http://localhost:3100/metrics"
check_service "Blackbox Export" "http://localhost:9115"

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