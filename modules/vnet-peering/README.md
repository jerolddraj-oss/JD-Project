# VNet Peering Module (Azure)

## Overview
This module implements bidirectional VNet peering between Hub and Spoke networks in a hub-and-spoke architecture.

## Use Cases
- Centralized security using Azure Firewall
- Private AKS communication across VNets
- Multi-region connectivity

## Prerequisites
- Existing Hub VNet
- Existing Spoke VNets
- Non-overlapping CIDR ranges
- Proper RBAC permissions

## Features
- Bidirectional peering (Hub ↔ Spoke)
- Configurable traffic settings
- Supports hub-and-spoke routing

## Requirements
- Terraform >= 1.3
- AzureRM Provider

## Notes
- Azure does not support BGP between VNets
- Use UDR for advanced routing
