resource "aws_lb" "lb" {
  name               = "Sparrow-${var.env}-alb-dmz"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnets
  tags               = var.tags
}

resource "aws_lb_target_group" "tg" {
  name     = "Sparrow-${var.env}-trg-dmz"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health_check"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "lb_http_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = var.tags
}
resource "aws_lb_listener" "lb_https_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.load_balancer_certificate

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "BAD Gateway"
      status_code  = "503"
    }
  }
  tags = var.tags
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.lb_https_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    path_pattern {
      values = ["/static/*", "/media/*", "*/media/*", "*/admin*"]
    }
  }
  tags = var.tags
}
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.lb_https_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  condition {
    path_pattern {
      values = ["*/api/*", "*/api/v2/", "*/api*"]
    }
  }
  condition {
    http_header {
      http_header_name = "gateway_key"
      values           = ["${var.gateway_key}"]
    }
  }
  tags = var.tags
}

resource "aws_lb_listener_certificate" "lb_https_listener_certificate" {
  listener_arn    = aws_lb_listener.lb_https_listener.arn
  certificate_arn = var.load_balancer_certificate
}
