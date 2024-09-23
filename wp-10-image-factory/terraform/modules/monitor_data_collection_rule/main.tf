resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "dcr-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  data_sources {
    syslog {
      name           = "syslog"
      facility_names = ["*"]
      log_levels     = ["*"]
      streams = ["Microsoft-Syslog"]
    }
  }

  destinations {
    log_analytics {
      name                  = "loganalytics-destination"
      workspace_resource_id = var.workspace_resource_id
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["loganalytics-destination"]
  }
}
