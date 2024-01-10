resource "azurerm_cognitive_account" "openai" {
  name                = "azopenai-${var.suffix}"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location

  custom_subdomain_name         = "azopenai${var.suffix}"
  kind                          = "OpenAI"
  public_network_access_enabled = false
  sku_name                      = "S0"
}

resource "azurerm_cognitive_deployment" "gpt4" {
  name = "live-gpt4"

  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "0613"
  }

  scale {
    type = "Standard"
  }
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = data.azurerm_resource_group.target.name
}

resource "azurerm_private_dns_a_record" "dns_a" {
  name                = azurerm_cognitive_account.openai.custom_subdomain_name
  resource_group_name = data.azurerm_resource_group.target.name

  records   = [azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address]
  ttl       = 10
  zone_name = azurerm_private_dns_zone.dns_zone.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "network_link" {
  name                = "vnet-link"
  resource_group_name = data.azurerm_resource_group.target.name

  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "endpoint" {
  name                = "pe-azopenai-${var.suffix}"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location

  subnet_id = azurerm_subnet.backend.id

  private_service_connection {
    name = "psc-azopenai"

    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
  }
}

