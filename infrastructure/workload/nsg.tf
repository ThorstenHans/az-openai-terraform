
resource "azurerm_network_security_group" "backend" {
  name                = "nsg-backend"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location

  security_rule {
    name = "allow-apps-to-openai-https"

    access                     = "Allow"
    description                = "Allow HTTPS from the apps subnet"
    destination_address_prefix = "${azurerm_private_endpoint.endpoint.private_service_connection.0.private_ip_address}/32"
    destination_port_range     = "443"
    direction                  = "Inbound"
    priority                   = 150
    protocol                   = "Tcp"
    source_address_prefix      = azurerm_subnet.apps.address_prefixes[0]
    source_port_range          = "*"
  }

  security_rule {
    name = "prevent-all"

    access                     = "Deny"
    description                = "Deny all inbound traffic"
    destination_address_prefix = azurerm_subnet.backend.address_prefixes[0]
    destination_port_range     = "443"
    direction                  = "Inbound"
    priority                   = 200
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}



