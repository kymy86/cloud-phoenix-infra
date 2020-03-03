
data "aws_region" "current_region" {}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "codebuild_logs" {
  name              = "/${var.app_name}/codebuild"
  retention_in_days = 7
}

data "template_file" "buildspec" {
  template = file("${path.module}/buildspec/buildspec.yml")
}

resource "aws_codebuild_source_credential" "_" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_oauth_token
}

#CodeBuild project
resource "aws_codebuild_project" "phoenix_project" {
    name = "${var.app_name}-project"
    description = "CodeBuild project for ${var.app_name} app"
    service_role = aws_iam_role.codebuild_role.arn
    badge_enabled = true

    artifacts {
        type = "NO_ARTIFACTS"
    }

    cache {
        type = "NO_CACHE"
    }

    environment {
        compute_type = "BUILD_GENERAL1_SMALL"
        image = "aws/codebuild/standard:3.0"
        type = "LINUX_CONTAINER"
        image_pull_credentials_type = "CODEBUILD"
        privileged_mode = true

        environment_variable {
            name = "DB_CONNECTION_STRING"
            value = var.ssm_test_db_parameter
            type = "PARAMETER_STORE"
        }

        environment_variable {
            name = "NAME"
            value = var.app_name
        }

        environment_variable {
            name = "REGISTRY_URL"
            value = var.docker_registry_url
        }
    }

    logs_config {
        cloudwatch_logs {
            status = "ENABLED"
            group_name = aws_cloudwatch_log_group.codebuild_logs.name
            stream_name = "${var.app_name}_"
        }
    }

    source {
        type = "GITHUB"
        location = var.github_repo
        git_clone_depth = 0
        buildspec = data.template_file.buildspec.rendered

        auth {
            type = "OAUTH"
            resource = aws_codebuild_source_credential._.arn
        }
    }

    vpc_config {
        vpc_id = var.vpc_id
        subnets = var.private_subnets
        security_group_ids = var.security_group_ids
    }

}

#bucket needed by CodePipeline to store the artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  acl    = "private"
  force_destroy = true
}

#CodePipeline project
resource "aws_codepipeline" "codepipeline" {

    name = "${var.app_name}-pipeline"
    role_arn = aws_iam_role.codepipeline_role.arn

    artifact_store {
        location = aws_s3_bucket.codepipeline_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name = "Source"
            category = "Source"
            owner = "ThirdParty"
            provider = "GitHub"
            version = "1"
            output_artifacts = ["SourceArtifact"]

            configuration = {
                Owner = var.github_owner
                Repo = var.github_repo_name
                Branch = var.github_branch
            }
        }
    }

    stage {
        name = "Build"
        action {
            name = "Build"
            category = "Build"
            owner = "AWS"
            version = "1"
            provider = "CodeBuild"
            input_artifacts  = ["SourceArtifact"]
            output_artifacts = ["BuildArtifact"]
            
            configuration = {
                ProjectName = aws_codebuild_project.phoenix_project.id
            }
            
        }
    }

    stage {
        name = "Deploy"
        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "ECS"
            version = "1"
            input_artifacts = ["BuildArtifact"]

            configuration = {
                ClusterName = var.app_name
                DeploymentTimeout = "30"
                ServiceName = "${var.app_name}-svc"
            }
        }
    }
}