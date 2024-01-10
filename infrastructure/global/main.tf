# A random suffix is attached to resources to ensure uniqueness.
resource "random_integer" "suffix" {
  min = 100
  max = 999
}

resource "azurerm_resource_group" "global" {
  name     = "rg-az-openai-${random_integer.suffix.result}"
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = "azopenai${random_integer.suffix.result}"
  resource_group_name = azurerm_resource_group.global.name

  admin_enabled = false
  location      = azurerm_resource_group.global.location
  sku           = "Standard"
}



