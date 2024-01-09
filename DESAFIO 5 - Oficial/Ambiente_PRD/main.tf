#Criando o grupo de recursos para o ambiente de PRD
resource "azurerm_resource_group" "rg_data_prd" {
  name     = "rg-data"
  location = "East US" 
}

#Criando o Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                     = "storage001"
  resource_group_name      = azurerm_resource_group.rg_data_prd.name
  location                 = azurerm_resource_group.rg_data_prd.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
}

#Criando o File Share
resource "azurerm_storage_share" "file_share" {
  name                 = "fileshare"
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 1024
}

#Criando a rede virtual e a sub-rede no ambiente de PRD
resource "azurerm_virtual_network" "vnet_spoke_prd" {
  name                = "vnet-prd"
  address_space       = ["10.3.0.0/16"]
  location            = azurerm_resource_group.rg_data_prd.location
  resource_group_name = azurerm_resource_group.rg_data_prd.name
}

resource "azurerm_subnet" "snet_data_001" {
  name                 = "snet-data"
  resource_group_name  = azurerm_resource_group.rg_data_prd.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke_prd.name
  address_prefixes     = ["10.3.1.0/24"]
}

#Criando o NSG (Network Security Group) no ambiente de PRD
resource "azurerm_network_security_group" "nsg_prd_001" {
  name                = "nsg-prd-001"
  location            = azurerm_resource_group.rg_data_prd.location
  resource_group_name = azurerm_resource_group.rg_data_prd.name
}

#Permitir tráfego de entrada na porta 445 (SMB)
resource "azurerm_network_security_rule" "allow_smb" {
  name                        = "AllowSMB"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_data_prd.name
  network_security_group_name = azurerm_network_security_group.nsg_prd_001.name
}

#Criando Private Endpoint para o Storage Account
resource "azurerm_private_endpoint" "private_endpoint_storage" {
  name                = "private-endpoint-storage"
  resource_group_name = azurerm_resource_group.rg_data_prd.name
  location            = azurerm_resource_group.rg_data_prd.location
  subnet_id           = azurerm_subnet.snet_data_001.id

  private_service_connection {
    name                           = "storage-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = false
  }
}

#Criando Private DNS Zone para o Storage Account
resource "azurerm_private_dns_zone" "private_dns_storage" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_data_prd.name
}

#Link Private DNS Zone ao Private Endpoint
resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_link_storage" {
  name                   = "dns-link-storage"
  resource_group_name    = azurerm_resource_group.rg_data_prd.name
  private_dns_zone_name  = azurerm_private_dns_zone.private_dns_storage.id
  virtual_network_id     = azurerm_virtual_network.vnet_spoke_prd.id
}
data "azurerm_resource_group" "rg_hub_hub" {
  name                 = "rg-hub"
}
data "azurerm_virtual_network" "vnet_hub_hub" {
  name                 = "vnet-hub"
  resource_group_name  = "rg_hub_hub"
}

# Peering ambiente de PRD para HUB
resource "azurerm_virtual_network_peering" "peering_prd_to_hub" {
  name                        = "peering-prd-to-hub"
  resource_group_name         = azurerm_resource_group.rg_data_prd.name
  virtual_network_name        = azurerm_virtual_network.vnet_spoke_prd.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_hub_hub.id
  depends_on                = [data.azurerm_virtual_network.vnet_hub_hub]
}

