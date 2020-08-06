resource "aws_internet_gateway" "ee_igw" {
  vpc_id = aws_vpc.equalexperts.id

  tags = {
    "Name"  = "ee_igw"
    "Owner" = "equal_experts"
  }
}