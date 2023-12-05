# 1 - Terraform Data Block (Resource Group)
data "azurerm_resource_group" "Desafio03-terraform" {
  name = "DESAFIO03"
}
# 2 - Terraform Local Variables Block
locals {
  subnet_names = ["AppGateway", "Firewall", "Other"]
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
# 3 - Terraform Resource Block (Vnet)
resource "azurerm_virtual_network" "Vnet-module" {
  name                = "Vnet-desafio3"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.Desafio03-terraform.name
  location            = data.azurerm_resource_group.Desafio03-terraform.location
}
resource "azurerm_subnet" "Subnet-module" {
  count                = length(local.subnet_names)
  name                 = local.subnet_names[count.index]
  resource_group_name  = data.azurerm_resource_group.Desafio03-terraform.name
  virtual_network_name = azurerm_virtual_network.Vnet-module.name
  address_prefixes     = [local.subnet_cidrs[count.index]]
}

resource "azurerm_network_security_group" "NSG-module" {
  count               = length(local.subnet_names)
  name                = "nsg-${local.subnet_names[count.index]}"
  resource_group_name = data.azurerm_resource_group.Desafio03-terraform.name
  location            = data.azurerm_resource_group.Desafio03-terraform.location
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