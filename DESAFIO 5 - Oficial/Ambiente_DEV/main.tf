#Criando RG
resource "azurerm_resource_group" "rg-database-dev" {
  name = "rg-database"
  location = "East US"
}

#Virtual Network
resource "azurerm_virtual_network" "vnet_spoke_dev" {
  name                = "vnet-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-database-dev.location
  resource_group_name = azurerm_resource_group.rg-database-dev.name
}

#Subnet para o banco de dados
resource "azurerm_subnet" "snet_db_001_dev" {
  name                 = "snet-db-001"
  resource_group_name  = azurerm_resource_group.rg-database-dev.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke_dev.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

#Network Security Group
resource "azurerm_network_security_group" "nsg_dev_001" {
  name                = "nsg-dev-001"
  location            = azurerm_resource_group.rg-database-dev.location
  resource_group_name = azurerm_resource_group.rg-database-dev.name
}

resource "azurerm_network_security_rule" "allow_sqlin" {
  name                        = "AllowSQL"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-database-dev.name
  network_security_group_name = azurerm_network_security_group.nsg_dev_001.name
}
resource "azurerm_network_security_rule" "allow_sqlout" {
  name                        = "AllowSQL"
  priority                    = 1002
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-database-dev.name
  network_security_group_name = azurerm_network_security_group.nsg_dev_001.name
}

#SQL Database
resource "azurerm_mssql_server" "mssql_db_server" {
  name                         = "mssqldbserver"
  resource_group_name          = azurerm_resource_group.rg-database-dev.name
  location                     = azurerm_resource_group.rg-database-dev.location
  version                      = "12.0" 
  administrator_login          = "day_admin"
  administrator_login_password = "dayadmin@123456"
 
  tags = {
    environment = "DEV"
  }
}

resource "azurerm_mssql_database" "mssql_database" {
  name           = "mssqldatabase"
  server_id      = azurerm_mssql_server.mssql_db_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 4
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = true
  enclave_type   = "VBS"

  #prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    environment = "DEV"
  }

}

#Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "private_endpoint_sql" {
  name                = "private-endpoint-sql"
  resource_group_name = azurerm_resource_group.rg-database-dev.name
  location            = azurerm_resource_group.rg-database-dev.location
  subnet_id           = azurerm_subnet.snet_db_001_dev.id

#Desabilitando o acesso externo do BD
  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.mssql_db_server.id
    is_manual_connection           = false
  }
}

#Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "private_dns_sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg-database-dev.name
}

#Link Private DNS Zone to Private Endpoint
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_sql" {
  name                  = "dns-link-sql"
  resource_group_name   = azurerm_resource_group.rg-database-dev.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_sql.name
  virtual_network_id    = azurerm_virtual_network.vnet_spoke_dev.id
}

data "azurerm_resource_group" "rg_app_hml" {
  name                 = "rg-app"
}
data "azurerm_resource_group" "rg_hub_hub" {
  name                 = "rg-hub"
}
data "azurerm_virtual_network" "vnet_spoke_hml" {
  name                 = "vnet-hml"
  resource_group_name  = "rg_app_hml"
}
data "azurerm_virtual_network" "vnet_hub_hub" {
  name                 = "vnet-hub"
  resource_group_name  = "rg_hub_hub"
}

#Peering entre DEV e HML
resource "azurerm_virtual_network_peering" "peering_dev_to_hml" {
  name                        = "dev-to-hml"
  resource_group_name         = azurerm_resource_group.rg-database-dev.name
  virtual_network_name        = azurerm_virtual_network.vnet_spoke_dev.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_spoke_hml.id
  depends_on                = [data.azurerm_virtual_network.vnet_spoke_hml]
}

#Peering ambiente de DEV para HUB
resource "azurerm_virtual_network_peering" "peering_dev_to_hub" {
  name                        = "peering-dev-to-hub"
  resource_group_name         = azurerm_resource_group.rg-database-dev.name
  virtual_network_name        = azurerm_virtual_network.vnet_spoke_dev.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_hub_hub.id
  depends_on                = [data.azurerm_virtual_network.vnet_hub_hub]
}

