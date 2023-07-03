# ----------------------------------------------------------
# For provider
# ----------------------------------------------------------
variable "access_key" {
    default = "your access key"
}

variable "secret_key" {
  default = "your secret key"  
}
# ----------------------------------------------------------
# For Region
# ----------------------------------------------------------

variable "region" {
    default = "ap-south-1"
}
# ----------------------------------------------------------
# For VPC
# ----------------------------------------------------------

variable "main_network" {
    default = "172.16.0.0/16"
}
# ----------------------------------------------------------
# For tags
# ----------------------------------------------------------

variable "project_name" {
    description = "project_name"
    type = string
    default = "Wordpress"
}

variable "project_env" {
  description = "project_env"
    type = string
    default = "prod"
}
# ----------------------------------------------------------
# For AMI and Instance type
# ----------------------------------------------------------

variable "instance_type" {
    description = "instance_type"
    type = string
    default = "t2.micro"
}

variable "ami_id" {
    description = "ami_id"
    type = string
    default = "ami-057752b3f1d6c4d6c"
}
# ----------------------------------------------------------
# For Route53
# ----------------------------------------------------------
variable "private_zone_name" {
    default = "jijinmichael.local"
}
variable "public_zone_name" {
    default = "jijinmichael.online"
}
# ----------------------------------------------------------
# For nat gateway. This variable definition can be used to configure whether or not to create a Network Address Translation (NAT) resource in your infrastructure provisioning code. By setting the default value to false, it means that the NAT resource will not be created by default unless the variable is explicitly set to true when using it.
# ----------------------------------------------------------
variable "enable_natgw" {
    type = bool
    default = true
    }
