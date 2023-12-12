#Criando RG
resource "azurerm_resource_group" "LabDesafio03" {
  name = "rg-desafio3-network"
  location = "East US"
}

#Criando Vnet
resource "azurerm_virtual_network" "Vnet-module" {
  name                = "Vnet-desafio3"
  address_space       = ["10.0.0.0/8"]
  resource_group_name = azurerm_resource_group.LabDesafio03.name
  location            = azurerm_resource_group.LabDesafio03.location
}

#Criando Subnet usando a função CIDRSubnet
resource "azurerm_subnet" "Subnet-module" {
  count                = length(local.subnet_names)
  name                 = local.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.LabDesafio03.name
  virtual_network_name = azurerm_virtual_network.Vnet-module.name
  address_prefixes     = [cidrsubnet(local.subnet_cidr_base, 16, count.index + 8)]
}

#Criando NSG
resource "azurerm_network_security_group" "NSG-module" {
  count               = length(local.subnet_names)
  name                = "nsg-${local.subnet_names[count.index]}"
  resource_group_name = azurerm_resource_group.LabDesafio03.name
  location            = azurerm_resource_group.LabDesafio03.location
}

resource "azurerm_subnet_network_security_group_association" "Sub-NSG-Ass" {
  count                 = length(local.subnet_names)
  subnet_id             = azurerm_subnet.Subnet-module[count.index].id
  network_security_group_id = azurerm_network_security_group.NSG-module[count.index].id
}
# Terraform Output Values Block
output "network_account_id" {
  value = azurerm_virtual_network.Vnet-module.id
}