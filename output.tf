output "AZs" {
    value = data.aws_availability_zones.available
}
output "subnet-1" {
    value = cidrsubnet(var.main_network, 3, 0)
}
output "subnet-2" {
    value = cidrsubnet(var.main_network, 3, 1)
}
output "subnet-3" {
    value = cidrsubnet(var.main_network, 3, 2)
}
output "subnet-4" {
    value = cidrsubnet(var.main_network, 3, 3)
}
output "subnet-5" {
    value = cidrsubnet(var.main_network, 3, 4)
}
output "subnet-6" {
    value = cidrsubnet(var.main_network, 3, 5)
}
output "subnet-7" {
    value = cidrsubnet(var.main_network, 3, 6)
}
output "subnet-8" {
    value = cidrsubnet(var.main_network, 3, 7)
}

output "Bastion-Server-Public-IP" {
    value = aws_instance.Wordpress-Bastion.public_ip
}
output "Bastion-Server-Private-IP" {
    value = aws_instance.Wordpress-Bastion.private_ip
}
output "Frontend-Server-Public-IP" {
    value = aws_instance.Wordpress-Frontend.public_ip
}
output "Frontend-Server-Private-IP" {
    value = aws_instance.Wordpress-Frontend.private_ip
}
output "Backend-Server-Private-IP" {
    value = aws_instance.Wordpress-Backend.private_ip
}
output "Frontend_Public_URL" {
    value = "http://${aws_route53_record.public_frontend.fqdn}"
}
