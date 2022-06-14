resource "aws_key_pair" "key-node" {
  key_name   = var.name
  public_key = var.public_key
}

resource "aws_ebs_volume" "node-storage" {
  availability_zone = var.zone
  size              = 200

  tags = {
    owner = var.name
  }
}

resource "aws_volume_attachment" "node-storage-attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.node-storage.id
  instance_id = aws_instance.bootnode.id
  # count       = var.node_count
}

resource "aws_instance" "bootnode" {
  source        = "../network"
  ami           = var.image
  instance_type = var.machine_type
  key_name      = var.name
  # count         = var.node_count

  subnet_id              = output.aws_subnet.value #aws_subnet.main-node.id
  vpc_security_group_ids = aws_security_group.node.id

  root_block_device {
    volume_size = 100
  }

  tags = {
    Name = var.name
  }
}