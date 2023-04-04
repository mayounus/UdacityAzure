 variable "prefix" {
  description = "the prfix which should be used for all resources"
  type =  string
}

variable "location" {
  description = "ResourceLocation"
  type =  string
 
}

variable "adminuser" {
  description = "VM admin user name"
  type =  string
  
}   

variable "adminpassword" {
  description = "VM password with default"
  type =  string
  sensitive = true
}   

variable "resourcegroup" {
  description = "Existing resource group"
  type =  string
 
}   

variable "azureimage" {
  description = "Existing image"
  type =  string
 
}   

variable "VirtualMachines" {
  description = "Number of VMs in scaleset"
  type =  number
  validation {
    condition = var.VirtualMachines > 1
    error_message = "Please select number of virtual machines greater then 1"
  }
}   

variable "tags" {
   description = "Map of tags to use for deployed resources"
   type        = map(string)
   
}

