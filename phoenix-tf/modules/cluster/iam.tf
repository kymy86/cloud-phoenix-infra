
//instance profile assumed by autoscaling group intances
resource "aws_iam_role" "ecs_cluster_role" {
  name               = "${var.app_name}_ecs_cluster_role"
  assume_role_policy = file("${path.module}/policies/cluster-ip-assume-role-policy.json")
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.app_name}_instance_profile"
  role = aws_iam_role.ecs_cluster_role.name
}

resource "aws_iam_role_policy" "ecs_policy" {
  name   = "${var.app_name}_ecs_policy"
  role   = aws_iam_role.ecs_cluster_role.id
  policy = file("${path.module}/policies/cluster-ip-policy.json")
}

