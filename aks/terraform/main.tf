terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.11.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.16"
    }
    azapi = {
      source = "azure/azapi"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.15.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "fmigueltfstate"
    container_name       = "springstate"
    key                  = "terraform.tfstate"
  }
}

provider "azapi" {
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

provider "kubernetes" {
  host                   = module.service.cluster_fqdn
  client_certificate     = base64decode(module.service.client_certificate)
  client_key             = base64decode(module.service.client_key)
  cluster_ca_certificate = base64decode(module.service.cluster_ca_certificate)
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
  aks_rbac_admin_group_object_id = module.admins.admin_group_id
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


module "admins" {
  source           = "./modules/admins"
  application_name = var.application_name
  environment      = local.environment
  admin_ids        = var.admin_ids
}

resource "kubernetes_namespace" "app_namepsace" {
  metadata {
    name = var.apps_namespace
    labels = {
      "environment" = var.environment
      "app"         = var.application_name
    }
  }
}

module "k8s_apps" {
  count               = length(var.apps)
  source              = "./modules/k8s-app"
  resource_group      = azurerm_resource_group.main.name
  application_name    = var.application_name
  environment         = local.environment
  location            = var.location
  appname             = var.apps[count.index]
  namespace           = kubernetes_namespace.app_namepsace.metadata[0].name
  aks_oidc_issuer_url = module.service.oidc_issuer_url
}
