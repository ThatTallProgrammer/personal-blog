resource "aws_launch_template" "ghost_server" {
  name = "ghost-server"

  image_id = "ami-0bd3fbcdc633a1b1a" # TODO: Dynamically fetch latest AMI for Ghost 

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t3.small"

  update_default_version = true

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = "us-east-1a"
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
  launch_template {
    id = aws_launch_template.ghost_server.id
    version = "$Latest"
  }
}


resource "aws_eip" "ghost_server" {
  instance = aws_instance.ghost_server.id
  domain   = "vpc"
}
