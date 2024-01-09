# Terraform Output Values Block
output "rg_ids_hml1" {
  value = data.azurerm_resource_group.rg-database-dev.id
}
output "rg_ids_hml2" {
  value = data.azurerm_resource_group.rg_hub_hub.id
}
output "vnet_ids_hml1" {
  value = data.azurerm_virtual_network.vnet_hub_hub.id
}
output "vnet_ids_hml2" {
  value = data.azurerm_virtual_network.vnet_spoke_dev.id
}