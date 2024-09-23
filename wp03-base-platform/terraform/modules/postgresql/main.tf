resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "${var.name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  administrator_login = var.psql_admin_username
  administrator_password  = var.psql_admin_password
  sku_name            = "GP_Standard_D2s_v3"
  storage_mb          = 32768
  version             = "13"
  zone                = 3
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.private_dns_zone.id
  high_availability {
    mode = "SameZone"
    standby_availability_zone = 3
  }
  backup_retention_days = 35
  geo_redundant_backup_enabled = true
  auto_grow_enabled = true
  
  tags                = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  name                = var.database_name
  server_id           = azurerm_postgresql_flexible_server.postgresql.id
  collation           = "en_US.utf8"
  charset             = "UTF8"
}
