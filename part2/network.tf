
########### Resource Group ###############
resource "azurerm_resource_group" "rg_block" {
  name     = var.rg_name
  location = var.location
}


########### Virtual Network ###############
resource "azurerm_virtual_network" "vnet_1_block" {
  name                = var.vnet_1_name
  location            = azurerm_resource_group.rg_block.location
  resource_group_name = azurerm_resource_group.rg_block.name
  address_space       = var.vnet_1_cidr

  tags = {
    environment = "test"
  }
}

########### Virtual Network 1 - Subnet 1 ###########
resource "azurerm_subnet" "subnet_1_block" {
  name                 = "${var.vnet_1_name}-${var.subnet_1_name}"
  resource_group_name  = azurerm_resource_group.rg_block.name
  virtual_network_name = azurerm_virtual_network.vnet_1_block.name
  address_prefixes     = var.subnet_1_cidr
  
}


resource "azurerm_subnet" "subnet_2_block" {
  name                 = "${var.vnet_1_name}-${var.subnet_2_name}"
  resource_group_name  = azurerm_resource_group.rg_block.name
  virtual_network_name = azurerm_virtual_network.vnet_1_block.name
  address_prefixes     = var.subnet_2_cidr
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "mysql_fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}


