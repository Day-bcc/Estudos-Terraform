# Terraform Output Values Block
output "rg_ids_prd" {
  value = data.azurerm_resource_group.rg_hub_hub.id
}
output "vnet_ids_prd" {
  value = data.azurerm_virtual_network.vnet_hub_hub.id
}