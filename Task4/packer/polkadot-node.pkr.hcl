packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "node" {
  ami_name      = "polkadot-node"
  instance_type = "t2.micro"
  region        = "eu-west-1"
  access_key    = "AKIA3HRZQEMSMJW43FTE"
  secret_key    = "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"

  source_ami_filter {
    filters = {
      name                = "*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 100
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }
  tags = {
    OS_Version    = "Ubuntu"
    Base_Ami_Name = "{{ .SourceAMIName }}"
    Name          = "polkadot-node"
  }

  aws_polling {
    delay_seconds = 180
    max_attempts  = 100
  }

}

build {
  name = "Node"
  sources = [
    "source.amazon-ebs.node"
  ]
  provisioner "shell" {
    script       = "scripts/install.sh"
    pause_before = "10s"
    timeout      = "10s"
  }


  post-processors {
    post-processor "manifest" {
      output     = "packer-manifest.json"
      strip_path = true
    }
  }
  post-processors {
    post-processor "checksum" {
      checksum_types = ["md5", "sha512"] # Inspect artifact
    }
  }
}