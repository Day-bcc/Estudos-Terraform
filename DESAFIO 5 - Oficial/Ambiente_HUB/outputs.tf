# Terraform Output Values Block
output "rg_ids_hub1" {
  value = data.azurerm_resource_group.rg-database-dev.id
}
output "rg_ids_hub2" {
  value = data.azurerm_resource_group.rg_app_hml.id
}
output "rg_ids_hub3" {
  value = data.azurerm_resource_group.rg_data_prd.id
}
output "vnet_ids_hub1" {
  value = data.azurerm_virtual_network.vnet_spoke_hml.id
}
output "vnet_ids_hub2" {
  value = data.azurerm_virtual_network.vnet_spoke_dev.id
}
output "vnet_ids_hub3" {
  value = data.azurerm_virtual_network.vnet_spoke_prd.id
}