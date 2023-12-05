resource "azurerm_key_vault" "KeyVault-Desafio03" {
  name                = "kv-desafio3"
  location            = azurerm_resource_group.Desafio03-terraform.location
  resource_group_name = azurerm_resource_group.Desafio03-terraform.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = true
}

resource "azurerm_key_vault_access_policy" "storage" {
  key_vault_id = azurerm_key_vault.KeyVault-Desafio03.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_storage_account.desafio03sa-terrafom.identity[0].principal_id

  secret_permissions = ["Get"]
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]
}

resource "azurerm_key_vault_access_policy" "client" {
  key_vault_id = azurerm_key_vault.KeyVault-Desafio03.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get"]
  key_permissions = [
    "Get",
    "Create",
    "Delete",
    "List",
    "Restore",
    "Recover",
    "UnwrapKey",
    "WrapKey",
    "Purge",
    "Encrypt",
    "Decrypt",
    "Sign",
    "Verify",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
}

resource "azurerm_key_vault_key" "Desafio03-KVkey-terraform" {
  name         = "Desafio03-KVkey"
  key_vault_id = azurerm_key_vault.KeyVault-Desafio03.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.client,
    azurerm_key_vault_access_policy.storage
  ]
}
resource "azurerm_storage_account" "desafio03sa-terrafom" {
  name                     = "desafio03sa"
  resource_group_name      = azurerm_resource_group.Desafio03-terraform.name
  location                 = azurerm_resource_group.Desafio03-terraform.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

resource "azurerm_storage_account_customer_managed_key" "DESAFIO03-sacmk" {
  storage_account_id = azurerm_storage_account.desafio03sa-terrafom.id
  key_vault_id       = azurerm_key_vault.KeyVault-Desafio03.id
  key_name           = azurerm_key_vault_key.Desafio03-KVkey-terraform.name
}
