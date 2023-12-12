#Criando RG
resource "azurerm_resource_group" "Desafio03-terraform" {
  name = var.resource_group_name
  location = "East US"
}
#Criando Key Vault e o Acces Policy
resource "azurerm_key_vault" "KeyVault1-Desafio03" {
  name                = "kv-labdesafio3"
  resource_group_name = azurerm_resource_group.Desafio03-terraform.name
  location            = azurerm_resource_group.Desafio03-terraform.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]
  }
}
resource "azurerm_key_vault_secret" "sa" {
  name         = "sakvsecret"
  value        = "labdesafio3"
  key_vault_id = azurerm_key_vault.KeyVault1-Desafio03.id
}

#Criando o Storage Account
resource "azurerm_storage_account" "desafio03sa-terrafom" {
  name                     = "storagedesafio03"
  resource_group_name      = azurerm_resource_group.Desafio03-terraform.name
  location                 = azurerm_resource_group.Desafio03-terraform.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

depends_on = [
    azurerm_resource_group.Desafio03-terraform
  ]
} 

# Terraform Modules de network
module "network_module" {
  source = "./network_module"
}
# Terraform Output Values Block
output "network_account_id" {
  value = module.network_module.network_account_id
}
