packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 1"
    }
  }
}

source "azure-arm" "openscap_hardening" {
  azure_tags = {
    dept    = "Security"
    project = "OpenSCAP-Remediation"
  }
  client_id                         = "client_id"
  client_secret                     = "client_secret"
  subscription_id                   = "subscription_id"
  tenant_id                         = "tenant_id"
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "Canonical"
  image_sku                         = "22_04-lts-gen2"
  build_resource_group_name         = "cariad-dev-wp09-west-us-02"
  managed_image_name                = "wp09-ubuntu-22-04-template"
  managed_image_resource_group_name = "cariad-dev-wp09-west-us-02"
  os_type                           = "Linux"
  vm_size                           = "Standard_DS2_v2"
}


build {
  sources = ["source.azure-arm.openscap_hardening"]
  provisioner "shell" {
    inline          = ["sudo apt-get update", "sudo apt-get upgrade -y", "sudo apt-get install unzip -y", "sudo apt-get install libopenscap8 -y"]
    max_retries       = 5
  }
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    script          = "./setup.sh"
  }
  provisioner "file" {
    source      = "cloud-init.yaml"
    destination = "/tmp/cloud-init.yaml"
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/cloud-init.yaml /etc/cloud/cloud.cfg.d/99_remove_waagent.cfg"
    ]
  }
  provisioner "file" {
    source      = "/tmp/reports/report-before.html"
    destination = "/tmp/report-before.html"
    direction   = "download"
  }
  provisioner "file" {
    source      = "/tmp/reports/report-after.html"
    destination = "/tmp/report-after.html"
    direction   = "download"
    max_retries = 5
  }
  provisioner "shell" {
    inline          = ["/usr/sbin/waagent -force -deprovision+user export HISTSIZE=0 sync"]
  }

}