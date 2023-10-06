terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-fm-tfsate"
    storage_account_name = "fmtfstate11856"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}



locals {
  // If an environment is set up (dev, test, prod...), it is used in the application name
  environment = var.environment == "" ? "dev" : var.environment
}

resource "azurecaf_name" "resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = [local.environment]
}

resource "azurerm_resource_group" "main" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform"        = "true"
    "environment"      = local.environment
    "application-name" = var.application_name
    "nubesgen-version" = "0.13.0"
  }
}

module "service" {
  source                         = "./modules/aks"
  resource_group                 = azurerm_resource_group.main.name
  application_name               = var.application_name
  environment                    = local.environment
  location                       = var.location
  acr_id                         = module.acr.acr_id
  aks_rbac_admin_group_object_id = local.admin_group_id
  dns_prefix                     = var.dns_prefix
}

module "database" {
  source           = "./modules/mysql"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
  mysql_aad_admin  = var.mysql_aad_admin
}

module "application-insights" {
  source           = "./modules/application-insights"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
}

module "acr" {
  source           = "./modules/acr"
  resource_group   = azurerm_resource_group.main.name
  application_name = var.application_name
  environment      = local.environment
  location         = var.location
}

locals {
  admin_group_id = var.admin_group_id
}

# locals {
#   admin_group_id = length(var.admin_group_id) > 0 ? var.admin_group_id : module.admins[0].admin_group_id
# }
# module "admins" {
#   count            = length(var.admin_group_id) == 0 ? 0 : 1
#   source           = "./modules/admins"
#   application_name = var.application_name
#   environment      = local.environment
#   admin_ids        = var.admin_ids
# }

