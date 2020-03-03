
#Role assumed by the CodeBuild project
resource "aws_iam_role" "codebuild_role" {
  name               = "${var.app_name}_codebuild_role"
  assume_role_policy = file("${path.module}/policies/codebuild-assume-role-policy.json")
}

data "template_file" "codebuild_service_role_policy" {
  template = file("${path.module}/policies/codebuild-policy.json")

  vars = {
    app_name = var.app_name
    region = data.aws_region.current_region.name
    account_id = data.aws_caller_identity.current.account_id
    subnet_1 = var.private_subnets[0]
    subnet_2 = var.private_subnets[1]
    subnet_3 = var.private_subnets[2]
    cw_logs_group = aws_cloudwatch_log_group.codebuild_logs.arn
  }
}

resource "aws_iam_role_policy" "codebuild_service_role_policy" {
  name   = "${var.app_name}_codebuild_policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.template_file.codebuild_service_role_policy.rendered
}

#Role assumed by the CodePipeline project
resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.app_name}_codepipeline_role"
  assume_role_policy = file("${path.module}/policies/codepipeline-assume-role-policy.json")
}

resource "aws_iam_role_policy" "codepipeline_service_role_policy" {
  name   = "${var.app_name}_codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = file("${path.module}/policies/codepipeline-policy.json")
}