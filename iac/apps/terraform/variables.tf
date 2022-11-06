variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "demo-6256-6791"
}

variable "resource_group" {
  type        = string
  description = "The resource group"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "eastus"
}

variable "apps" {
  type        = list(string)
  description = "List of applications to deploy"
  default     = ["customer-service", "vets-service", "visits-service"]
}

variable "apps_namespace" {
  type    = string
  default = "spring-petclinic"
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
}

variable "database_url" {
  description = "The JDBC URL to connect to the MySQL database"
}