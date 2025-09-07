locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

# Create application load balancer
resource "aws_lb" "load_balancer" {
  name               = "${var.project_name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  ip_address_type    = "ipv4"
  subnets = [
    var.public_subnet_A_id,
    var.public_subnet_B_id
  ]

  #enable_deletion_protection = false

  tags = {
    Environment = "project"
  }

}

# load balancer listener
resource "aws_lb_listener" "lb_http_listner" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }

}

# load balancer listener rule
resource "aws_lb_listener_rule" "lb_http_listner_rule" {
  listener_arn = aws_lb_listener.lb_http_listner.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }


}

# Create backend target group
resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.project_name}-LB-TG"
  target_type = "instance"
  port        = local.http_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }

}