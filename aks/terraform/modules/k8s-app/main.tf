terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.16"
    }
    azapi = {
      source  = "azure/azapi"
    }
  }
}

resource "azurecaf_name" "app_umi" {
  name          = var.appname
  resource_type = "azurerm_user_assigned_identity"
  suffixes      = [var.environment, "micro"]
}

resource "azurerm_user_assigned_identity" "app_umi" {
  name                = azurecaf_name.app_umi.result
  resource_group_name = var.resource_group
  location            = var.location
}

resource "kubernetes_service_account" "service_account" {
  metadata {
    name      = var.appname
    namespace = var.namespace
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.app_umi.client_id
    }
    labels = {
      "azure.workload.identity/use" = "true"
    }
  }
}

resource "azapi_resource" "federated_credential" {
  type = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2022-01-31-preview"
  name = "fc-${var.appname}"
  parent_id = azurerm_user_assigned_identity.app_umi.id
  body = jsonencode({
    properties = {
        audiences = ["api://AzureADTokenExchange"]
        issuer = var.aks_oidc_issuer_url
        subject = "system:serviceaccount:${var.namespace}:${var.appname}"        
    }
  })  
}

# resource "azuread_application_federated_identity_credential" "federated_credential" {
#   application_object_id = azurerm_user_assigned_identity.app_umi.id
#   display_name          = var.appname
#   audiences             = ["api://AzureADTokenExchange"]
#   issuer                = var.aks_oidc_issuer_url
#   subject               = "system:serviceaccount:${var.namespace}:${var.appname}"
# }
