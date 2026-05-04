# Post-Provision Validation

## Deploy monitoring apps
```bash
az aks get-credentials -g <rg> -n <aks_name> --admin
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/prometheus -f k8s/prometheus-values.yaml -n monitoring --create-namespace
helm upgrade --install grafana grafana/grafana -f k8s/grafana-values.yaml -n monitoring
```

## Tests
1. Validate AKS ingress via Application Gateway public IP/FQDN.
2. Resolve Traffic Manager DNS: `nslookup <traffic_manager_fqdn>`.
3. Check Prometheus targets: `kubectl get pods -n monitoring` and port-forward to UI.
4. Access Grafana LoadBalancer IP and confirm Prometheus datasource.
5. Validate connectivity: AKS node to internet through Azure Firewall and spoke-to-hub routing.
