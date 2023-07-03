data "aws_route53_zone" "jijinmichaelonline" {
  name         = var.public_zone_name
  private_zone = false
}
# ----------------------------------------------------------
# Retrieve the list of availability zones in a particular region.
# ----------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}
