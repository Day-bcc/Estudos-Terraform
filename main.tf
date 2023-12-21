#Criar um grupo de recursos com AzAPI
resource "azapi_resource" "resourceGroup" {
  type                      = "Microsoft.Resources/resourceGroups@2020-06-01"
  parent_id                 = "/subscriptions/038bd2ab-7c4b-4cb1-90f4-8b811c7b3fc7"
  name                      = "RG-DESAFIO04-AZAPI"
  location                  = var.location
}

#Criando minha Infra de redes com AzAPI
resource "azapi_resource" "virtualNetwork" {
  type      = "Microsoft.Network/virtualNetworks@2022-07-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = "Network-desafio04"
  location  = var.location
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = [
          "10.0.0.0/16",
        ]
      }
      dhcpOptions = {
        dnsServers = []
      }
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
  lifecycle {
    ignore_changes = [
      body,
    ]
  }
}

resource "azapi_resource" "subnet" {
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-07-01"
  parent_id = azapi_resource.virtualNetwork.id
  name      = "subnet-desafio04"
  body = jsonencode({
    properties = {
      addressPrefix = "10.0.2.0/24"
    }
  })
   schema_validation_enabled = false
   response_export_values    = ["*"]
}

resource "azapi_resource" "networkInterface" {
  type      = "Microsoft.Network/networkInterfaces@2022-07-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = "ni-desafio04"
  location  = var.location
  body = jsonencode({
    properties = {
      enableAcceleratedNetworking = false
      enableIPForwarding          = false
      ipConfigurations = [
        {
          name = "testconfiguration1"
          properties = {
            primary                   = true
            privateIPAddressVersion   = "IPv4"
            privateIPAllocationMethod = "Dynamic"
            subnet = {
              id = azapi_resource.subnet.id
            }
          }
        },
      ]
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

#Criando uma VM com AzAPI
resource "azapi_resource" "virtualMachine" {
  type      = "Microsoft.Compute/virtualMachines@2022-11-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = "vm-desafio04"
  location  = var.location
  body = jsonencode({
    properties = {
      hardwareProfile = {
        vmSize = "Standard_F2"
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.networkInterface.id
            properties = {
              primary = false
            }
          },
        ]
      }
      osProfile = {
        adminPassword = "Password1234!"
        adminUsername = "testadmin"
        computerName  = "vm-desafio04"
        linuxConfiguration = {
          disablePasswordAuthentication = false
        }
      }
      storageProfile = {
        osDisk = {
          createOption = "FromImage"
          name         = "osdisk1"
          caching      = "ReadWrite"
          managedDisk = {
            storageAccountType = "Standard_LRS"
          }
        }
        imageReference = {
          offer     = "0001-com-ubuntu-server-focal"
          publisher = "Canonical"
          sku       = "20_04-lts"
          version   = "latest"
        }
      }
    }
  })
  schema_validation_enabled = true
  response_export_values    = ["*"]
}

#Desligando a VM com AzApi
resource "azapi_resource_action" "stop" {
  type                   = "Microsoft.Compute/virtualMachines@2022-11-01"
  resource_id            = azapi_resource.virtualMachine.id
  action                 = "stop"
  response_export_values = ["*"]

  count = var.enabled ? 0 : 1
}

#Criar o Storage Account com AzAPI
resource "azapi_resource" "storageAccount" {
  type      = "Microsoft.Storage/storageAccounts@2021-09-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = "sadesafio04"
  location  = var.location
  body = jsonencode({
    identity = {
      type = "None"
    }
    kind = "StorageV2"
    properties = {
      accessTier                   = "Hot"
      allowBlobPublicAccess        = true
      allowCrossTenantReplication  = true
      allowSharedKeyAccess         = true
      defaultToOAuthAuthentication = false
      encryption = {
        keySource = "Microsoft.Storage"
        services = {
          queue = {
            keyType = "Service"
          }
          table = {
            keyType = "Service"
          }
        }
      }
      isHnsEnabled      = false
      isNfsV3Enabled    = false
      isSftpEnabled     = false
      minimumTlsVersion = "TLS1_2"
      networkAcls = {
        defaultAction = "Allow"
      }
      publicNetworkAccess      = "Enabled"
      supportsHttpsTrafficOnly = true
    }
    sku = {
      name = "Standard_LRS"
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

#Desabilitar o Acesso Público do Storage Account com AzAPI
resource "azapi_update_resource" "AcessPublicSA" {
  type      = "Microsoft.Storage/storageAccounts@2021-09-01"
  resource_id = azapi_resource.storageAccount.id

  body = jsonencode({
    properties = {
      networkAcls = {
        defaultAction = "Allow"
      }
      publicNetworkAccess      = "Disabled"
    }
  })
}
