# Azure Hub-and-Spoke Terraform (AKS + VMSS + Monitoring + Key Vault + Traffic Manager)

## Overview
This repository contains a modular Terraform project to deploy a hub-and-spoke network in Azure, an AKS cluster (Azure CNI, Azure AD integration), two VMSS instances, Azure Firewall with forced tunneling, internal load balancer, Traffic Manager, Log Analytics, Key Vault, and diagnostic settings.

## Prerequisites
- Terraform 1.0+
- Azure subscription
- Service principal with Contributor role (or appropriate RBAC)
- GitHub repository with Secrets configured (see below)
- `az` CLI for local operations

## GitHub Secrets (used by workflow)
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `BACKEND_RG`
- `BACKEND_STORAGE_ACCOUNT`
- `BACKEND_CONTAINER`
- `BACKEND_KEY`
- `AZURE_CREDENTIALS` (JSON for azure/aks-set-context)
- `AKS_CLUSTER_NAME`
- `AKS_RESOURCE_GROUP`

## Deploy locally
1. Export Azure SP credentials as environment variables or set them in `terraform.tfvars`.
2. Initialize Terraform:
   ```bash
   terraform init \
     -backend-config="resource_group_name=BACKEND_RG" \
     -backend-config="storage_account_name=BACKEND_STORAGE_ACCOUNT" \
     -backend-config="container_name=BACKEND_CONTAINER" \
     -backend-config="key=terraform.tfstate"
