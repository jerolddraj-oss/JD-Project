output "aks_name" { value=azurerm_kubernetes_cluster.this.name }
output "aks_fqdn" { value=azurerm_kubernetes_cluster.this.fqdn }
output "kube_config_raw" { value=azurerm_kubernetes_cluster.this.kube_admin_config_raw sensitive=true }
output "ingress_private_ip" { value="10.1.1.10" }
