#select an amazon-linux2 ami as base image for the bastion host
data "aws_ami" "bastion_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "hypervisor"
    values = ["xen"]
  }
}

//create the bastion host to get access to the cluster/db instances
resource "aws_instance" "bastion_host" {
  instance_type   = var.bastion_instance_type
  ami             = data.aws_ami.bastion_ami.image_id
  key_name        = var.aws_key_pair_name
  security_groups = [aws_security_group.bastion_sg.id]
  subnet_id       = element(var.subnet_ids, 0)

  tags = {
    Name        = "Bastion Host"
    Environment = var.environment
    Application = var.app_name
    DependsId = var.depends_id
  }
}

/**
* We don't need bastion host alive. So shut it down
*/

data "template_file" "provisioner_app" {
  template = file("${path.module}/user_data/provisioner.sh")
}

resource "null_resource" "stop_instance" {
  triggers = {
    instance_id = aws_instance.bastion_host.id
  }

  connection {
    type        = "ssh"
    host        = aws_instance.bastion_host.public_dns
    user        = var.ssh_user
    private_key = file(var.aws_private_key_path)
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [data.template_file.provisioner_app.rendered]
  }
}
