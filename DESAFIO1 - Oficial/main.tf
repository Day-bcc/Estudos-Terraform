# Configuração do provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
      resource_group_name  = "rg-terraform-desafio1"
      storage_account_name = "sadesafio1"
      container_name       = "tfstatedesafio1"
      key                  = "terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

# Cria o grupo de recursos do projeto
resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = "eastus2"
}


# Identificação randomica
resource "random_string" "random" {
  length  = 5
  special = false
  upper   = false
}