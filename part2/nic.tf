
########### Network Interface ###############
resource "azurerm_network_interface" "main_nic_1" {
  name                = var.network_interface_1_name
  location            = azurerm_resource_group.rg_block.location
  resource_group_name = azurerm_resource_group.rg_block.name

  ip_configuration {
    name                          = "nic-ip-configuration"
    subnet_id                     = azurerm_subnet.subnet_1_block.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_1.id
  }
}
