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
  access_key= "AKIAZATYSUGMFVUFUM4L"
  secret_key= "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"
  region = "sa-east-1"
  ssh_username = "ec2-user"
}

source "azure-arm" "Nginx-Node-Azure" {
  client_id                         = "eb1baf29-ecdb-464e-9510-bbf8ddc16148"
  client_secret                     = "4X38Q~Dr5v2eErsaLa4NT7WHsEsas0CBkzXLCbQM"
  image_offer                       = "CentOS"
  image_publisher                   = "OpenLogic"
  image_sku                         = "8_5-gen2"
  location                          = "East US"
  managed_image_name                = "Nginx-Node-Azure-${local.timestamp}"
  managed_image_resource_group_name = "packer-rgroup"
  os_type                           = "Linux"
  subscription_id                   = "e9a5c656-3fa3-4fde-ac20-d2085991d7d1"
  tenant_id                         = "c24682df-35ba-452f-bc02-8f19f6ca28f5"
  vm_size                           = "Standard_B1s"
  ssh_username                      = "ec2-user"
}

build {
  sources = [
    "source.amazon-ebs.Nginx-Node", 
    # "source.azure-arm.Nginx-Node-Azure",
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

  post-processor "manifest" {
    output = "manifest.json"
  }

  post-processor "shell-local" {
    inline = [
      # Obtener la ID de la imagen creada
      "AMI_ID=$(jq -r '.builds[-1].artifact_id' manifest.json | cut -d ':' -f2)",
      "echo $AMI_ID",

      # Lanzar una instancia usando AWS CLI
      "echo 'Lanzando la instancia en AWS...'",
      "aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --key-name newKey --security-groups launch-wizard-1",
    ]
  }
}