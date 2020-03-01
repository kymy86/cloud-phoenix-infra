provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_dynamodb_table" "terraform-state-locking" {
   name = var.lock_table_name
   hash_key = "LockID"
   read_capacity = 20
   write_capacity = 20

   attribute {
      name = "LockID"
      type = "S"
   }

   tags = {
     Name = "Phoenix Terraform Lock Table"
   }
}

resource "aws_s3_bucket" "phoenix-terraform-bucket" {
  acl = "private"
  force_destroy = true
  bucket = var.state_bucket_name
  tags = {
    Name = "Phoenix terraform state bucket"
  }
}

resource "aws_ecr_repository" "phoenix_repo" {
    name = var.phoenix_repo
    tags = {
        Name = "Phoenix docker repository"
    }
}

data "template_file" "ecr_policy_template" {
    template = file("${path.module}/policies/ecr-policy.json")

}

resource "aws_ecr_lifecycle_policy" "phoenix_repo_policy" {
    repository = aws_ecr_repository.phoenix_repo.name
    policy = data.template_file.ecr_policy_template.rendered
}
