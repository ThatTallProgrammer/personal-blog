data "aws_route53_zone" "ghost" {
  name         = "worksonmymachine.me."
  private_zone = false
}

resource "aws_route53_record" "ghost" {
  zone_id = data.aws_route53_zone.ghost.zone_id
  name    = "worksonmymachine.me"
  type    = "A"
  ttl     = 300
  records = [aws_eip.ghost_server.public_ip]
}
