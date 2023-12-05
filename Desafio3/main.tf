resource "azurerm_resource_group" "Desafio03-terraform" {
  name     = var.resource_group_name
  location = "East US"
}
# Terraform Modules Block (Exemplo de utilização de módulo)
#module "storage_module" {
# source = "./storage_module"
#}

# Terraform Output Values Block
#output "storage_account_id" {
# value = module.storage_module.storage_account_id
#}
