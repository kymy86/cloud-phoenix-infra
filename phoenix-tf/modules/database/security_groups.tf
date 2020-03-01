resource "aws_security_group" "mongodb_access_sg" {
  name        = "${var.app_name}_mongodb_access_sg"
  description = "Instances with access to MongoDB servers"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "Security group MongoDB instances"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_security_group" "mongodb_sg" {
  name        = "${var.app_name}_mongodb_sg"
  description = "MongoDB server management and access ports"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  }

  ingress {
    from_port       = 27017
    to_port         = 27030
    protocol        = "tcp"
    security_groups = [aws_security_group.mongodb_access_sg.id]
  }

  ingress {
    from_port       = 28017
    to_port         = 28017
    protocol        = "tcp"
    security_groups = [aws_security_group.mongodb_access_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Security group for MongoDB server mgm and access ports"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_security_group" "mongodb_intra_sg" {
  name        = "${var.app_name}_mongodb_intra_sg"
  description = "MongoDB inter-server communication and management ports"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.mongodb_sg.id]
  }

  ingress {
    from_port       = 27017
    to_port         = 27030
    protocol        = "tcp"
    security_groups = [aws_security_group.mongodb_sg.id]
  }

  ingress {
    from_port       = 28017
    to_port         = 28017
    protocol        = "tcp"
    security_groups = [aws_security_group.mongodb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "MongoDB inter-server communication and management ports"
    Environment = var.environment
    Application = var.app_name
  }
}