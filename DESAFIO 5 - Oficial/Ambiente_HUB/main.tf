# Criando RG para o ambiente do HUB
resource "azurerm_resource_group" "rg_hub_hub" {
  name     = "rg-hub"
  location = "East US" 
}

# Criando a máquina virtual no ambiente do HUB
resource "azurerm_virtual_machine" "vm_hub" {
  name                  = "vm-hub-001"
  resource_group_name   = azurerm_resource_group.rg_hub_hub.name
  location              = azurerm_resource_group.rg_hub_hub.location
  vm_size               = "Standard_DS2_v2" 
  network_interface_ids = [azurerm_network_interface.nic_hub.id]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "vmhub001"
    admin_username = "hub_admin"
    admin_password = "hubadmin@123456"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "HUB"
  }
}

# Criando a interface de rede no ambiente do HUB
resource "azurerm_network_interface" "nic_hub" {
  name                      = "nic-hub-001"
  resource_group_name       = azurerm_resource_group.rg_hub_hub.name
  location                  = azurerm_resource_group.rg_hub_hub.location
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "ipconfig-hub-001"
    subnet_id                     = azurerm_subnet.snet_hub.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Criando a rede virtual e a sub-rede no ambiente do HUB
resource "azurerm_virtual_network" "vnet_hub_hub" {
  name                = "vnet-hub"
  address_space       = ["10.4.0.0/16"]
  location            = azurerm_resource_group.rg_hub_hub.location
  resource_group_name = azurerm_resource_group.rg_hub_hub.name
}

resource "azurerm_subnet" "snet_hub" {
  name                 = "snet-hub-001"
  resource_group_name  = azurerm_resource_group.rg_hub_hub.name
  virtual_network_name = azurerm_virtual_network.vnet_hub_hub.name
  address_prefixes     = ["10.4.1.0/24"]
}

data "azurerm_subnet" "snet_app_hml" {
  name                 = "snet-app-001"
  virtual_network_name = "vnet_spoke_hml"
  resource_group_name  = "rg_app_hml"
}

data "azurerm_subnet" "snet_db_001_dev" {
  name                 = "snet-db-001"
  virtual_network_name = "vnet_spoke_dev"
  resource_group_name  = "rg-database-dev"
}

data "azurerm_subnet" "snet_data_001" {
  name                 = "snet-data"
  virtual_network_name = "vnet_spoke_prd"
  resource_group_name  = "rg_data_prd"
}

# Criando o NSG (Network Security Group) no ambiente do HUB
resource "azurerm_network_security_group" "nsg_hub_001" {
  name                = "nsg-hub-001"
  location            = azurerm_resource_group.rg_hub_hub.location
  resource_group_name = azurerm_resource_group.rg_hub_hub.name
}

#Permitir tráfego de entrada na porta 22 (SSH) da VM de HML
resource "azurerm_network_security_rule" "allow_ssh_from_hub_to_hml" {
  name                        = "AllowSSHFromHubToHML"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.snet_hub.address_prefixes[0]
  destination_address_prefix  = data.azurerm_subnet.snet_app_hml.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.rg_hub_hub.name
  network_security_group_name = azurerm_network_security_group.nsg_hub_001.name
}

#Criando regra para permitir comunicação com o File Share de PRD na porta 445
resource "azurerm_network_security_rule" "allow_hub_to_prd_file_share" {
  name                        = "AllowHubToPRDFileShare"
  priority                    = 1002
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = azurerm_subnet.snet_hub.address_prefixes[0]
  destination_address_prefix  = data.azurerm_subnet.snet_data_001.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.rg_hub_hub.name
  network_security_group_name = azurerm_network_security_group.nsg_hub_001.name
}
#Criando regra para permitir comunicação com o banco de dados DEV
resource "azurerm_network_security_rule" "allow_hub_to_database" {
  name                        = "AllowHubToDatabase"
  priority                    = 1003
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433" 
  source_address_prefix       = azurerm_subnet.snet_hub.address_prefixes[0]
  destination_address_prefix  = data.azurerm_subnet.snet_db_001_dev.address_prefixes[0] 
  resource_group_name         = azurerm_resource_group.rg_hub_hub.name
  network_security_group_name = azurerm_network_security_group.nsg_hub_001.name
}
data "azurerm_resource_group" "rg-database-dev" {
  name                 = "rg-database"
}
data "azurerm_resource_group" "rg_app_hml" {
  name                 = "rg-app"
}
data "azurerm_resource_group" "rg_data_prd" {
  name                 = "rg-data"
}
data "azurerm_virtual_network" "vnet_spoke_dev" {
  name                 = "vnet-dev"
  resource_group_name  = "rg-database-dev"
}
data "azurerm_virtual_network" "vnet_spoke_hml" {
  name                 = "vnet-hml"
  resource_group_name  = "rg_app_hml"
}
data "azurerm_virtual_network" "vnet_spoke_prd" {
  name                 = "vnet-prd"
  resource_group_name  = "rg_data_prd"
}

# Criando peering HUB para DEV
resource "azurerm_virtual_network_peering" "peering_hub_to_dev" {
  name                        = "peering-hub-to-dev"
  resource_group_name         = azurerm_resource_group.rg_hub_hub.name
  virtual_network_name        = azurerm_virtual_network.vnet_hub_hub.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_spoke_dev.id
  depends_on                = [data.azurerm_virtual_network.vnet_spoke_dev]
}

# Criando peering HUB para HML
resource "azurerm_virtual_network_peering" "peering_hub_to_hml" {
  name                        = "peering-hub-to-hml"
  resource_group_name         = azurerm_resource_group.rg_hub_hub.name
  virtual_network_name        = azurerm_virtual_network.vnet_hub_hub.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_spoke_hml.id
  depends_on                = [data.azurerm_virtual_network.vnet_spoke_hml]
}

# Criando peering HUB para PRD
resource "azurerm_virtual_network_peering" "peering_hub_to_prd" {
  name                        = "peering-hub-to-prd"
  resource_group_name         = azurerm_resource_group.rg_hub_hub.name
  virtual_network_name        = azurerm_virtual_network.vnet_hub_hub.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_spoke_prd.id
  depends_on                = [data.azurerm_virtual_network.vnet_spoke_prd]
}