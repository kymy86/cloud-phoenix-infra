resource "aws_alb" "loadbalancer" {
  name            = "${var.app_name}-alb"
  subnets         = [var.public_subnet_ids]
  security_groups = [aws_security_group.lb_sg.id]

  tags = {
    Name        = "${var.app_name} Load Balancer"
    Environment = var.environment
    Application = var.app_name
  }
}

resource "aws_alb_target_group" "target_group" {
  name     = "${var.app_name}-${var.environment}-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    matcher = "200,304"
    path    = var.healthcheck_path
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action = {
    target_group_arn = aws_alb_target_group.target_group.id
    type             = "forward"
  }
}

#################### ENABLE HTTPS  ##########################
/*resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.backend_certificate
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action = {
    target_group_arn = aws_alb_target_group.target_group.id
    type             = "forward"
  }
}


resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.loadbalancer.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action = {
    target_group_arn = "${aws_alb_target_group.target_group.id}"
    type             = "forward"
  }
}*/

resource "aws_alb_listener_rule" "front_end_url" {
  listener_arn = aws_alb_listener.front_end.arn

  action {
    target_group_arn = aws_alb_target_group.target_group.id
    type             = "forward"
  }

  condition {
    field  = "path-pattern"
    values = ["/"]
  }
}
