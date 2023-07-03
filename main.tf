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
# ----------------------------------------------------------
# Creating public route table
# ----------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
        Name      = "${var.project_name}-${var.project_env}-route-public"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating private route table and its route if nat gateway is enabled
# ----------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
        Name      = "${var.project_name}-${var.project_env}-route-private"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}

resource "aws_route" "private" {
    count = var.enable_natgw == true ? 1 : 0
  route_table_id              = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat-gateway.0.id
}
# ----------------------------------------------------------
# Public route table assosiation
# ----------------------------------------------------------
resource "aws_route_table_association" "public" {
    count =3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
# ----------------------------------------------------------
# Private route table assosiation
# ----------------------------------------------------------
resource "aws_route_table_association" "private" {
    count = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
# ----------------------------------------------------------
# Creating Security group for bastion Server
# ----------------------------------------------------------
resource "aws_security_group" "Wordpress-Bastion" {
  name        = "${var.project_name}-${var.project_env}-Bastion"
  description = "Wordpress-Bastion-SG"
    vpc_id      = aws_vpc.vpc.id


  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.project_env}-bastion"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
    lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------------------------
# Creating Security group for Frontend Server
# ----------------------------------------------------------
resource "aws_security_group" "Wordpress-Frontend" {
  name        = "${var.project_name}-${var.project_env}-Frontend"
  description = "Wordpress-Bastion-SG"
    vpc_id      = aws_vpc.vpc.id


  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.Wordpress-Bastion.id]
  }
    
    ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

      ingress {

    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.project_env}-frontend"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
    lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------------------------
# Creating security group for Backend Server
# ----------------------------------------------------------
resource "aws_security_group" "Wordpress-Backend" {
  name        = "${var.project_name}-${var.project_env}-Backend"
  description = "Wordpress-Bastion-SG"
    vpc_id      = aws_vpc.vpc.id


  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.Wordpress-Bastion.id]
  }
    
    ingress {

    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
 security_groups = [aws_security_group.Wordpress-Frontend.id]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.project_env}-backend"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
    lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------------------------
# Assigning keypair from local
# ----------------------------------------------------------
resource "aws_key_pair" "wordpress" {
  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("wordpress.pub")
  tags = {
    "Name"    = "${var.project_name}-${var.project_env}-Wordpress-Prod"
    "Project" = var.project_name
    "Env"     = var.project_env
  }
}
# ----------------------------------------------------------
# Creating Bastion Server
# ----------------------------------------------------------
resource "aws_instance" "Wordpress-Bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
    subnet_id = aws_subnet.public.1.id

  key_name               = aws_key_pair.uber.key_name
  vpc_security_group_ids = [aws_security_group.Uber-Bastion.id]
  tags                   = { "Name" = "${var.project_name}-${var.project_env}-Bastion", 
                            "Project" = var.project_name, 
                            "Env" = var.project_env, 
                             
                           }
  lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------------------------
# Creating Frontend Server
# ----------------------------------------------------------
resource "aws_instance" "Wordpress-Frontend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
    
    subnet_id = aws_subnet.public.0.id
    user_data = file("wordpress.sh")

  key_name               = aws_key_pair.uber.key_name
  vpc_security_group_ids = [aws_security_group.Uber-Frontend.id]
  tags                   = { "Name" = "${var.project_name}-${var.project_env}-Frontend", 
                            "Project" = var.project_name, 
                            "Env" = var.project_env, 
                             
                           }
  lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------------------------
# Creating Backend Server
# ----------------------------------------------------------
resource "aws_instance" "Wordpress-Backend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
    user_data = file("mysql.sh")
    subnet_id = aws_subnet.private.1.id

  key_name               = aws_key_pair.uber.key_name
  vpc_security_group_ids = [aws_security_group.Uber-Backend.id]
  tags                   = { "Name" = "${var.project_name}-${var.project_env}-Backend", 
                            "Project" = var.project_name, 
                            "Env" = var.project_env, 
                             
                           }
  lifecycle {
    create_before_destroy = true
  }
}
