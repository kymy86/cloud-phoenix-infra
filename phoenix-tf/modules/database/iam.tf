resource "aws_iam_role" "mongodb_cluster_role" {
  name               = "${var.app_name}_mongodb_node_role"
  assume_role_policy = file("${path.module}/policies/mongodb-node-assume-role-policy.json")
}

data "template_file" "mongo_cluster_policy" {
  template = file("${path.module}/policies/mongodb-cluster-policy.json")

  vars = {
    bucket_arn = aws_s3_bucket.mongodb_config_bucket.arn
    region = data.aws_region.current_region.name
    account_id = data.aws_caller_identity.current.account_id
  }
}

resource "aws_iam_role_policy" "mongodb_policy" {
  name   = "${var.app_name}_mongodb_policy"
  role   = aws_iam_role.mongodb_cluster_role.id
  policy = data.template_file.mongo_cluster_policy.rendered
}

resource "aws_iam_instance_profile" "mongodb_instance_profile" {
  name = "${var.app_name}_mongodb_instance_profile"
  role = aws_iam_role.mongodb_cluster_role.name
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name               = "${var.app_name}_dlm_lifecycle_role"
  assume_role_policy = file("${path.module}/policies/dlm-lifecycle-role-policy.json")
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name   = "${var.app_name}_dlm_lifecycle_policy"
  role   = aws_iam_role.dlm_lifecycle_role  .id
  policy = file("${path.module}/policies/dlm-lifecycle-policy.json")
}