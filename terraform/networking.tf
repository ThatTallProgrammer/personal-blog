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
