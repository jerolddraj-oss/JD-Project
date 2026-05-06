# Azure Windows RDS PoC – Hub & Spoke Architecture

## Overview

This project deploys a Proof of Concept (PoC) Microsoft Remote Desktop Services (RDS) environment in Microsoft Azure using:

- Terraform for Infrastructure as Code (IaC)
- Ansible for configuration management
- Hub and Spoke network topology
- Azure Firewall
- Network Security Groups (NSGs)
- Windows Server Virtual Machines

## Architecture Components

### Hub Network
- Azure Firewall
- Bastion / Management subnet
- Shared services

### Spoke Networks
- RDS Gateway subnet
- RD Connection Broker subnet
- RD Session Host subnet

## RDS Roles

| Role | Purpose |
|------|----------|
| RD Gateway | Secure remote access |
| RD Connection Broker | Session management |
| RD Session Host | User desktop sessions |

## Deployment Workflow

### Step 1 – Terraform Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve