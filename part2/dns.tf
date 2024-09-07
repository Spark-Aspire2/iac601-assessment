
### Private DNS Zone ###############
resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = var.mysql_dns_name
  resource_group_name = azurerm_resource_group.rg_block.name
}

### Private DNS Zone Linked with VNET ###############
resource "azurerm_private_dns_zone_virtual_network_link" "dns_network_link" {
  name                  = var.dns_network_link_name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet_1_block.id
  resource_group_name   = azurerm_resource_group.rg_block.name
}