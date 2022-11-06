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

resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = var.appname
    namespace = var.namespace
  }

  spec {
    selector {
      match_labels = {
        app = var.appname
      }
    }
    template {
      metadata {
        labels = {
          app = var.appname
        }
      }
      spec {
        service_account_name = kubernetes_service_account.service_account.metadata[0].name
        container {
          name  = var.appname
          image = var.image
          
          env {
            name  = "SPRING_DATASOURCE_AZURE_PASSWORDLESSENABLED"
            value = "true"
          }
          env {
            name  = "SPRING_DATASOURCE_AZURE_URL"
            value = var.database_url
          }
          liveness_probe {
            http_get {
              path = "/actuator/health"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }
        }
      }
      
    }
  }
  
}
