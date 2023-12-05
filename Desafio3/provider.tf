terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83.0"
    }
  }

}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}