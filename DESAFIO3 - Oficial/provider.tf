terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83.0"
    }
}
backend "azurerm" {
      resource_group_name  = "DESAFIO03"
      storage_account_name = "desafio03sa"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
}
}
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}