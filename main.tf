#provider
provider "azurerm" {
  features {}
}
#data
data "azurerm_resource_group" "UdacityProject" {
  name = var.resourcegroup  
}
data "azurerm_image" "UdacityProject" {
  name = var.azureimage
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
} 


resource "azurerm_network_security_group" "UdacityProject" {
  name = "${var.prefix}-NSG"
  location = var.location
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  tags = var.tags
}

resource "azurerm_network_security_rule" "InboundRestrictAll" {
  name = "InboundRestrictAll"
  priority = 198
  direction = "Inbound"
  access = "Deny"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "Internet"
  destination_address_prefix = "*"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  network_security_group_name = azurerm_network_security_group.UdacityProject.name
}

resource "azurerm_network_security_rule" "OutboundAllow" {
  name = "OutboundAllow"
  priority = 199
  direction = "Outbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  network_security_group_name = azurerm_network_security_group.UdacityProject.name
}

resource "azurerm_network_security_rule" "InboundAllowInternal" {
  name = "InboundAllowInternal"
  priority = 200
  direction = "Inbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "VirtualNetwork"
  destination_address_prefix = "VirtualNetwork"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  network_security_group_name = azurerm_network_security_group.UdacityProject.name
}

resource "azurerm_virtual_network" "UdacityProject" {
  name = "${var.prefix}-vnet"
  location = var.location
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  address_space = ["10.0.0.0/24"]
  tags = var.tags
}

resource "azurerm_subnet" "UdacityProject" {
    address_prefixes = ["10.0.0.0/24"]
    name = "${var.prefix}-Subnetnet"
    resource_group_name = data.azurerm_resource_group.UdacityProject.name  
    virtual_network_name = azurerm_virtual_network.UdacityProject.name
}

resource "azurerm_subnet_network_security_group_association" "UdacityProject" {
  subnet_id = azurerm_subnet.UdacityProject.id
  network_security_group_id = azurerm_network_security_group.UdacityProject.id
}

resource "azurerm_network_interface" "UdacityProject" {
  count = "${var.VirtualMachines}"
  name = "nic-${count.index}"
  location = var.location
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  

  ip_configuration {
    name = "InternalIP"
    subnet_id = azurerm_subnet.UdacityProject.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = var.tags
}

resource "azurerm_public_ip" "UdacityProject" {
  name = "PublicIP"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  location = var.location
  allocation_method = "Dynamic"
  tags = var.tags
}
resource "azurerm_lb" "UdacityProject" {
  name = "Udacity-lb"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  location = var.location

  frontend_ip_configuration {
    name = "Udacity-feip"
    public_ip_address_id = azurerm_public_ip.UdacityProject.id
  }
  tags =var.tags
}
resource "azurerm_lb_backend_address_pool" "UdacityProject" {
  name = "Udacity-ap"
  loadbalancer_id = azurerm_lb.UdacityProject.id
}

resource "azurerm_availability_set" "UdacityProject" {
  name = "Udacity-as"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  location = var.location
  tags = var.tags
}

resource "azurerm_managed_disk" "UdacityProject" {
  count = "${var.VirtualMachines}"
  name = "Udacity-md${count.index}"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  location = var.location
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb =  "1"
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "UdacityProject" {
  count = "${var.VirtualMachines}"
  name = "Udacity-vm${count.index}"
  resource_group_name = data.azurerm_resource_group.UdacityProject.name  
  location = var.location
  admin_username = "${var.adminuser}"
  admin_password = "${var.adminpassword}"
  network_interface_ids = [element(azurerm_network_interface.UdacityProject.*.id, count.index)]
  source_image_id = data.azurerm_image.UdacityProject.id
  availability_set_id = azurerm_availability_set.UdacityProject.id
  disable_password_authentication = false
  size = "Standard_B1s"
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS" 
  }
  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "UdacityProject" {
  count = "${var.VirtualMachines}"
  managed_disk_id = azurerm_managed_disk.UdacityProject[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.UdacityProject[count.index].id
  lun = "${count.index}"
  caching = "ReadWrite"
}
