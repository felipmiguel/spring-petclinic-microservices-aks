variable "resource_group" {
  type        = string
  description = "The resource group"
}

variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
}

variable "appname" {
  description = "Name of the application"
  type        = string
}

variable "namespace" {
  description = "Namespace of the application"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "The issuer URL for the AKS cluster"
  type        = string
}
