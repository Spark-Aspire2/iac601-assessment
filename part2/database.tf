
### Azure MySQL Database ###############
resource "azurerm_mysql_flexible_server" "media_labs_mysql" {
  name                   = var.mysql_server_name
  location               = azurerm_resource_group.rg_block.location
  resource_group_name    = azurerm_resource_group.rg_block.name
  administrator_login    = var.mysql_root
  administrator_password = var.mysql_password
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.subnet_2_block.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_dns.id

  sku_name   = "GP_Standard_D2ds_v4"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_network_link]
}

