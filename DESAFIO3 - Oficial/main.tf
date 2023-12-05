resource "azurerm_resource_group" "Desafio03-terraform" {
  name     = var.resource_group_name
  location = "East US"
}

# Terraform Modules Block (Exemplo de utilização de módulo)
module "network_module" {
  source = "./network_module"
}

# Terraform Output Values Block
output "network_account_id" {
  value = module.network_module.network_account_id
}
