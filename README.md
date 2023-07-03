# Terraform-VPC-creation-conditionally

A Virtual Private Cloud (VPC) can benefit from the deployment of AWS Route 53 Private DNS Zones to increase connectivity and dependability.You can establish a private namespace that is only accessible from within your VPC using Route 53 Private DNS Zones.This gives you a dependable and safe method of accessing resources by translating domain names to private IP addresses inside your VPC.You can configure Route 53 to associate certain domain names (hostnames) with those resources rather than utilising private IP addresses directly. By giving your resources names that are more significant and memorable, you may make it simpler to manage and access them.

Typically, to do this, you would create a private hosted zone in Route 53 and set up the required DNS records to link your custom domain names to the private IP addresses of your resources inside the VPC.You can also quickly update the IP addresses of your resources and abstract the underlying infrastructure by employing private hostnames rather than private IP addresses, all without affecting the clients that use the hostnames.

In this case, I'm going to use a frontend, bastion, and backend server for MySQL to build a high availability WordPress application, with each instance connecting via a private hostname. This code demonstrates how to create a complete VPC, how to use Terraform's count argument to create subnets based on the number of availability zones (AZs) present in a region, how to apply a condition to create a NAT gateway and its associated Elastic IP (EIP), and how to associate subnets.


## Variable definition for the resources

Lets create a file for declaring the variables.This is used to declare the variable and the values are passing through the variables.tf file.

> variables.tf

```
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
```
## Create a provider.tf file

> provider.tf
```
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```
## Create datasource.tf file

> datasource.tf
```
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
```
## Resource code definitionin main.tf

> main.tf
```
# ----------------------------------------------------------
#  Vpc Creation
# ----------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block       = var.main_network
  instance_tenancy = "default"
    enable_dns_hostnames = true

  tags = {
      Name      = "${var.project_name}-${var.project_env}"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating igw
# ----------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name      = "${var.project_name}-${var.project_env}"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating public subnets
# ----------------------------------------------------------
resource "aws_subnet" "public" {
    count = 3
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.main_network, 3, "${count.index}")
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "${var.project_name}-${var.project_env}-public-${count.index +1}"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating private subnets
# ----------------------------------------------------------
resource "aws_subnet" "private" {
    count = 3
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.main_network, 3, "${count.index +3}")
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "${var.project_name}-${var.project_env}-private-${count.index +1}"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating Elastic IP. The count argument is set to 1 if var.enable_natgw == true, indicating that one EIP should be created.
# ----------------------------------------------------------
resource "aws_eip" "nat-gateway" {
    count = var.enable_natgw == true ? 1 : 0
  
  domain   = "vpc"
      tags = {
    Name      = "${var.project_name}-${var.project_env}-nat-gateway"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating nat gateway. The count argument is set to 1 if var.enable_natgw == true, indicating that the above EIP should be assign to the below nat gateway.
# ----------------------------------------------------------
resource "aws_nat_gateway" "nat-gateway" {
    count = var.enable_natgw == true ? 1 : 0
  allocation_id = aws_eip.nat-gateway.0.id
  subnet_id     = aws_subnet.public.1.id

  tags = {
    Name      = "${var.project_name}-${var.project_env}-nat-gateway"
    "Project" = var.project_name
    "Env"     = var.project_env
  } 
  depends_on = [aws_internet_gateway.igw]
}

