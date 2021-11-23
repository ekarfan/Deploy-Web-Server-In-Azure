provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}





resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-main-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}


resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-main-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]

}



resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}




resource "azurerm_network_interface" "main" {
  count = 2
  name                = "${var.prefix}-umpbox-nic-${var.server_name[count.index]}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  ip_configuration {
    name                          = "${var.prefix}-ip_configuration"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }

  tags                = var.tags
}



resource "azurerm_network_security_group" "webserver" {
  name                = "${var.prefix}-webserver-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "inboundRule"
    priority                   = 101
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "externalRule"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags                = var.tags
}

resource "azurerm_availability_set" "main" {
  name                        = "${var.prefix}-availabity-set"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  platform_fault_domain_count = 2
  tags                        = var.tags
}


 
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "${var.prefix}-public-address"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags                = var.tags
}


resource "azurerm_lb_backend_address_pool" "main" {

  loadbalancer_id     = azurerm_lb.main.id
  name                = "${var.prefix}-backend-address-pool"
}



resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count = var.vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name   = "${var.prefix}-ip_configuration"
  network_interface_id    = azurerm_network_interface.main[count.index].id
}


resource "azurerm_linux_virtual_machine" "main" {
  count = var.vm_count
  name                            = "${var.prefix}-vm-${var.server_name[count.index]}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = var.username
  admin_password                  = var.password
  availability_set_id             = azurerm_availability_set.main.id
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.main[count.index].id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

 
  tags                = var.tags
}



resource "azurerm_managed_disk" "main" {
  count                = var.vm_count
  name                 = "${var.prefix}-disk-${count.index}"
  location             = var.location
  create_option        = "Empty"
  disk_size_gb         = 10
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"

  tags                = var.tags

}



