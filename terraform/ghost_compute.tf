# TODO: 
# - Create ASG
# - Create User data 
# 

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


resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ghost_server.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
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


data "aws_iam_policy_document" "ssm_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetServiceSetting",
      "ssm:ResetServiceSetting",
      "ssm:UpdateServiceSetting"
    ]

    resources = ["arn:aws:ssm:us-east-1:952835124770:servicesetting/ssm/managed-instance/default-ec2-instance-management-role"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = ["arn:aws:iam::952835124770:role/service-role/AWSSystemsManagerDefaultEC2InstanceManagementRole"]
  
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = ["ssm.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "ghost_server" {
  name               = "ghost_server"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


resource "aws_iam_role_policy" "ssm_access" {
  name   = "ssm_access"
  role   = aws_iam_role.ghost_server.id
  policy = data.aws_iam_policy_document.ssm_permissions.json
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

  key_name = "development" 

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Ghost Server"
    }
  }

  user_data = filebase64("${path.module}/cloud-config/blog-server-v001.yaml")
}
