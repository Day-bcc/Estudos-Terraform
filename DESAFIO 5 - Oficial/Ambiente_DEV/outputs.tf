
# Terraform Output Values Block
output "rg_ids_dev1" {
  value = data.azurerm_resource_group.rg_hub_hub.id
}
output "rg_ids_dev2" {
  value = data.azurerm_resource_group.rg_app_hml.id
}
output "vnet_ids_dev1" {
  value = data.azurerm_virtual_network.vnet_hub_hub.id
}
output "vnet_ids_dev2" {
  value = data.azurerm_virtual_network.vnet_spoke_hml.id
}

