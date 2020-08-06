data "template_file" "dev_hosts" {
  template = "${file("${path.module}/ansible/dev_hosts.cfg")}"
  depends_on = [
    aws_instance.public_server,
    aws_instance.private_server,
  ]
  vars = {
    api_public   = aws_instance.public_server.private_ip
    api_internal = aws_instance.private_server.private_ip
  }
}

resource "null_resource" "dev-hosts" {
  triggers = {
    template_rendered = "${data.template_file.dev_hosts.rendered}"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.public_server.public_ip
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      timeout     = "1m"
      //    agent = false . // true?
    }
    inline = [
      "hostname",
      "whoami",
      "echo '${data.template_file.dev_hosts.rendered}' | sudo tee /etc/ansible/hosts"
    ]
    # command = "echo '${data.template_file.dev_hosts.rendered}' > dev_hosts"
  }
}