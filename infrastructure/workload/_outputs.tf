output "app_url" {
  value = azurerm_container_app.app.ingress[0].fqdn
}
