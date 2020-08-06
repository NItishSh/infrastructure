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
# data "template_file" "install_ansible" {
#   template = "install_ansible.tpl"
# }
# resource "tls_private_key" "ee_private_key" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# ref https://ifritltd.com/2017/12/06/provisioning-ec2-key-pairs-with-terraform/
resource "aws_key_pair" "generated_key" {
  key_name = var.key_name
  # public_key = tls_private_key.ee_private_key.public_key_openssh
  public_key = file(var.public_key_path)
}
# output "tls_private_key" {
#   value = tls_private_key.ee_private_key.private_key_pem
# }
# output "tls_public_key" {
#   value = tls_private_key.ee_private_key.public_key_openssh
# }
resource "aws_instance" "public_server" {
  ami           = data.aws_ami.amazon-linux-2-ami.id
  instance_type = var.web_server_size
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = aws_key_pair.generated_key.key_name
  # user_data       = data.template_file.install_ansible.rendered
  user_data       = file("install_ansible.sh")
  security_groups = [aws_security_group.web.id, aws_security_group.jenkins.id, aws_security_group.puppet.id, aws_security_group.bastion.id, aws_security_group.ssh.id]
  tags = {
    "Name"  = "ee_web_server"
    "Owner" = "equal_experts"
  }
  provisioner "file" {
    content     = file(var.public_key_path)
    destination = "/home/ec2-user/.ssh/id_rsa.pub"
  }
  provisioner "file" {
    content     = file(var.private_key_path)
    destination = "/home/ec2-user/.ssh/id_rsa"
  }
}
output "public_ip" {
  value = aws_instance.public_server.public_ip
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