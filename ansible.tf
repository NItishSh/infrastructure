#https://www.linkbynet.com/produce-an-ansible-inventory-with-terraform
#https://stackoverflow.com/questions/23074412/how-to-set-host-key-checking-false-in-ansible-inventory-file
#https://github.com/geerlingguy/ansible-role-jenkins
data "template_file" "ansible_inventory" {
  template = "${file("${path.module}/inventory.tmpl")}"
  depends_on = [
    aws_instance.public_server,
    aws_instance.private_server,
  ]
  vars = {
    bastion-dns   = aws_instance.public_server.public_dns,
    bastion-ip    = aws_instance.public_server.public_ip,
    bastion-id    = aws_instance.public_server.id,
    private-dns   = aws_instance.private_server.private_dns,
    private-ip    = aws_instance.private_server.private_ip,
    private-id    = aws_instance.private_server.id,
    ssh_user_name = var.ssh_user_name
  }
}
resource "null_resource" "dev-hosts" {
  triggers = {
    template_rendered = "${data.template_file.ansible_inventory.rendered}"
  }
  provisioner "file" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_server.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
    source      = "${path.module}/.ansible"
    destination = "/home/ec2-user/"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_server.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
    inline = [
      "sudo yum install python3 -y",
      # "sudo ln -sf /usr/bin/python3 /usr/bin/python",
      # "sudo ln -sf /usr/bin/pip3 /usr/bin/pip",
      # "python --version",
      # "python3 --version",
      "sudo amazon-linux-extras install ansible2 -y",
      "ansible-galaxy install geerlingguy.java",
      "ansible-galaxy install geerlingguy.jenkins",
      "echo '${data.template_file.ansible_inventory.rendered}' > /home/ec2-user/.ansible/hosts"
    ]
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_server.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
    inline = [
      "ansible-playbook /home/ec2-user/.ansible/playbook-connectivity.yaml -i /home/ec2-user/.ansible/hosts",
    ]
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_server.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
    inline = [
      "ansible-playbook /home/ec2-user/.ansible/jenkins/playbook-jenkins.yaml -i /home/ec2-user/.ansible/hosts"
    ]
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_server.public_ip
      user        = var.ssh_user_name
      private_key = file(var.private_key_path)
      timeout     = var.ssh_time_out
    }
    inline = [
      "ansible-playbook /home/ec2-user/.ansible/docker/playbook-docker.yaml -i /home/ec2-user/.ansible/hosts"
    ]
  }
}