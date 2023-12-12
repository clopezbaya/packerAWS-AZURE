packer {
 required_plugins{
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }

    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "Nginx-Node"{
  ami_name = "Nginx-Node-app-${local.timestamp}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.2.20231113.0-kernel-6.1-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  instance_type = "t2.micro"
  access_key= "MODIFICAR"
  secret_key= "MODIFICAR"
  region = "sa-east-1"
  ssh_username = "ec2-user"
}

source "azure-arm" "Nginx-Node-Azure" {
  client_id                         = "MODIFICAR"
  client_secret                     = "MODIFICAR"
  image_offer                       = "CentOS"
  image_publisher                   = "OpenLogic"
  image_sku                         = "8_5-gen2"
  location                          = "East US"
  managed_image_name                = "Nginx-Node-Azure-${local.timestamp}"
  managed_image_resource_group_name = "packer-rgroup"
  os_type                           = "Linux"
  subscription_id                   = "MODIFICAR"
  tenant_id                         = "MODIFICAR"
  vm_size                           = "Standard_B1s"
  ssh_username                      = "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.Nginx-Node", 
    "source.azure-arm.Nginx-Node-Azure",
  ]

  provisioner "file" {
    source = "../NodeAPP.zip"
    destination = "/home/ec2-user/NodeAPP.zip"
  }

  provisioner "file" {
    source = "./node.service"
    destination = "/tmp/node.service"
  }

  provisioner "shell" {
    script = "./app.sh"
  }
}