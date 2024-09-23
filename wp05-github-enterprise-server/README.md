## Requirement For GitHub Enterprise Server on Azure
- licenses: Trial, demo, or 10 light users
- x86-64 vCPUs: 4
- Memory: 32GB
- Root storage: 200 GB
- Attached (data) storage: 150 GB

### Prerequisites

- Install Ansible
- Install TerraForm
- Install Azure-CLI
- Azure Account Permission Contributor.

## How to run

### Steps to Run Terraform

1. Ensure your machine has Azure CLI installed, and that your Azure account has Contributor permissions on the Azure Subscription you're working on.

    ```bash
    az login
    az account set --subscription <subscription-id>
    ```

2. Modify the `subscription_id` value in the `./terraform/versions.tf` file located in the root directory.

3. (Optional) You can also customize your values in the `./terraform/terraform.tfvars` file located in the root directory.

4. Execute the following Terraform commands to create Azure resources for the project:

    ```bash
    cd terraform/
    terraform init
    terraform validate
    terraform plan
    terraform apply
    ```

### Steps to Run ansible
```bash
cd ansible/
ansible-playbook -i inventory/hosts playbooks/main.yaml
```

### Resource groups & Azure VMs
- Resource groups:
  - WP05_GITHUB_ENTERPRISE_EAST_US
  - WP05_GITHUB_ENTERPRISE_WEST_US_2

- Virtual machines:
  - vm-wp05-ge-east-us-1
  - vm-wp05-ge-east-us-2
  - vm-wp05-ge-west-us-2-1 (cross region)

### Setting up replica
1. ssh to replica vm
   ```bash
   ssh -p 122 -i <private key path> <admin username>@<replica IP>
   ```
2. To generate a key pair for replication, use the `ghe-repl-setup` command with the primary appliance's IP address and copy the public key as the command output.
   ```bash
   sudo ghe-repl-setup <primary IP>
   ```
   Output: <SSH string key>
   
3. Open browser access to `https://<primary IP>:8443/setup/start`
4. Enter admin password
5. Input the SSH public key (2)
6. Go back SSH terminal, then enter the below command to verify the connection:
   ```bash
   ghe-repl-setup <primary ip> 
   ```
   PS: for the second replica, add more flag `--add`
7. Start replica
   ```bash
   ghe-repl-start
   ```
8. Check status
   ```bash
   ghe-repl-status
   ```
    
### Install Prometheus & Grafana

1. Ensure your machine has Azure CLI installed, and that your Azure account has Contributor permissions on the Azure Subscription you're working on.
    ```bash
    az login
    az account set --subscription <subscription-id>
    ```

2. Provision VM (Ubuntu LTS 18):
    ```bash
    az vm create -n vm-wp05-ge-west-us-2-prometheus-graffana -g WP05_GITHUB_ENTERPRISE_WEST_US_2 --size Standard_F8s_v2 -l westus2 --image Canonical:UbuntuServer:18.04-LTS:latest --storage-sku Standard_LRS --admin-password <admin password> --admin-username <admin username> --generate-ssh-keys --output table
    ```
3. Install Prometheus:
https://www.cherryservers.com/blog/install-prometheus-ubuntu

4. Install Grafana:
https://www.cherryservers.com/blog/install-grafana-ubuntu

5. Configuring `Load Balancer` for our 3 VMs
6. Configuring Failover script in Prometheus & Grafana VM in order to automatically promote the replica instance to the primary instance in case the primary instance down.
7. Integrate `Load balancer` service automatically find the proper instance and route traffic by `health-check` mechanism.