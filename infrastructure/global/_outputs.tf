output "suffix" {
  value = random_integer.suffix.result
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "resource_group_name" {
  value = azurerm_resource_group.global.name
}
