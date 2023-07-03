# ----------------------------------------------------------
# Creating a private zone jijinmichael.local
# ----------------------------------------------------------
resource "aws_route53_zone" "private" {
  name = var.private_zone_name
    vpc {
    vpc_id = aws_vpc.vpc.id
  }
tags                   = { "Name" = "${var.project_name}-${var.project_env}-private", 
                            "Project" = var.project_name, 
                            "Env" = var.project_env, 
                             }
}
# ----------------------------------------------------------
# Pointing frontend.jijinmichael.local to frontend's private ip
# ----------------------------------------------------------
resource "aws_route53_record" "private_frontend" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "frontend"
  type    = "A"
  ttl     = 300
  records = [aws_instance.Wordpress-Frontend.private_ip]
}
# ----------------------------------------------------------
# Pointing bastion.jijinmichael.local to bastion's private ip
# ----------------------------------------------------------
resource "aws_route53_record" "private_bastion" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "bastion"
  type    = "A"
  ttl     = 300
  records = [aws_instance.Wordpress-Bastion.private_ip]
}
# ----------------------------------------------------------
# Pointing backend.jijinmichael.local to bastion's private ip
# ----------------------------------------------------------
resource "aws_route53_record" "private_backend" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "backend"
  type    = "A"
  ttl     = 300
  records = [aws_instance.Wordpress-Backend.private_ip]
}
# ----------------------------------------------------------
# Pointing blog.jijinmichael.online to frontend public IP
# ----------------------------------------------------------
resource "aws_route53_record" "public_frontend" {
  zone_id = data.aws_route53_zone.jijinmichaelonline.id
  name    = "blog"
  type    = "A"
  ttl     = 300
  records = [aws_instance.Wordpress-Frontend.public_ip]
}
