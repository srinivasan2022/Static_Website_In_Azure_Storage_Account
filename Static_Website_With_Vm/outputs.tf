# Output the VM public IP and storage account website URL
output "vm_public_ip" {
  value = azurerm_windows_virtual_machine.win_vm.public_ip_address
}

output "storage_account_website_url" {
  value = azurerm_storage_account.static_website.primary_web_endpoint
}
