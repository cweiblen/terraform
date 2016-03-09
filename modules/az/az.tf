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

# Create NAT gateway
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"
}

# Create route tables for public and private subnets
# Use these instead of main route table, which we leave untouched
resource "aws_route_table" "private" {
    vpc_id = "${var.az_vpc_id}"

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = "${aws_nat_gateway.nat.id}"
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
