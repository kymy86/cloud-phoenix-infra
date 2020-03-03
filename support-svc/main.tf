provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_dynamodb_table" "terraform-state-locking" {
   name = "${var.app_name}${var.lock_table_name}"
   hash_key = "LockID"
   read_capacity = 20
   write_capacity = 20

   attribute {
      name = "LockID"
      type = "S"
   }

   tags = {
     Name = "${title(var.app_name)} Terraform Lock Table"
   }
}

resource "aws_s3_bucket" "terraform-bucket" {
  acl = "private"
  force_destroy = true
  tags = {
    Name = "${title(var.app_name)} terraform state bucket"
  }
}

resource "aws_ecr_repository" "application_repo" {
    name = var.app_name
    tags = {
        Name = "${title(var.app_name)} docker repository"
    }
}

data "template_file" "ecr_policy_template" {
    template = file("${path.module}/policies/ecr-policy.json")

}

resource "aws_ecr_lifecycle_policy" "phoenix_repo_policy" {
    repository = aws_ecr_repository.application_repo.name
    policy = data.template_file.ecr_policy_template.rendered
}
