# Create subnets for ELB and EC2 instances
# 
# public subnet (ELB and VPN instance)
resource "aws_subnet" "public" {
    vpc_id = "${var.az_vpc_id}"
    cidr_block = "${var.az_cidr_block_public}"
    availability_zone = "${var.az}"
    tags {
        Name = "public"
        Environment = "${var.az_env}"
    }
}

# subnet for web layer
resource "aws_subnet" "web" {
    vpc_id = "${var.az_vpc_id}"
    cidr_block = "${var.az_cidr_block_web}" 
    availability_zone = "${var.az}"
    tags {
        Name = "web"
        Environment = "${var.az_env}"
    }
}

# subnet for app layer
resource "aws_subnet" "app" {
    vpc_id = "${var.az_vpc_id}"
    cidr_block = "${var.az_cidr_block_app}"
    availability_zone = "${var.az}"
    tags {
        Name = "app"
        Environment = "${var.az_env}"
    }
}

# subnets for data layer
# 2 are required for RDS subnet groups
resource "aws_subnet" "data" {
    vpc_id = "${var.az_vpc_id}"
    cidr_block = "${var.az_cidr_block_data}"
    availability_zone = "${var.az}"
    tags {
        Name = "data"
        Environment = "${var.az_env}"
    }
}


# Create route tables for public and private subnets
# Use these instead of main route table, which we leave untouched

# public route table uses internet gateway for routing outside VPC
resource "aws_route_table" "public" {
    vpc_id = "${var.az_vpc_id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${var.az_igw_id}"
    }

    tags {
        Name = "public"
        Environment = "${var.az_env}"
    }
}

resource "aws_security_group" "nat" {
  name = "nat-sg"
  description = "NAT instance for HTTP/S traffic"
  vpc_id = "${var.az_vpc_id}"
  
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.az_cidr_block_web}","${var.az_cidr_block_app}","${var.az_cidr_block_data}"]
  }
  
  ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["${var.az_cidr_block_web}","${var.az_cidr_block_app}","${var.az_cidr_block_data}"]
  }
  
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.az_cidr_block_web}","${var.az_cidr_block_app}","${var.az_cidr_block_data}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat" {
  ami = "${var.az_nat_ami}"
  instance_type = "${var.az_nat_instance_type}"
  key_name = "${var.az_nat_keyname}"
  vpc_security_group_ids = ["${aws_security_group.nat.id}"]
  subnet_id = "${aws_subnet.public.id}"
  associate_public_ip_address = true
  source_dest_check = false
  tags {
        Name = "NAT"
        Environment = "${var.az_env}"
  }
}

# Create route tables for public and private subnets
# Use these instead of main route table, which we leave untouched
resource "aws_route_table" "private" {
    vpc_id = "${var.az_vpc_id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }
    
    tags {
        Name = "private"
        Environment = "${var.az_env}"
    }
}

# Associate route tables with the subnets that were created
resource "aws_route_table_association" "public" {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "web" {
    subnet_id = "${aws_subnet.web.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "app" {
    subnet_id = "${aws_subnet.app.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "data" {
    subnet_id = "${aws_subnet.data.id}"
    route_table_id = "${aws_route_table.private.id}"
}
