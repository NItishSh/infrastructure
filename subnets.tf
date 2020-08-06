data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.equalexperts.id
  cidr_block              = var.public_subnet
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    "Name"  = "ee_public_subnet"
    "Owner" = "equal_experts"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.equalexperts.id
  cidr_block        = var.private_subnet
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    "Name"  = "ee_private_subnet"
    "Owner" = "equal_experts"
  }
}