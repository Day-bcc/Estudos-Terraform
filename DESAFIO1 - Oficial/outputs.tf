output "sa-info-nome" {
  value = azurerm_storage_account.sa.name
}


output "postgresql-info-nome" {
  value = azurerm_postgresql_server.postgresql.name
}