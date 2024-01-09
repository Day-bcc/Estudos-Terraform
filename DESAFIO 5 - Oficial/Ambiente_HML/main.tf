# Criação do grupo de recursos para o ambiente de HML
resource "azurerm_resource_group" "rg_app_hml" {
  name     = "rg-app"
  location = "East US"  
}

# Criação da máquina virtual no ambiente de HML
resource "azurerm_virtual_machine" "vm_app" {
  name                  = "vm-app-001"
  resource_group_name   = azurerm_resource_group.rg_app_hml.name
  location              = azurerm_resource_group.rg_app_hml.location
  vm_size               = "Standard_DS2_v2" 
  network_interface_ids = [azurerm_network_interface.nic_hml.id]
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
    computer_name  = "vmapp001"
    admin_username = "hml_admin"
    admin_password = "hmladmin@123456"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "HML"
  }
}

# Criação da interface de rede no ambiente de HML
resource "azurerm_network_interface" "nic_hml" {
  name                      = "nic-hml-001"
  resource_group_name       = azurerm_resource_group.rg_app_hml.name
  location                  = azurerm_resource_group.rg_app_hml.location
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "ipconfig-hml-001"
    subnet_id                     = azurerm_subnet.snet_app_hml.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Criação da rede virtual e da sub-rede no ambiente de HML
resource "azurerm_virtual_network" "vnet_spoke_hml" {
  name                = "vnet-hml"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg_app_hml.location
  resource_group_name = azurerm_resource_group.rg_app_hml.name
}
resource "azurerm_subnet" "snet_app_hml" {
  name                 = "snet-app-001"
  resource_group_name  = azurerm_resource_group.rg_app_hml.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke_hml.name
  address_prefixes     = ["10.2.1.0/24"]
}

# Criação do NSG (Network Security Group) no ambiente de HML
resource "azurerm_network_security_group" "nsg_hml_001" {
  name                = "nsg-hml-001"
  location            = azurerm_resource_group.rg_app_hml.location
  resource_group_name = azurerm_resource_group.rg_app_hml.name
}

# Adicionar regra para permitir SSH (porta 22)
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_app_hml.name
  network_security_group_name = azurerm_network_security_group.nsg_hml_001.name
}
data "azurerm_resource_group" "rg-database-dev" {
  name                 = "rg-database"
}
data "azurerm_resource_group" "rg_hub_hub" {
  name                 = "rg-hub"
}
data "azurerm_virtual_network" "vnet_spoke_dev" {
  name                 = "vnet-dev"
  resource_group_name  = "rg-database-dev"
}
data "azurerm_virtual_network" "vnet_hub_hub" {
  name                 = "vnet-hub"
  resource_group_name  = "rg_hub_hub"
}

# Peering de HML para DEV
resource "azurerm_virtual_network_peering" "peering_hml_to_dev" {
  name                        = "peering-hml-to-dev"
  resource_group_name         = azurerm_resource_group.rg_app_hml.name
  virtual_network_name        = azurerm_virtual_network.vnet_spoke_hml.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_spoke_dev.id
  depends_on                = [data.azurerm_virtual_network.vnet_spoke_dev]
}

# Peering ambiente de HML para HUB
resource "azurerm_virtual_network_peering" "peering_hml_to_hub" {
  name                        = "peering-hml-to-hub"
  resource_group_name         = azurerm_resource_group.rg_app_hml.name
  virtual_network_name        = azurerm_virtual_network.vnet_spoke_hml.name
  remote_virtual_network_id   = data.azurerm_virtual_network.vnet_hub_hub.id
  depends_on                = [data.azurerm_virtual_network.vnet_hub_hub]
}

