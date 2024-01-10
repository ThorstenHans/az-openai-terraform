resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-openai-${var.suffix}"
  resource_group_name = data.azurerm_resource_group.target.name
  location            = data.azurerm_resource_group.target.location

  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "apps" {
  name                = "apps"
  resource_group_name = data.azurerm_resource_group.target.name

  address_prefixes     = ["10.0.4.0/23"]
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "backend" {
  name                = "backend"
  resource_group_name = data.azurerm_resource_group.target.name

  address_prefixes     = ["10.0.2.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
}
