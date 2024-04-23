terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}

}

resource "azurerm_network_security_group" "nsg" {
  name = "VM-tf-nsg-DEV"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id = azurerm_network_interface.tf-NtInt-Dev.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_resource_group" "rg" {
  name     = "VM-tf-rg-DEV"
  location = "westus2"

  tags = {
    environment = "dev"
  }
}


resource "azurerm_storage_account" "storage" {
  name                     = "rauniribeirostorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "public-ip" {
  name = "VM-tf-publicIP-DEV"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  
}

resource "azurerm_virtual_network" "virtual-network" {
  resource_group_name = azurerm_resource_group.rg.name
  name                = "VM-tf-network-DEV"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "tf-subnet-Dev" {
  name                 = "VM-tf-subnet-DEV"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "tf-NtInt-Dev" {
  name                = "VM-tf-networkInt-Dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "VM-tf-IP-configuration"
    subnet_id                     = azurerm_subnet.tf-subnet-Dev.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "tf-linux-Dev" {
  name                = "VM-tf-linux-DEV"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_F2s_v2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.tf-NtInt-Dev.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_5-gen2"
    version   = "latest"
  }
}