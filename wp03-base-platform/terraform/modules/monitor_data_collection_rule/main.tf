resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "dcr-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  data_sources {
    syslog {
      name           = "syslog"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["*"]
      log_levels     = ["*"]
    }

    performance_counter {
      name                          = "perfCounters"
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      counter_specifiers            = ["Processor(*)\\% Processor Time", "Memory(*)\\% Used Memory", "Logical Disk(*)\\ % Used Space", "Logical Disk(*)\\ % Free Space"]
      sampling_frequency_in_seconds = 60
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Syslog", "Microsoft-Perf"]
    destinations = ["${var.destination}"]
  }

  destinations {
    log_analytics {
      name                  = var.destination
      workspace_resource_id = var.workspace_resource_id
    }
  }
}