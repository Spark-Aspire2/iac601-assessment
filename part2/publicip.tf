
### Public  IP Address ###############
resource "azurerm_public_ip" "public_ip_1" {
  name                = var.public_ip_1_name
  resource_group_name = azurerm_resource_group.rg_block.name
  location            = azurerm_resource_group.rg_block.location
  allocation_method   = "Dynamic"
}
