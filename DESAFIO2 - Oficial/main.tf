# Create Resource Group
resource "azurerm_resource_group" "rg-desafio2" {
  name     = "rg-desafio2-from-terraform"
  location = "East US"
}

# Resource Group for NSGs
resource "azurerm_resource_group" "rg_nsgs" {
  name     = "rg-nsgs"
  location = azurerm_resource_group.rg-desafio2.location
}

# NSGs and Rules using for_each
resource "azurerm_network_security_group" "nsg" {
  for_each = var.vnets

  name                = each.value.nsg_name
  location            = azurerm_resource_group.rg_nsgs.location
  resource_group_name = azurerm_resource_group.rg_nsgs.name
}
resource "azurerm_network_security_rule" "allow_ssh" {
  for_each = { for k, v in var.vnets : k => v if v.allow_ssh }

  name                        = "allow_ssh_${each.key}"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_nsgs.name
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
}

# Recurso para criar VNets usando count
resource "azurerm_virtual_network" "vnets" {
  count               = length(keys(var.vnets))
  name                = var.vnets[keys(var.vnets)[count.index]].name
  address_space       = [var.vnets[keys(var.vnets)[count.index]].address_space]
  location            = azurerm_resource_group.rg-desafio2.location
  resource_group_name = azurerm_resource_group.rg-desafio2.name
}
# Recurso para criar subnets usando count
resource "azurerm_subnet" "subnet1" {
  count               = length(keys(var.vnets))
  name                = "subnet1-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  virtual_network_name = azurerm_virtual_network.vnets[count.index].name
  address_prefixes     = ["10.${count.index + 1}.1.0/24"]
}

# Recurso para a máquina virtual usando count
resource "azurerm_linux_virtual_machine" "vms" {
  count               = length(keys(var.vnets))
  name                = "vm_${keys(var.vnets)[count.index]}"
  computer_name       = "vm-${count.index + 1}" 
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  location            = azurerm_resource_group.rg-desafio2.location
  size                = "Standard_DS1_v2"

  network_interface_ids  = [azurerm_network_interface.nics[count.index].id]

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

  admin_username = "adminuser2"
  admin_password = "Password12345!"
  disable_password_authentication = false
}

# Recurso para a interface de rede da máquina virtual
resource "azurerm_network_interface" "nics" {
  count               = length(keys(var.vnets))
  name                = "nic_vm_${keys(var.vnets)[count.index]}"
  resource_group_name = azurerm_resource_group.rg-desafio2.name
  location            = azurerm_resource_group.rg-desafio2.location

  ip_configuration {
    name                          = "nic_vm_${keys(var.vnets)[count.index]}_config"
    subnet_id                     = azurerm_subnet.subnet1[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Recurso para o peering entre as VNets com dynamic block
resource "azurerm_virtual_network_peering" "peerings" {
  for_each                       = length(var.vnets) > 1 ? toset(keys(var.vnets)) : toset([])

  name                          = var.vnets[each.key].allow_peering ? "peering_${var.vnets[each.key].name}_to_${var.vnets[element(keys(var.vnets), (index(keys(var.vnets), each.key) + 1) % length(var.vnets))].name}" : null
  resource_group_name           = azurerm_resource_group.rg-desafio2.name
  virtual_network_name          = var.vnets[each.key].name
  remote_virtual_network_id     = var.vnets[each.key].allow_peering ? azurerm_virtual_network.vnets[(index(keys(var.vnets), each.key) + 1) % length(var.vnets)].id : null
  allow_virtual_network_access   = var.vnets[each.key].allow_peering

# Dependência condicional usando null_resource
  depends_on = [null_resource.create_dependencies]

  lifecycle {
    create_before_destroy = true
  }
}

# Recurso null_resource para criar dependências dinâmicas
resource "null_resource" "create_dependencies" {
  count = length(var.vnets) > 1 ? 1 : 0

  triggers = {
    dependencies = jsonencode([for key in tolist(keys(var.vnets)) : var.vnets[key].allow_peering])
  }
}


