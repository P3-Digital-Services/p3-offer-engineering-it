# Installing HashiCorp Boundary

HashiCorp Boundary is an open-source tool for secure access management. This guide provides step-by-step instructions for installing Boundary on a system.

## 1. Prerequisites

Before you begin, ensure you have the following:

- A supported operating system (Linux, macOS, or Windows).
- Access to a terminal or command prompt.
- Administrative privileges to install software.
- Service Princial Name (WP09_PackerPrincipal)

You can create SPN with command 

```
az ad sp create-for-rbac -n "WP09_PackerPrincipal" --role="Contributor" --scopes="/subscriptions/<your-subscription>"
```


## 2. Provision new Azure VM
Follow the Azure portal instructions to create a new virtual machine. Ensure that the VM meets the system requirements for running Boundary.

## 3. Install and Configure PostgreSQL
### 3.1 Install PostgreSQL
Run the following command in your terminal:

```bash
sudo apt install postgresql -y
```
![alt text](./images/image.png)

### 3.2 Configure PostgreSQL
Open the PostgreSQL command line:

```bash
sudo -u postgres psql
```

Create a new database and user:

```bash
CREATE DATABASE boundary;
CREATE USER boundary WITH ENCRYPTED PASSWORD 'hidden_password';
GRANT ALL PRIVILEGES ON DATABASE boundary TO boundary;
```

Quit the postgres `\q`

```
postgres=# CREATE DATABASE boundary;
CREATE DATABASE
postgres=# CREATE USER boundary WITH ENCRYPTED PASSWORD '*************';
CREATE ROLE
postgres=# GRANT ALL PRIVILEGES ON DATABASE boundary TO boundary;
GRANT
postgres=# \q
root@hcl-boundary-02:~# 
```

### 3.3 Enable Password Authentication

Edit the PostgreSQL configuration file to allow password authentication:


```bash
echo "host    all             all             127.0.0.1/32            password" | sudo tee -a /etc/postgresql/14/main/pg_hba.conf
```

![alt text](./images/image-2.png)

Then `Restart` the PostgreSQL service:

```bash
sudo systemctl restart postgresql
```

<div class="page"/>

## 4. Install and Configure Apache2
### 4.1 Install Apache2

Run the following commands:

```bash
sudo apt install apache2 -y
sudo a2enmod ssl proxy proxy_http
sudo systemctl start apache2
```

![alt text](./images/image-3.png)

![alt text](./images/image-4.png)

### 4.2 Create a Self-Signed Certificate
Create a directory for SSL certificates and generate a self-signed certificate:

```bash
sudo mkdir /etc/ssl/mycerts
```

Generate a private key with the following command:
```bash
sudo openssl genrsa -out /etc/ssl/mycerts/private.key 2048
```

Run this command to create a CSR. You'll be prompted to enter some information.
```bash
sudo openssl req -new -key /etc/ssl/mycerts/private.key -out /etc/ssl/mycerts/self-signed.csr
```
![alt text](./images/image-5.png)

Use the following command to create the self-signed certificate:
```bash
sudo openssl x509 -req -days 365 -in /etc/ssl/mycerts/self-signed.csr -signkey /etc/ssl/mycerts/private.key -out /etc/ssl/mycerts/self-signed.crt
```

Output
```
root@hcl-boundary-02:/etc/ssl/mycerts# sudo openssl x509 -req -days 365 -in /etc/ssl/mycerts/self-signed.csr -signkey /etc/ssl/mycerts/private.key -out /etc/ssl/mycerts/self-signed.crt
Certificate request self-signature ok
subject=C = VN, ST = HN, L = Hanoi, O = FPT, CN = boundary.example.com
```

### 4.3 Create a Dummy SSL Site

Edit your Apache configuration file `/etc/apache2/sites-available/default-ssl.conf` to include the following lines:

```
<IfModule mod_ssl.c>
        <VirtualHost 127.0.0.1:443>
                ServerAdmin webmaster@localhost
                ServerName test.example.com
                DocumentRoot /var/www/html

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on
                SSLProxyEngine on
                SSLProxyVerify none
                SSLProxyCheckPeerCN off
                SSLProxyCheckPeerName off
                SSLCertificateFile      /etc/apache2/ssl/cert.pem
                SSLCertificateKeyFile /etc/apache2/ssl/key.pem

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>


        </VirtualHost>
</IfModule>
```

Enable default ssl website

```bash
a2ensite default-ssl
```

Reload service
```bash
systemctl reload apache2
```

![alt text](./images/image-6.png)


Test the dummy site:
```bash
curl -I -k https://127.0.0.1
```

![alt text](./images/image-24.png)

### 4.4 Update /etc/hosts
Add the following lines to your /etc/hosts file:

```bash
echo "127.0.0.1 localhost test.example.com controller.example.com worker.example.com oundary.example.com" | sudo tee -a /etc/hosts
```
![alt text](./images/image-8.png)

<div class="page"/>

## 5. Install and Configure Boundary

### 5.1 Install Boundary

Add the HashiCorp GPG Key

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```
Add the HashiCorp Repository

```bash
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
Install Boundary
```bash
sudo apt update

```
![alt text](./images/image-9.png)

Fix GPG Key Errors (if any)
```
sudo chmod 644 /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

![alt text](./images/image-10.png)

Run command to install `boundary`
```bash
sudo apt install boundary -y
```
![alt text](./images/image-11.png)


### 5.3 Create KMS Keys


Go to Auzre Portal and create new keyvault named `cariad-dev-wp09-boundary`

![alt text](./images/image-26.png)

![alt text](./images/image-27.png)

Grant access for the service principal (SPN) with role `Key Vault Crypto Officer`



Then create three keys
- Root key
- Recovery key
- Worker-auth key

![alt text](./images/image-29.png)



### 5.2 Configure Boundary Controller

**Prepare TLS certificates**: Run following command

Create a directory for SSL certificates and generate a self-signed certificate:

```bash
sudo mkdir /etc/ssl/boundary
```

Generate a private key with the following command:
```bash
sudo openssl genrsa -out /etc/ssl/boundary/private.key 2048
```

Run this command to create a CSR. You'll be prompted to enter some information.
```bash
sudo openssl req -new -key /etc/ssl/boundary/private.key -out /etc/ssl/boundary/boundary.csr
```

Use the following command to create the self-signed certificate:
```bash
sudo openssl x509 -req -days 365 -in /etc/ssl/boundary/boundary.csr -signkey /etc/ssl/boundary/private.key -out /etc/ssl/boundary/boundary.crt
```
![alt text](./images/image-12.png)

Output
```
root@hcl-boundary-02:~# sudo openssl x509 -req -days 365 -in /etc/ssl/boundary/boundary.csr -signkey /etc/ssl/boundary/private.key -out /etc/ssl/boundary/boundary.crt
Certificate request self-signature ok
subject=C = VN, ST = HN, L = Hanoi, O = FPT, CN = boundary.example.com
```


Edit Configuration File `/etc/boundary.d/boundary.env` :

```bash
POSTGRESQL_CONNECTION_STRING=postgresql://boundary:********@127.0.0.1:5432/boundary
```

Reload OS environment
```bash
source /etc/boundary.d/boundary.env
```

**Base Controller Configuration**
Create the boundary.hcl file as per requirements.

```hcl
# disable memory from being swapped to disk
disable_mlock = true

# API listener configuration block
listener "tcp" {
  # Should be the address of the NIC that the controller server will be reached on
  # Use 0.0.0.0 to listen on all interfaces
  address = "127.0.0.1:9200"
  # The purpose of this listener block
  purpose = "api"

  # TLS Configuration
  tls_disable   = false
  tls_cert_file = "/etc/ssl/boundary/boundary.crt"
  tls_key_file  = "/etc/ssl/boundary/private.key"

  # Uncomment to enable CORS for the Admin UI. Be sure to set the allowed origin(s)
  # to appropriate values.
  #cors_enabled = true
  #cors_allowed_origins = ["https://yourcorp.yourdomain.com", "serve://boundary"]
}

# Data-plane listener configuration block (used for worker coordination)
listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "127.0.0.1:9201"
  # The purpose of this listener
  purpose = "cluster"
}

# Ops listener for operations like health checks for load balancers
listener "tcp" {
  # Should be the address of the interface where your external systems'
  # (eg: Load-Balancer and metrics collectors) will connect on.
  address = "127.0.0.1:9203"
  # The purpose of this listener block
  purpose = "ops"

  tls_disable   = false
  tls_cert_file = "/etc/ssl/boundary/boundary.crt"
  tls_key_file  = "/etc/ssl/boundary/private.key"
}

# Controller configuration block
controller {
  # This name attr must be unique across all controller instances if running in HA mode
  name = "boundary-controller-1"
  description = "Boundary controller number one"

  # This is the public hostname or IP where the workers can reach the
  # controller. This should typically be a load balancer address
  public_cluster_addr = "controller.example.com"

  # Enterprise license file, can also be the raw value or env:// value
  #license = "file:///path/to/license/file.hclic"

  # After receiving a shutdown signal, Boundary will wait 10s before initiating the shutdown process.
  graceful_shutdown_wait_duration = "10s"

  # Database URL for postgres. This is set in boundary.env and
  #consumed via the “env://” notation.
  database {
     url = "env://POSTGRESQL_CONNECTION_STRING"
  }
}

# Events (logging) configuration. This
# configures logging for ALL events to both
# stderr and a file at /var/log/boundary/controller.log
events {
  audit_enabled       = true
  sysevents_enabled   = true
  observations_enable = true
  sink "stderr" {
    name = "all-events"
    description = "All events sent to stderr"
    event_types = ["*"]
    format = "cloudevents-json"
  }
  sink {
    name = "file-sink"
    description = "All events sent to a file"
    event_types = ["*"]
    format = "cloudevents-json"
    file {
      path = "/var/log/boundary"
      file_name = "controller.log"
    }
    audit_config {
      audit_filter_overrides {
        sensitive = "redact"
        secret    = "redact"
      }
    }
  }
}

# Root KMS Key (managed by AWS KMS in this example)
# Keep in mind that sensitive values are provided via ENV VARS
# in this example, such as access_key and secret_key
#
kms "azurekeyvault" {
  purpose        = "root"
  tenant_id      = "tenant-id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms"
  key_name       = "vault1"
}
kms "azurekeyvault" {
  purpose        = "recovery"
  tenant_id      = "tenant-id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms"
  key_name       = "vault2"
}
kms "azurekeyvault" {
  purpose        = "worker-auth"
  tenant_id      = "tenant-id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms"
  key_name       = "vault3"
}
```

Please remember to change value of `tenant_id`, `client_id`, `client_secret`, `vault_name`, `key_name`.

### 5.3 Run the Boundary

Initialize the Database
```bash
boundary database init -config /etc/boundary.d/boundary.hcl
```
The output look like. You will get the initial credential from output console. Please save them to use later
![alt text](./images/image-13.png)

**Start Boundary Service**

First all first, We need to update File Permissions for `boundary`

```bash
sudo chown -R boundary:boundary /etc/boundary.d
sudo chown -R boundary:boundary /var/log/boundary
sudo chown -R boundary:boundary /etc/ssl/boundary
```

Then, enable boot-start and start the service
```bash
sudo systemctl enable boundary
sudo systemctl start boundary
```

Verify the status:
```bash
sudo systemctl status boundary
```

Output:
```
root@hcl-boundary-02:/etc/apache2/sites-available# systemctl status boundary
● boundary.service - "HashiCorp Boundary - Identity-based access management for dynamic infrastructure"
     Loaded: loaded (/lib/systemd/system/boundary.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-09-23 03:29:52 UTC; 33min ago
       Docs: https://www.boundaryproject.io/docs
   Main PID: 10134 (boundary)
      Tasks: 47 (limit: 9519)
     Memory: 292.6M
        CPU: 38.152s
     CGroup: /system.slice/boundary.service
             ├─10134 /usr/bin/boundary server -config=/etc/boundary.d/boundary.hcl
             ├─10141 /tmp/3372176301/boundary-plugin-kms-azurekeyvault-gmMTT
             ├─10149 /tmp/3012504364/boundary-plugin-kms-azurekeyvault-wSSDg
             ├─10158 /tmp/3225556827/boundary-plugin-kms-azurekeyvault-roA0R
             ├─10168 /tmp/2276464319/boundary-plugin-aws-bMDcj
             └─10175 /tmp/3612182203/boundary-plugin-azure-aXead

Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"1kWltL3NTO","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"github.com/hashic>
Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"W3acCR1pHE","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"github.com/hashic>
Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"mYAlwSax9z","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"github.com/hashic>
Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"nAordNphSw","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"github.com/hashic>
Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"v8bjYAXfKL","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"github.com/hashic>
Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"K3tih9EXZR","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"github.com/hashic>
Sep 23 03:29:56 hcl-boundary-02 boundary[10134]: {"id":"4bWoHYLDLY","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"system","data":{"version":"v0.1","op":"server.RotateRoot>
Sep 23 03:56:48 hcl-boundary-02 boundary[10134]: {"id":"Fn2WdPWJO1","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"audit","data":{"id":"e_b5AE2jVvVG","version":"v0.1","typ>
Sep 23 03:57:30 hcl-boundary-02 boundary[10134]: {"id":"rmRZFgKYFQ","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"audit","data":{"id":"e_h821ZA6Mw3","version":"v0.1","typ>
Sep 23 03:59:07 hcl-boundary-02 boundary[10134]: {"id":"nGsu5tFWSO","source":"https://hashicorp.com/boundary/hcl-boundary-02/controller","specversion":"1.0","type":"audit","data":{"id":"e_Hh506rUocN","version":"v0.1","typ>
lines 1-26/26 (END)
```

Verify with `Boundary API`

```bash
curl -k https://127.0.0.1/v1/auth-methods?scope_id=global
```

![alt text](./images/image-14.png)

### 5.4 Config reverse proxy
Create config file `/etc/apache2/site-avaiable/boundary.conf` with content below to public Boundary Management Web UI
```
<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName boundary.example.com
        ServerAdmin admin@example.com

        ErrorLog ${APACHE_LOG_DIR}/boundary.example.com_error.log
        CustomLog ${APACHE_LOG_DIR}/boundary.example.com_access.log combined

        ProxyPass / https://127.0.0.1:9200/

        ProxyRequests Off

        SSLEngine on
        SSLProxyEngine on
        SSLProxyVerify none
        SSLProxyCheckPeerCN off
        SSLProxyCheckPeerName off

        SSLCertificateFile /etc/ssl/boundary/boundary.crt
        SSLCertificateKeyFile /etc/ssl/boundary/private.key

        #<LocationMatch "^/">
        #    Require all denied
        #</LocationMatch>

        #<LocationMatch "^/v1/auth-methods|^/v1/targets">
        #    Require all granted
        #</LocationMatch>
    </VirtualHost>
</IfModule>
```

Enable boundary site

```bash
a2ensite boundary
```
Then reload Apache service to apply the change

```bash
systemctl reload apache2 
```

Check access on browser:

![alt text](./images/image-25.png)

Login with `Initial auth information` that we got from step **5.3**


### 5.5 Create Boundary Worker

Create worker configuration file as bellow:

```hcl
listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

# worker block for configuring the specifics of the
# worker service
worker {
  name = "worker1"
  public_addr = "worker.example.com"
  initial_upstreams = ["controller.example.com:9201"]
  tags {
    type = ["worker", "egress"]
  }
}
kms "azurekeyvault" {
  purpose        = "worker-auth"
  tenant_id      = "tenant_id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms"
  key_name       = "boundary-worker-auth"
}
```

Please remember to update `kms` information before deploying

Deploy the worker in same VM

```bash
boundary server -config=/etc/boundary.d/worker.hcl &
```

![alt text](./images/image-16.png)


The Worker will be connected to `Boundary Controller` aotumatically

From Web Admin UI, select Worker, you will see the worker is connected

![List Boundary worker](./images/image-19.png)

<div class="page"/>

## 6. Create user, target

### 6.1. Create Authentication method

Go to `Generated Scope Org`

![Go to Generated Scope Org](./images/image-20.png)

Select `Auth Methods` and create a new **Password Auth Methods**

![Password Auth Methods](./images/image-21.png)

Then make `password-auth` as primary Auth Methods

![primary Auth Methods](./images/image-23.png)

### 6.2. Create new User

Go to **Users** and create new one

![create new user](./images/image-22.png)

### 6.3. Create new account
In Auth Methods, Create new account
![Create new account](./images/image23.png)

Assign account to user
![Assign account](./images/image24.png)

### 6.4. Add Role to project
In Projects > Roles > Add Pricipals > Add account created in 6.3
![Alt text](./images/image25.png)


1. Connect to target
Login in CLI
    ```
    boundary authenticate password -auth-method-id <method-id> --tls-insecure
    ```
Save token to env
Connect to target
    ```
    boundary connect -target-id <target-id> -token env://BOUNDARY_TOKEN --tls-insecure
    ```

<div class="page"/>

## 7. Custom Boundary Client

Download Boundary source code from github [Boundary Source](https://github.com/hashicorp/boundary)

```bash
git clone https://github.com/hashicorp/boundary.git
```

### 7.1. Hardcode Boundary URL

Open file `/api/client.go`, add content to `line 33-34`

```go
const DEFAULT_CLIENT_URL="https://boundary.example.com 
```

![alt text](./images/image-30.jpg)

Change the code from `line 442-445` to
```
  if err:=c.setAddr(DEFAULT_CLIENT_URL); err != nil {
    return nil, err
  }
```

![alt text](./images/image-31.jpg)

### 7.2. Modify the code to fetch Auth Method ID aotumatically

Open the file `internal/cmd/commands/authenticate/funcs.go` and paste the code in from `line 135`

```go
/ getPasswordAuthMethodId returns the auth method ID from list of auth methods.
func getPasswordAuthMethodId(ctx context.Context, client *authmethods.Client, scopeId string) (string, error) {
  authMethodListResult, err := client.List(ctx, scopeId)
  if err != nil {
    return "", err
  }

  for _, m := range authMethodListResult.GetItems() {
    if m.Type == "password" && m.ScopeId == scopeId {
      return m.Id, nil
    }
  }

  return "", fmt.Errorf("Password auth method not found for scope ID: '%s'. Please set a primary auth method on this scope or pass one explicitly using an authenticate sub command (see 'boundary authenticate -h') along with the -auth-method-id flag.", scopeId)
}
```

![alt text](./images/image-32.jpg)


Open the file `internal/cmd/commands/authenticate/password.go` and change the code as following
![alt text](./images/image-33.jpg)


### 7.3 Re-build the Boundary Client

Re-build boundary client with command

```
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o boundary cmd/boundary/main.go
```

Then you will get new `boundary` binary

### 7.4 Test new Boundary Client

Copy new binary to `/tmp`

Grant execution permission for binary
```
chmod +x /tmp/boundary
```

Run test command

```bash
./boundary authenticate password -tls-insecure
```

![alt text](./images/image-34.jpg)