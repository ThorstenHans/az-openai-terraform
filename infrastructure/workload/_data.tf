data "azurerm_resource_group" "target" {
  name = var.target_resource_group_name
}

data "azurerm_container_registry" "target" {
  name                = var.target_acr_name
  resource_group_name = var.target_resource_group_name
}







