resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-azopenai-${var.suffix}"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location

  sku = "PerGB2018"
}
