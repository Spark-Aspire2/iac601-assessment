
########### Network Security Group ###############
resource "azurerm_network_security_group" "nsg_1_block" {
  name                = var.security_group_name
  location            = azurerm_resource_group.rg_block.location
  resource_group_name = azurerm_resource_group.rg_block.name

  # Only IP addesses of "118.92.0.0/16" are permit to access the VM.
  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "118.92.0.0/16"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "test"
  }
}



resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.main_nic_1.id
  network_security_group_id = azurerm_network_security_group.nsg_1_block.id
}
