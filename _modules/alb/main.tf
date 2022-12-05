resource "aws_security_group" "alb_security_group" {
  name        = "${var.name}-alb-sg"
  description = "EC2 security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "alb_security_group_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_security_group.id

  from_port   = 80
  to_port     = 80
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_security_group_https" {
  type              = "ingress"
  security_group_id = aws_security_group.alb_security_group.id

  from_port   = 443
  to_port     = 443
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_security_group_egress" {
  security_group_id = aws_security_group.alb_security_group.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_alb" "alb" {
  internal                   = false
  load_balancer_type         = "application"
  name                       = "${var.name}-alb"
  subnets                    = var.subnet_ids
  security_groups            = [aws_security_group.alb_security_group.id]
  idle_timeout               = 1800
  desync_mitigation_mode     = "strictest"
  enable_deletion_protection = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-alb"
    }
  )
}

resource "aws_alb_listener" "alb_http" {
  load_balancer_arn = aws_alb.alb.arn
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

resource "aws_alb_listener" "alb_https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "application/json"
      message_body = "Bad Gateway"
      status_code  = "503"
    }
  }
  tags = var.tags
}

resource "aws_alb_target_group" "tg" {
  name        = "${var.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = "HTTP"
    matcher  = "200,404"
    path     = "/" // required only for HTTP & HTTPS
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  listener_arn = aws_alb_listener.alb_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
  condition {
    path_pattern {
      values = ["*/media/*", "*/admin*", "/static*", "/media/"]
    }
  }
  tags = var.tags
}

resource "aws_alb_listener_rule" "api_rule" {
  listener_arn = aws_alb_listener.alb_https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
  condition {
    path_pattern {
      values = ["*/api*", "*/api/*", "*/api/v2/"]
    }
  }
  condition {
    http_header {
      http_header_name = "gateway_key"
      values           = ["vsPbBOxnjDMI9KEZhYxOrNqfFsxaP6wI"]
    }
  }
  tags = var.tags
}
