## How to run

### Prerequisites

- Install Ansible
- Install TerraForm
- Install Helm
- Install Azure-CLI
- Azure Account Permission Contributor.

### Steps to Run Terraform

1. Ensure your machine has Azure CLI installed, and that your Azure account has Contributor permissions on the Azure Subscription you're working on.

    ```bash
    az login
    az account set --subscription <subscription-id>
    ```

2. Execute the following Terraform commands to create Azure resources for the project:

    ```bash
    cd terraform/aks
    terraform init
    terraform plan
    terraform apply
    ```

### Steps to Run Ansible

1. Ensure your machine has Azure CLI installed, and that your Azure account has Contributor permissions on the Azure Subscription you're working on.

    ```bash
    az login
    az account set --subscription <subscription-id>
    ```

2. Use the following Azure CLI command to download the credentials for your AKS cluster and configure kubectl

    ```bash
    az aks get-credentials --resource-group <resource-group> --name <cluster-name>
    ```

3. Ensure update credentials and variables are defined in the vars directory
4. Execute the following Ansible commands to rotate Jenkins master key

    ```bash
    cd ansible
    ansible-playbook jenkins-security-breach.yml 
    ```