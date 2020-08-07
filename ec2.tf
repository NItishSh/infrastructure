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
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
resource "aws_instance" "public_server" {
  ami           = data.aws_ami.amazon-linux-2-ami.id
  instance_type = var.web_server_size
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = aws_key_pair.generated_key.key_name
  # user_data       = file("install_ansible.sh")
  # availability_zone = var.az
  security_groups = [aws_security_group.web.id, aws_security_group.jenkins.id, aws_security_group.puppet.id, aws_security_group.bastion.id, aws_security_group.ssh.id]
  tags = {
    "Name"  = "ee_web_server"
    "Owner" = "equal_experts"
  }
  provisioner "file" {
    content     = file(var.public_key_path)
    destination = "/home/ec2-user/.ssh/id_rsa.pub"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
  }
  provisioner "file" {
    content     = file(var.private_key_path)
    destination = "/home/ec2-user/.ssh/id_rsa"
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
    inline = [
      "chmod 600 /home/ec2-user/.ssh/id_rsa",
      "chmod 644 /home/ec2-user/.ssh/id_rsa.pub"
    ]
  }
}
output "public_ip" {
  value = aws_instance.public_server.public_ip
}
resource "aws_instance" "private_server" {
  ami           = data.aws_ami.amazon-linux-2-ami.id
  instance_type = var.web_server_size
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = aws_key_pair.generated_key.key_name
  # availability_zone = var.az
  security_groups = [aws_security_group.jenkins.id, aws_security_group.puppet.id, aws_security_group.ssh.id]
  tags = {
    "Name"  = "ee_app_server"
    "Owner" = "equal_experts"
  }
}