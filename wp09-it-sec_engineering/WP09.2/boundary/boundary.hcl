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
  tls_cert_file = "/etc/boundary.d/tls/boundary-cert.pem"
  tls_key_file  = "/etc/boundary.d/tls/boundary-key.pem"

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
  tls_cert_file = "/etc/boundary.d/tls/boundary-cert.pem"
  tls_key_file  = "/etc/boundary.d/tls/boundary-key.pem"
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
  tenant_id      = "tenant_id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms-02"
  key_name       = "boundary-root"
}
kms "azurekeyvault" {
  purpose        = "recovery"
  tenant_id      = "tenant_id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms-02"
  key_name       = "boundary-recovery"
}
kms "azurekeyvault" {
  purpose        = "worker-auth"
  tenant_id      = "tenant_id"
  client_id      = "client_id"
  client_secret  = "client_secret"
  vault_name     = "cariad-kms-02"
  key_name       = "boundary-worker-auth"
}