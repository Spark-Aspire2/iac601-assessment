################ Output ###################

output "vm_1_ipv4_address" {
  value = azurerm_windows_virtual_machine.vm_1_block.public_ip_address
}
