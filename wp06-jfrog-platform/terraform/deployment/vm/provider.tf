provider "azurerm" {
  features {}
}

provider "azuread" {
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "dbg-cariad-demo"
    storage_account_name = "dbgdemocariadtfstate"
    container_name       = "tfstatefiles"
    key                  = "vm.tfstate"
  }
}
