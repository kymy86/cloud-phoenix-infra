resource "aws_security_group" "cluster_security_group" {
  name        = "${var.app_name}_cluster_security_group"
  description = "Security group for ECS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  }

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Security group for the ECS cluster"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_security_group" "lb_sg" {
  description = "Control access to the application Load Balancer"
  vpc_id      = var.vpc_id
  name        = "${var.app_name}_load_balancer"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "Security group for Load Balancer"
    Environment = var.environment
    Application = var.app_name
  }
}