*.eastus2.cloudapp.azure.com
dbg-cariad-test.eastus2.cloudapp.azure.com

# 1. Generate CA cert
openssl req -x509 -newkey rsa:4096 -keyout ca-key.pem -out ca-cert.pem -days 365 -subj "/CN=eastus2.cloudapp.azure.com" -nodes

# 2. Create new certificate and sign with CA.
# 2.1 Create a CSR with SAN
openssl req -new -newkey rsa:4096 -keyout fpt-cariad.key -out fpt-cariad.csr -config san.cnf -nodes

# 2.2 Sign the certificate with the CA cert and create a self-signed cert
openssl x509 -req -in fpt-cariad.csr -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out fpt-cariad.pem -days 365 -extfile san.cnf -extensions req_ext

# 3. Add CA cert to trust store.
$certPath = "C:\Users\adminuser\certs\ca-cert.pem"
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($certPath)
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()

# 4.
kk create secret tls ingress-nginx-artifactory01-tls --key fpt-cariad.key --cert fpt-cariad.pem

########################################################################
# Create client.key and client.crt in Linux Agent

# Prepare pfx file 
openssl pkcs12 -export -out client-cert.pfx -inkey client.key -in client.crt

# Import pfx
Import-PfxCertificate -FilePath "C:\path\to\client-cert.pfx" -CertStoreLocation Cert:\CurrentUser\My

# Get certificate thumbprint
Get-ChildItem Cert:\CurrentUser\My

# Use the certificate in Invoke-Web
$thumbPrint = "EC15C80138009E0536A964C573C3A27A43A124E8"
$cert = Get-Item Cert:\CurrentUser\My\EC15C80138009E0536A964C573C3A27A43A124E8
Invoke-WebRequest -Uri "https://dbg-artifactory01.eastus2.cloudapp.azure.com" -Certificate $cert
