provider "aws"  {
    region = "us-east-1"
    access_key = "#############################"
    secret_key = "########################################"
  
}

resource "aws_vpc" "vpc-1" {
    cidr_block = "12.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      "Name" = "vpc-terraform"
    }
  
}

resource "aws_subnet" "sub-pub" {
    vpc_id = aws_vpc.vpc-1.id
    cidr_block = "12.0.1.0/24"

    tags = {
      Name = "public"
    }
}

resource "aws_subnet" "sub-pvt" {
    vpc_id = aws_vpc.vpc-1.id
    cidr_block = "12.0.5.0/24"

    tags = {
      Name = "private"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc-1.id

    tags= {
        Name = "IGW"
    }
}

resource "aws_eip" "eip" {
    vpc = true
}

resource "aws_nat_gateway" "nat-gateway" {
    allocation_id= aws_eip.eip.id
    subnet_id= aws_subnet.sub-pvt.id

    tags= {
        Name = "NGW"
    }
}

resource "aws_route_table" "route-1" {
    vpc_id = aws_vpc.vpc-1.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

        tags= {
            Name = "custom_route_table"
        }
    
}

resource "aws_route_table" "route-2" {
    vpc_id = aws_vpc.vpc-1.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat-gateway.id
    }

        tags = {
            Name= "main"
        }
    
}

resource "aws_route_table_association" "association-1" {
  subnet_id      = aws_subnet.sub-pub.id
  route_table_id = aws_route_table.route-1.id
}

resource "aws_route_table_association" "association-2" {
  subnet_id      = aws_subnet.sub-pvt.id
  route_table_id = aws_route_table.route-2.id
}

resource "aws_security_group" "sg" {
  name        = "first-SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc-1.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.vpc-1.cidr_block]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "first-SG"
  }
}