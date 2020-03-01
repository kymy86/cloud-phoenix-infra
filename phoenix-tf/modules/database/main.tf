
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
        working_dir = "./modules/database"
        command = <<EOT
        aws s3 cp ./scripts s3://${aws_s3_bucket.mongodb_config_bucket.id} --acl private --recursive
    EOT
    }
}

resource "aws_cloudformation_stack" "mongo_primary_node" {
    name = "primary-node-stack"
    parameters = {
        BucketName = aws_s3_bucket.mongodb_config_bucket.id
        ClusterReplicaSetCount = var.cluster_replicaset_count
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
        MongoDBTestAppName = var.mongodb_db_test_app_name
        MongoDBAppName = var.mongodb_db_app_name
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

    depends_on = [null_resource.copy_scripts]
}

resource "aws_cloudformation_stack" "mongo_secondary_node_1" {
    name = "secondary-node-1-stack"
    parameters = {
        BucketName = aws_s3_bucket.mongodb_config_bucket.id
        ClusterReplicaSetCount = var.cluster_replicaset_count
        KeyName = var.key_pair_name
        MongoDBVersion = var.mongodb_version
        MongoDBAdminUsername = var.mongodb_admin_username
        MongoDBAdminPassword = var.mongodb_admin_password
        MongoDBAppUsername = var.mongodb_app_username
        MongoDBAppTestUsername = var.mongodb_app_test_username
        MongoDBAppPassword = var.mongodb_app_user_password
        MongoDBAppTestPassword = var.mongodb_app_test_user_password
        NodeInstanceType = var.mongodb_instance_type
        NodeSubnet = var.secondary_node_1_subnet_id
        MongoDBTestAppName = var.mongodb_db_test_app_name
        MongoDBAppName = var.mongodb_db_app_name
        MongoDBServerSecurityGroupID = aws_security_group.mongodb_sg.id
        MongoDBServersSecurityGroupID = aws_security_group.mongodb_intra_sg.id
        MongoDBNodeIAMProfileID = aws_iam_instance_profile.mongodb_instance_profile.id
        VPC = var.vpc_id
        StackName = var.app_name
        ImageId = data.aws_ami.linux_ami.image_id
        ReplicaNodeNameTag = "SecondaryReplicaNode1"
        NodeReplicaSetIndex = "1"
        ReplicaShardIndex = "0"
    }

    template_body = file("${path.module}/templates/mongodb-node.json")
    timeout_in_minutes = 3600

    depends_on = [null_resource.copy_scripts]
}

resource "aws_cloudformation_stack" "mongo_secondary_node_2" {
    name = "secondary-node-2-stack"
    parameters = {
        BucketName = aws_s3_bucket.mongodb_config_bucket.id
        ClusterReplicaSetCount = var.cluster_replicaset_count
        KeyName = var.key_pair_name
        MongoDBVersion = var.mongodb_version
        MongoDBAdminUsername = var.mongodb_admin_username
        MongoDBAdminPassword = var.mongodb_admin_password
        MongoDBAppUsername = var.mongodb_app_username
        MongoDBAppTestUsername = var.mongodb_app_test_username
        MongoDBAppPassword = var.mongodb_app_user_password
        MongoDBAppTestPassword = var.mongodb_app_test_user_password
        NodeInstanceType = var.mongodb_instance_type
        NodeSubnet = var.secondary_node_2_subnet_id
        MongoDBTestAppName = var.mongodb_db_test_app_name
        MongoDBAppName = var.mongodb_db_app_name
        MongoDBServerSecurityGroupID = aws_security_group.mongodb_sg.id
        MongoDBServersSecurityGroupID = aws_security_group.mongodb_intra_sg.id
        MongoDBNodeIAMProfileID = aws_iam_instance_profile.mongodb_instance_profile.id
        VPC = var.vpc_id
        StackName = var.app_name
        ImageId = data.aws_ami.linux_ami.image_id
        ReplicaNodeNameTag = "SecondaryReplicaNode2"
        NodeReplicaSetIndex = "2"
        ReplicaShardIndex = "0"
    }

    template_body = file("${path.module}/templates/mongodb-node.json")
    timeout_in_minutes = 3600

    depends_on = [null_resource.copy_scripts]
}
