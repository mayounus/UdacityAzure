#Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

Introduction:
  This configuration uses Packer to create a server image (Ubuntu 18.04-LTS SKU) and uses Terraform to deplo cluster of servers with a loadbalancer. 

Getting Started
  Clone this repository

Dependencies
  Azure Account
  Install Terraform
  Install Packer
  Install AZ Cli
  Create Service Principal used for Packer
  Existing Resource group (used for deploying Packer image and home resources created by Terraform config)
  Create tagging policy
  
Resources created by config:
  Virtual network with a subnet
  Network Security Group
  Network Interfaces
  Public IP
  Load Balancer
  Virtual machine availabity set
  Virtual machines
  Managed disks

Instructions:
  Clone Repo
  Login to your AZ account
  PackerImage Steps:
    Create service principal either from the portal or through AZ cli and grant contributor permissions to your target subscription
    Set environment variables from your service principal:  
              $env:ARM_CLIENT_ID = ""
              $env:ARM_CLIENT_SECRET = ""
              $env:ARM_SUBSCRIPTION_ID = ""
    Create packer image using "server.json" file included in the repo. **Update your tags**
    Run packer build
  Terraform Steps:
    Run Terraform init
    Run Terraform validate
    Run terraform plan **To avoid inputting varialbles from command line, create a Terraform.tfvars file and add add values to variables.**
    Run Terraform apply
    Run Terraform destroy to avoid charges if this is a test
    
    
  

  
              
  


