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
    resource_group_name  = "rg-terraformstate"
    storage_account_name = "terraformstate26020"
    container_name       = "appstate"
    key                  = "terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.resource_group
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.fqdn
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
}

provider "azapi" {
}

provider "azurerm" {
  features {}
}

provider "azuread" {
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

locals {
  // If an environment is set up (dev, test, prod...), it is used in the application name
  environment = var.environment == "" ? "dev" : var.environment
}

module "k8s_apps" {
  count               = length(var.apps)
  source              = "./modules/k8s-app"
  resource_group      = var.resource_group
  application_name    = var.application_name
  environment         = local.environment
  location            = var.location
  appname             = var.apps[count.index]
  namespace           = kubernetes_namespace.app_namepsace.metadata[0].name
  aks_oidc_issuer_url = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  database_url        = var.database_url
}
