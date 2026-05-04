# Global Fix Applied

## Root Cause
All modules were missing variable definitions, causing Terraform to reject arguments.

## Fix Applied
Standardized variable definitions across all modules:

### Required variables added to ALL modules:
- rg
- location

### Additional per module:
- spoke: name
- aks: name
- vnet-peering: resource_group_name, hub_vnet_id, hub_vnet_name, spokes

## Next Steps
Run:
terraform init -upgrade
terraform validate
terraform plan

If running in CI/CD ensure cache cleanup is enabled.
