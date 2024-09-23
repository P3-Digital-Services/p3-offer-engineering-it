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