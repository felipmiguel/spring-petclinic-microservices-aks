data "azuread_client_config" "current" {}


locals {
  admin_group_name= "gr-${var.application_name}-admins-${var.environment}"
}

resource "azuread_group" "azuread_group" {
  display_name     = local.admin_group_name
  mail_enabled     = true
  mail_nickname    = local.admin_group_name
  security_enabled = true
  types            = ["Unified"]

  owners = distinct(concat([data.azuread_client_config.current.object_id], var.admin_ids))
}
