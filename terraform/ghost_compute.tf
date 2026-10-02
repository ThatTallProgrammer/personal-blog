locals {
  availability_zone = "us-east-1a"
}


resource "aws_launch_template" "ghost_server" {
  name = "ghost-server"

  image_id = "ami-01576732ed072a93c" # TODO: Dynamically fetch latest AMI for Ghost 

  instance_market_options {
    market_type = "on-demand"
  }

  instance_type = "t3.small"

  update_default_version = true

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = local.availability_zone
  }
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ghost_server.name
  }

  vpc_security_group_ids = [aws_security_group.ghost_server.id]

  key_name = "" 

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Ghost Server"
    }
  }

  user_data = filebase64("${path.module}/cloud-config/blog-server-v001.yaml")
}


resource "aws_instance" "ghost_server" {
  availability_zone = local.availability_zone
  
  launch_template {
    id      = aws_launch_template.ghost_server.id
    version = aws_launch_template.ghost_server.default_version
  }

  # Terraform tries to set fields from LT to null on update
  # This appears to be a bug caused by terraform not seeing those fields in the instance declaration
  lifecycle {
    ignore_changes = [
      user_data,
      tags,
      tags_all
    ]
  }
}


resource "aws_ebs_volume" "ghost_data" {
  availability_zone = local.availability_zone
  size = 10
  encrypted = true
  type = "gp3"
  
  tags = {
    Name = "Ghost MySQL Data Volume"
    Backup = "true"
  }
}


resource "aws_volume_attachment" "ghost_data" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ghost_data.id
  instance_id = aws_instance.ghost_server.id
}


resource "aws_eip" "ghost_server" {
  domain   = "vpc"
  instance = aws_instance.ghost_server.id
}
