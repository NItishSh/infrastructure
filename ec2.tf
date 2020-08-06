data "aws_ami" "amazon-linux-2-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
resource "tls_private_key" "ee_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.ee_private_key.public_key_openssh
}
output "tls_private_key" {
  value = tls_private_key.ee_private_key
}
resource "aws_instance" "public_server" {
  ami             = data.aws_ami.amazon-linux-2-ami.id
  instance_type   = var.web_server_size
  subnet_id       = aws_subnet.public_subnet.id
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.web.id, aws_security_group.jenkins.id, aws_security_group.puppet.id, aws_security_group.bastion.id, aws_security_group.ssh.id]
  tags = {
    "Name"  = "ee_web_server"
    "Owner" = "equal_experts"
  }
}
resource "aws_instance" "private_server" {
  ami             = data.aws_ami.amazon-linux-2-ami.id
  instance_type   = var.web_server_size
  subnet_id       = aws_subnet.private_subnet.id
  key_name        = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.jenkins.id, aws_security_group.puppet.id, aws_security_group.ssh.id]
  tags = {
    "Name"  = "ee_app_server"
    "Owner" = "equal_experts"
  }
}