variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "demo-6256-6791"
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

variable "admin_ids" {
  type        = list(string)
  description = "List of Azure Active Directory user object IDs that will be added to a new group and granted admin access to the cluster"
}

variable "dns_prefix" {
  type    = string
  default = "spring-petclinic-ms"
}

variable "mysql_aad_admin" {
  type        = string
  description = "Azure AD user to be configured as MySQL admin"
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
