terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "tf-eco-k8s-vmw"

    workspaces {
      name = "aws_remote_backend"
    }
  }
}

provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region = var.AWS_REGION
}

data "aws_ami" "amazon_linux_2" {
    most_recent = true

    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*.*-x86_64-gp2"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["137112412989"]
}

resource "aws_instance" "terraform_dynamic_ami" {
    count = var.INSTANCE_COUNT
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = var.AWS_INSTANCE_TYPE

    tags = {
        name = var.TAG_USER_NAME
        company = "HashiCorp"
    }
}