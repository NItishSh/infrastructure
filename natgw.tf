resource "aws_eip" "nat_eip" {
  tags = {
    "Name"  = "ee_eip"
    "Owner" = "equal_experts"
  }
}
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    "Name"  = "ee_nat_gw"
    "Owner" = "equal_experts"
  }
}
