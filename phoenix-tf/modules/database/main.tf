
data "aws_ami" "linux_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  owners = ["amazon"]
}

data "aws_region" "current_region" {}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "mongodb_config_bucket" {
  acl = "private"
  force_destroy = true
  tags = {
    Name = "MongoDB config scripts bucket"
  }
}

resource "null_resource" "copy_scripts" {
    depends_on = [aws_s3_bucket.mongodb_config_bucket]

    provisioner "local-exec" {
        command = <<EOT
        aws cp ./scripts/* s3://${aws_s3_bucket.mongodb_config_bucket.id} --acl private
    EOT
    }
}

resource "aws_network_interface" "replica_node_ni" {
    name = "${var.app_name}_mongodb_replica_node_ni"
    description  = "Network Interface for Mongo Node"
    subnet_id = var.primary_node_subnet_id
    security_groups = [aws_security_group.mongodb_sg.id, aws_security_group.mongodb_intra_sg.id]
    source_dest_check = true
    tags = {
        Nework = "private"
    }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    bucket_name   = aws_s3_bucket.mongodb_config_bucket.id
    app_name = var.app_name
    mongodb_version = var.mongodb_version
    vpc_id = var.vpc_id
    mongodb_admin_user = var.mongodb_admin_username
  }
}

resource "aws_instance" "primary_node" {
    name = "${var.app_name}_mongodb_primary_node"
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.replica_node_ni.id
    }
    key_name = var.key_pair_name
    ami = data.aws_ami.linux_ami.id
    iam_instance_profile = aws_iam_instance_profile.mongodb_instance_profile.id
    instance_type=var.mongodb_instance_type
    
    ebs_block_device {
        device_name = "/dev/xvdg"
        volume_type = "io1"
        delete_on_termination = true
        volume_size = 25
        iops = 250
        encrypted = true
    }
    
    ebs_block_device {
        device_name = "/dev/xvdh"
        volume_type = "io1"
        delete_on_termination = true
        volume_size = 25
        iops = 200
        encrypted = true
    }

    ebs_block_device {
        device_name = "/dev/xvdf"
        volume_type = "gp2"
        delete_on_termination = true
        volume_size = 400
        encrypted = true
    }

    user_data = base64encode(data.template_file.user_data.rendered)


    tags = {
        Name = "PrimaryReplicaNode0"
        ClusterReplicaSetCount = "3"
        NodeReplicaSetIndex = "0"
        ReplicaShardIndex = "0"
    }

}

resource "null_resource" "copy_scripts" {
    depends_on = [aws_s3_bucket.mongodb_config_bucket]

    provisioner "local-exec" {
        command = <<EOT
        aws cp ./scripts/* s3://${aws_s3_bucket.mongodb_config_bucket.id} --acl private
    EOT
    }
}

provisioner "remote-exec" {
    inline = [
      "/usr/bin/env bash -c \"timeout 300 sed '/finished-user-data/q' <(tail -f /var/log/cloud-init-output.log)\""
    ]
}