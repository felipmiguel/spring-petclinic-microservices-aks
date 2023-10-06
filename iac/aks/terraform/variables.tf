variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "petclinic-alg-93832"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "westeurope"
}

variable "admin_group_id" {
  type        = string
  description = "Existing group Id to be used as AKS admins. If this variable is used `admin_ids` is ignored"
}

variable "admin_ids" {
  type        = list(string)
  description = "List of Azure Active Directory user object IDs that will be added to a new group and granted admin access to the cluster"
}

variable "dns_prefix" {
  type    = string
  default = "spring-petclinic-alg"
}

variable "mysql_aad_admin" {
  type        = string
  description = "Azure AD user to be configured as MySQL admin"
}


