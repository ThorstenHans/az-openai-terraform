resource "azurerm_user_assigned_identity" "acapull" {
  name                = "id-aca-app"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location
}

resource "azurerm_role_assignment" "acrpull" {
  scope                = data.azurerm_container_registry.target.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acapull.principal_id
}
