# Create Resource Group
resource "azurerm_resource_group" "rg-desafio2" {
  name     = "rg-desafio2-from-terraform"
  location = "East US"
}

# Recurso para a primeira VNet
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg-desafio2.location
  resource_group_name = azurerm_resource_group.rg-desafio2.name
}

# Recurso para a subnet da primeira SubNet
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg-desafio2.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Recurso para o NSG associado à subnet1
resource "azurerm_network_security_group" "nsg_subnet1" {
  name                = "nsg_subnet1"
  location            = azurerm_resource_group.rg-desafio2.location
  resource_group_name = azurerm_resource_group.rg-desafio2.name
}

# Regras do NSG para a subnet1
resource "azurerm_network_security_rule" "allow_ssh_subnet1" {
  name                        = "allow_ssh_subnet1"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-desafio2.name
  network_security_group_name = azurerm_network_security_group.nsg_subnet1.name
}

# Recurso para a segunda VNet
resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg-desafio2.location
  resource_group_name = azurerm_resource_group.rg-desafio2.name
}

# Recurso para a subnet da segunda VNet
resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg-desafio2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.2.1.0/24"]
}

# Recurso para o NSG associado à subnet2
resource "azurerm_network_security_group" "nsg_subnet2" {
  name                = "nsg_subnet2"
  location            = azurerm_resource_group.rg-desafio2.location
  resource_group_name = azurerm_resource_group.rg-desafio2.name
}

# Regras do NSG para a subnet2
resource "azurerm_network_security_rule" "allow_ssh_subnet2" {
  name                        = "allow_ssh_subnet2"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-desafio2.name
  network_security_group_name = azurerm_network_security_group.nsg_subnet2.name
}

# Recurso para a primeira máquina virtual
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm1"
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  location            = azurerm_resource_group.rg-desafio2.location
  size                = "Standard_DS1_v2"

  network_interface_ids = [azurerm_network_interface.nic_vm1.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_virtual_network_peering.peering_vnet1_to_vnet2,
  ]
  admin_username = "adminuser2"
  admin_password ="Password12345!" 
  disable_password_authentication = false
}

# Recurso para a interface de rede da máquina virtual 1
resource "azurerm_network_interface" "nic_vm1" {
  name                = "nic_vm1"
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  location            = azurerm_resource_group.rg-desafio2.location

  ip_configuration {
    name                          = "nic_vm1_config"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Recurso para a segunda máquina virtual
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm2"
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  location            = azurerm_resource_group.rg-desafio2.location
  network_interface_ids = [azurerm_network_interface.nic_vm2.id]
  size                = "Standard_DS1_v2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  depends_on = [
    azurerm_virtual_network_peering.peering_vnet2_to_vnet1,
  ]
    admin_username = "adminuser2"
    admin_password ="Password12345!"
    disable_password_authentication = false

  tags = {
    environment = "desafio2"
    provisioner = "terraform"
  }
}

# Recurso para a interface de rede da máquina virtual 2
resource "azurerm_network_interface" "nic_vm2" {
  name                = "nic_vm2"
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  location            = azurerm_resource_group.rg-desafio2.location

  ip_configuration {
    name                          = "nic_vm2_config"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Recurso para peering entre as VNets
resource "azurerm_virtual_network_peering" "peering_vnet1_to_vnet2" {
  name                        = "peering_vnet1_to_vnet2"
  resource_group_name         = azurerm_resource_group.rg-desafio2.name
  virtual_network_name        = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id   = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
}
resource "azurerm_virtual_network_peering" "peering_vnet2_to_vnet1" {
  name                        = "peering_vnet2_to_vnet1"
  resource_group_name         = azurerm_resource_group.rg-desafio2.name
  virtual_network_name        = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id   = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
}