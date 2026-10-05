terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  alias           = "c1"
  client_id       = "REPLACE_WITH_CLIENT_ID_1"
  client_secret   = "REPLACE_WITH_CLIENT_SECRET_1"
  tenant_id       = "REPLACE_WITH_TENANT_ID_1"
  subscription_id = "REPLACE_WITH_SUBSCRIPTION_ID_1"
  features {}
}

provider "azurerm" {
  alias           = "c2"
  client_id       = "REPLACE_WITH_CLIENT_ID_2"
  client_secret   = "REPLACE_WITH_CLIENT_SECRET_2"
  tenant_id       = "REPLACE_WITH_TENANT_ID_2"
  subscription_id = "REPLACE_WITH_SUBSCRIPTION_ID_2"
  features {}
}