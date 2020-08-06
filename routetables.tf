resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.equalexperts.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ee_igw.id
  }
  tags = {
    "Name"  = "ee_public_rt"
    "Owner" = "equal_experts"
  }
}
resource "aws_route_table_association" "public_rt" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
  depends_on     = [aws_route_table.public_rt, aws_subnet.public_subnet]
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.equalexperts.id
  tags = {
    "Name"  = "ee_private_rt"
    "Owner" = "equal_experts"
  }
}
resource "aws_route_table_association" "private_rt" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
  depends_on     = [aws_route_table.private_rt, aws_subnet.private_subnet]
}