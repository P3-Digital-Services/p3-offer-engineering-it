## Terraform
### Overview dicts
* `modules`: contains Terraform modules.
* `deployment`: content Terraform deployment files.

### Terraform modules
1. **Linux VM**
2. **Windows VM**
3. **VNET/SUBNET**
4. **AKS**
5. **AKV**

### Prepare working environment
* Create init storage account to store state files in advance.
* Locally runs Terraform configurations in `deployment` folders to deploy working environment.

## Ansible
### Overview dicts
* `inventory`: contains inventory file and group/host variable files.
* `roles`: contains Ansible custom roles
* `./`: contains ansible playbooks

### Roles
1. **ansible-prepare**: install required packages and dependencies.
2. **artifactory**: manage (install/upgrade/delete) jfrog artifactory instances.
3. **check-tls-expiration**: check if TLS certificate needs renewal or not.
4. **ingress-controller**: manage (install/upgrade/delete) ingress controller instances.
5. **mtls-certificate**: generate mTLS secret to authorize client requests.
6. **tls-certificate**: generate TLS secret to authorize server requests.

### Playbooks
1. **artifactory.yml**: playbook to manage jfrog artifactory instances.
2. **ingress_controller.yml**: playbook to manage ingress controller instances.
3. **mtls_cert.yml**: playbook to mTLS secret.
4. **prepare_environment**: playbook to install required packages and dependencies.
5. **tls_cert**: playbook to generate TLS secret.


## Helm value
*Contains **helm values** that will be used by **Ansible playbook** to deploy Helm chart.*
### Overview dicts
* `artifactory-oss`: contains helm values to deploy Jfrog artifacts.
* `ingress-controller`: contains helm values to deploy Ingress Controller instannces.

## Implemented Tasks
### Done
1. Prepare working environment on Azure using Terraform.
2. Azure Resource Group and AKS Cluster:
    1. Create an Azure Resource Group.
    2. Set up an Azure Kubernetes Service (AKS) cluster with a default node pool.
3. Kubernetes Configuration:
    1. Deploy two separate Artifactory (OSS) instances within the AKS cluster using Helm charts.
    .2 Configure each Artifactory instance to use mTLS for secure communication.
4. mTLS Proxy Setup:
    1. Deploy Nginx Ingress controllers as mTLS proxies for each Artifactory instance.
    2. Use a self-signed CA to generate certificates for mTLS authentication.
5. Ingress Configuration:
    1. Create Kubernetes secrets to store TLS certificates.
    2. Configure Nginx Ingress resources to:
        1. Use the TLS certificates for secure communication.
        2. Route traffic to the respective Artifactory instances.
        3. Enforce mTLS by verifying client certificates.
    3. Ensure proper namespace and secret management for storing TLS certificates.
6. Resource Management:
    1. Configure Kubernetes services to expose Artifactory instances internally.
    2. Set up ingress rules to handle HTTP(S) traffic and forward it to the Artifactory services.
7. Fix mTLS Handling for Remote Repositories:
    1. Implement a solution to enable Artifactory to handle mTLS connections for remote repositories.
    2. Ensure that the solution is integrated seamlessly with the existing setup and does not disrupt other functionalities.
8. Configuration Management with Ansible:
    1. Use Ansible to automate the configuration and management of the AKS cluster, Artifactory instances, and mTLS proxies.
    2. Ensure that all configurations are idempotent and can be easily reproduced


## Delivery:
### Done
1. Terraform script (optional but preferable) that automates the initial infrastructure setup.
2. Helm charts and custom values files for deploying Artifactory (OSS) instances.
3. Ansible playbooks for configuration management, including:
    1. TLS certificate generation and management.
    2. Nginx Ingress configuration for mTLS.
    3. Artifactory configuration for mTLS and remote repositories.
4. Documentation explaining the setup and configuration steps, including:
    1. Detailed ingress configuration for mTLS enforcement.
    2. Steps to verify the mTLS setup.
    3. Instructions on how the mTLS handling for remote repositories was fixed and tested.
    4. Ansible playbooks and their usage.