
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

resource "aws_cloudformation_stack" "mongo_node" {
    name = "mongodb-primary-node-stack"
    parameters {
        BucketName = aws_s3_bucket.mongodb_config_bucket.id
        ClusterReplicaSetCount = 1
        KeyName = var.key_pair_name
        MongoDBVersion = var.mongodb_version
        MongoDBAdminUsername = var.mongodb_admin_username
        MongoDBAdminPassword = var.mongodb_admin_password
        MongoDBAppUsername = var.mongodb_app_username
        MongoDBAppTestUsername = var.mongodb_app_test_username
        MongoDBAppPassword = var.mongodb_app_user_password
        MongoDBAppTestPassword = var.mongodb_app_test_user_password
        NodeInstanceType = var.mongodb_instance_type
        NodeSubnet = var.primary_node_subnet_id
        MongoDBServerSecurityGroupID = aws_security_group.mongodb_sg.id
        MongoDBServersSecurityGroupID = aws_security_group.mongodb_intra_sg.id
        MongoDBNodeIAMProfileID = aws_iam_instance_profile.mongodb_instance_profile.id
        VPC = var.vpc_id
        StackName = var.app_name
        ImageId = data.aws_ami.linux_ami.image_id
        ReplicaNodeNameTag = "PrimaryReplicaNode0"
        NodeReplicaSetIndex = "0"
        ReplicaShardIndex = "0"
    }

    template_body = file("${path.module}/templates/mongodb-node.json")
    timeout_in_minutes = 3600

}