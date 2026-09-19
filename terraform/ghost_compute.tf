data "aws_vpc" "default" {
  default = true
}


resource "aws_security_group" "ghost_server" {
  name        = "ghost_server"
  description = "Security group for Ghost server"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "Ghost Server"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ghost" {
  security_group_id = aws_security_group.ghost_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 2368
  ip_protocol       = "tcp"
  to_port           = 2368
}


resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ghost_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_iam_instance_profile" "ghost_server" {
  name = "ghost_server_profile"
  role = aws_iam_role.ghost_server.name
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "ghost_server" {
  name               = "ghost_server"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ghost_server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


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
