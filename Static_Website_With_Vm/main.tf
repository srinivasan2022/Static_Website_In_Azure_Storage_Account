# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.1.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "staticweb-rg"
  location = "eastus"
}

# Create a storage account for static website hosting
resource "azurerm_storage_account" "static_website" {
  name                     = "staticwebsite${random_string.random.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  static_website {
    index_document = "index.html"
  }

  tags = {
    environment = "production"
  }
  depends_on = [ azurerm_resource_group.rg , random_string.random ]
}

# Upload a sample index.html file to the static website
resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.static_website.name
  storage_container_name = "$web"
  type                   = "Block"
  source                  = "Files/index.html"
  content_type           = "text/html"
  depends_on = [ azurerm_storage_account.static_website ]
}


# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [ azurerm_resource_group.rg ]
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [ azurerm_virtual_network.vnet ]
}

# Create a public IP for the VM
resource "azurerm_public_ip" "vm" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "vm-proxy-${substr(md5(azurerm_resource_group.rg.name), 0, 8)}"
  depends_on = [ azurerm_resource_group.rg ]
}

# Create a network security group allowing HTTP traffic
resource "azurerm_network_security_group" "nsg" {
  name                = "rg-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [ azurerm_network_interface.nic ]
}

# Create a network interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm.id
  }
  depends_on = [ azurerm_resource_group.rg, azurerm_public_ip.vm, azurerm_subnet.subnet]
}

# Associate the NSG with the NIC
resource "azurerm_network_interface_security_group_association" "nic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [ azurerm_network_interface.nic, azurerm_network_security_group.nsg ]
}

# Create a Windows VM
resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = "proxy-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!" # In production, use Azure Key Vault for secrets

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [ azurerm_network_interface.nic, azurerm_public_ip.vm ]
}

# Configure the VM to proxy requests to the static website
resource "azurerm_virtual_machine_extension" "iis_config" {
  name                 = "iis-config"
  virtual_machine_id   = azurerm_windows_virtual_machine.win_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name Web-Server -IncludeManagementTools; Invoke-WebRequest -Uri '${azurerm_storage_account.static_website.primary_web_endpoint}' -UseBasicParsing -OutFile C:\\inetpub\\wwwroot\\iisstart.htm\""
    }
SETTINGS

depends_on = [ azurerm_windows_virtual_machine.win_vm, azurerm_storage_account.static_website ]
}
