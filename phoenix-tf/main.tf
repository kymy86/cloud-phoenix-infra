provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

#create key pairs to access the instances
resource "aws_key_pair" "instance_key" {
  key_name   = var.aws_key_pair_name
  public_key = file(var.aws_public_key_path)
}

#set-up VPC and subnets
module "networking" {
  source = "./modules/networking"
  app_name = var.app_name
  az_zones = var.aws_az[var.aws_region]
  environment = var.environment
}

/*
* Set-up the bastion host instance to grant access
* via SSH to the various instances in the private subnets
*/
module "bastion" {
  source = "./modules/bastion"
  vpc_id = module.networking.vpc_id
  app_name = var.app_name
  environment = var.environment
  aws_key_pair_name = var.aws_key_pair_name
  subnet_ids = module.networking.public_subnet_ids
  aws_private_key_path = var.aws_private_key_path
  ips_bastion_source = var.ips_bastion_source
  depends_id = module.networking.nat_gateway
}

/**
* Set-up the ECS cluster with the capacity provisioner
* and the Load Balancer
*/
module "cluster" {
  source      = "./modules/cluster"
  app_name    = var.app_name
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  bastion_sg = module.bastion.bastion_host_sg_id
  max_size = var.cluster_max_size
  min_size = var.cluster_min_size
  private_subnet_ids= module.networking.private_subnet_ids
  public_subnet_ids = module.networking.public_subnet_ids
  key_pair_name = var.aws_key_pair_name
  depends_id = module.networking.nat_gateway
}

/**
* Set-up the MongoDB replicaset
*/
module "database" {
  source = "./modules/database"
  app_name = var.app_name
  environment = var.environment
  vpc_id = module.networking.vpc_id
  primary_node_subnet_id = module.networking.private_subnet_ids[0]
  secondary_node_1_subnet_id = module.networking.private_subnet_ids[1]
  secondary_node_2_subnet_id = module.networking.private_subnet_ids[2]
  bastion_sg = module.bastion.bastion_host_sg_id
  cluster_sg = module.cluster.cluster_security_group
  key_pair_name = var.aws_key_pair_name
  depends_id = module.networking.nat_gateway
}

/**
* Set-up the ECS phoenix application
* as ECS service
*/
module "phoenix" {
  source = "./modules/services/phoenix"
  app_name = var.app_name
  environment = var.environment
  cluster_id = module.cluster.cluster_id
  docker_repo_url = "${var.docker_repo_url}/${var.app_name}"
  container_port = var.container_port
  container_name = var.image_name
  alb_target_group = module.cluster.alb_target_group_id
  mongo_prod_connection_string = module.database.mongo_connection_string_app
  mongo_test_connection_string = module.database.mongo_connection_string_test_app
  notification_email = var.notification_email
  aws_profile = var.aws_profile
  depends_id = module.networking.nat_gateway
  resource_label = "${module.cluster.resource_label_lb}/${module.cluster.resource_label_targetgroup}"
}

/**
* Set-up the CI/CD pipeline with CodePipeline
*/
module "cicd_pipeline" {
  source = "./modules/pipeline"
  docker_registry_url = var.docker_repo_url
  github_repo = var.github_repo
  vpc_id = module.networking.vpc_id
  private_subnets = module.networking.private_subnet_ids
  security_group_ids = [module.database.mongo_cluster_sg]
  ssm_test_db_parameter = module.phoenix.test_db_param_name
  github_oauth_token = var.github_oauth_token
  github_owner = var.github_owner
  github_repo_name = var.github_repo_name
}