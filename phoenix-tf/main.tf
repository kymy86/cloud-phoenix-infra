provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

module "networking" {
  source = "./modules/networking"
  app_name = var.app_name
  az_zones = var.aws_az[var.aws_region]
  aws_key_pair_name = var.aws_key_pair_name
  environment = var.environment
}

module "bastion" {
  source = "./modules/bastion"
  vpc_id = module.networking.vpc_id
  app_name = var.app_name
  environment = var.environment
  aws_key_pair_name = var.aws_key_pair_name
  subnet_ids = module.networking.public_subnet_ids
  aws_private_key_path = var.aws_private_key_path
  ips_bastion_source = var.ips_bastion_source
}

module "cluster" {
  source      = "./modules/cluster"
  app_name    = var.app_name
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  bastion_sg = module.bastion.bastion_host_sg_id
  max_size = var.cluster_max_size
  min_size = var.cluster_min_size
  private_subnet_ids= module.networking.private_subnet_ids
  key_pair_name = var.aws_key_pair_name
}

module "phoenix" {
    source = "./modules/services/phoenix"
    app_name = var.app_name
    environment = var.environment
    cluster_id = module.cluster.cluster_id
    docker_repo_url = var.docker_repo_url
    container_port = var.container_port
    alb_target_group = module.cluster.alb_target_group_id
}