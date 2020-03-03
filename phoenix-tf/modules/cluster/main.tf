# create an ECS Cluster with capacity provider for the instance autoscale

data "aws_region" "current_region" {}

data "aws_caller_identity" "current" {}

#capacity providere is not yet fully supported by Terraform. So We need this hack
#to automatically provision it
resource "aws_ecs_cluster" "ecs_cluster" {
  name               = var.app_name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  provisioner "local-exec" {
    when = destroy

    command = <<CMD
      # Get the list of capacity providers associated with this cluster
      CAP_PROVS="$(aws ecs describe-clusters --clusters "${self.arn}" \
        --query 'clusters[*].capacityProviders[*]' --output text)"

      # Now get the list of autoscaling groups from those capacity providers
      ASG_ARNS="$(aws ecs describe-capacity-providers \
        --capacity-providers "$CAP_PROVS" \
        --query 'capacityProviders[*].autoScalingGroupProvider.autoScalingGroupArn' \
        --output text)"

      if [ -n "$ASG_ARNS" ] && [ "$ASG_ARNS" != "None" ]
      then
        for ASG_ARN in $ASG_ARNS
        do
          ASG_NAME=$(echo $ASG_ARN | cut -d/ -f2-)

          # Set the autoscaling group size to zero
          aws autoscaling update-auto-scaling-group \
            --auto-scaling-group-name "$ASG_NAME" \
            --min-size 0 --max-size 0 --desired-capacity 0

          # Remove scale-in protection from all instances in the asg
          INSTANCES="$(aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-names "$ASG_NAME" \
            --query 'AutoScalingGroups[*].Instances[*].InstanceId' \
            --output text)"
          aws autoscaling set-instance-protection --instance-ids $INSTANCES \
            --auto-scaling-group-name "$ASG_NAME" \
            --no-protected-from-scale-in
        done
      fi
CMD

  }
}

#generate a random name for the capacity provider
resource "random_uuid" "capacity_name" {}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.app_name}_capacity_provider_${random_uuid.capacity_name.result}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }

  tags = {
    Name        = "Capacity provider for ECS cluster"
    Environment = var.environment
    Application = var.app_name
  }
}

#get the ecs-optimized image
data "aws_ami" "stable_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ecs-optimized*"]
  }

  owners = ["amazon"]
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    ecs_config   = var.ecs_config
    ecs_logging  = var.ecs_logging
    cluster_name = var.app_name
  }
}

resource "aws_launch_template" "cluster_launch_tpl" {

  name_prefix = "${var.app_name}_launch_tpl_"

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  image_id = data.aws_ami.stable_ecs.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = var.instance_type

  key_name = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.cluster_security_group.id]

  user_data = base64encode(data.template_file.user_data.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.app_name} instance"
      Environment = var.environment
      Application = var.app_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*
* Autoscaling group is formed by a mixed of spot instances and on-demand instances
*/
resource "aws_autoscaling_group" "autoscaling_group" {
  name_prefix           = "${var.app_name}_cluster_asg_"
  max_size              = var.max_size
  min_size              = var.min_size
  desired_capacity      = var.min_size
  vpc_zone_identifier   = var.private_subnet_ids
  protect_from_scale_in = true

  mixed_instances_policy {

    instances_distribution {
      on_demand_base_capacity                  = "1"
      on_demand_percentage_above_base_capacity = "50"
      spot_allocation_strategy                 = "lowest-price" #default value
      spot_instance_pools                      = "2"            #default value
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.cluster_launch_tpl.id
        version            = "$Latest"
      }

      override {
        instance_type     = "t3.medium"
        weighted_capacity = "1"
      }

      override {
        instance_type     = "m4.large"
        weighted_capacity = "2"
      }

    }
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.app_name} instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = var.environment
      propagate_at_launch = true
    },
    {
      key                 = "Application"
      value               = var.app_name
      propagate_at_launch = true
    },
    {
      key                 = "DependsId"
      value               = var.depends_id
      propagate_at_launch = true
    },
  ]
}
