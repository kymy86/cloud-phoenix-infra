resource "aws_security_group" "bastion_sg" {
  name        = "${var.app_name}-sg-bastion-host"
  description = "Security group for bastion host instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ips_bastion_source
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security group for bastion host instance"
  }
}
