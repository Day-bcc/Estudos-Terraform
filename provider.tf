terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "=1.11.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.83.0"
    }
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
