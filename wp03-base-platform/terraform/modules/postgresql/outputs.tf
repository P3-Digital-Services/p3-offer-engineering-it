output "postgresql_server_id" {
  value = azurerm_postgresql_flexible_server.postgresql.id
}

output "database_id" {
  value = azurerm_postgresql_flexible_server_database.database.id
}

output "db_url" {
  value = azurerm_postgresql_flexible_server.postgresql.fqdn
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.database.name
}
