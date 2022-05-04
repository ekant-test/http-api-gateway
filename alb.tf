resource "aws_lb" "alb_1" {
  name               = "ekant-test-1"
  load_balancer_type = "application"
  subnets            = var.private_subnet_ids
  internal           = true
  security_groups    = [aws_security_group.alb.id]
tags = {
    Name = "ekant-test"
  }
}

# the default listener to which all workloads can be attached
resource "aws_lb_listener" "https_1" {
  load_balancer_arn = aws_lb.alb_1.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:ap-southeast-2:******:certificate/********"
default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "server 1 ok"
      status_code = "200"
    }
  }
}
###---- Load Balancer 2 -----###
resource "aws_lb" "alb_2" {
  name               = "ekant-test-2"
  load_balancer_type = "application"
  subnets            = var.private_subnet_ids
  internal           = true
  security_groups    = [aws_security_group.alb.id]
tags = {
    Name = "ekant-test"
  }
}

# the default listener to which all workloads can be attached
resource "aws_lb_listener" "https_2" {
  load_balancer_arn = aws_lb.alb_2.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:ap-southeast-2::******::certificate/********"
default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "server 2 ok"
      status_code = "200"
    }
  }
}
###---- Load Balancer 3-----###
resource "aws_lb" "alb_3" {
  name               = "ekant-test-3"
  load_balancer_type = "application"
  subnets            = var.private_subnet_ids
  internal           = true
  security_groups    = [aws_security_group.alb.id]
tags = {
    Name = "ekant-test"
  }
}

# the default listener to which all workloads can be attached
resource "aws_lb_listener" "https_3" {
  load_balancer_arn = aws_lb.alb_3.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:ap-southeast-2:********:certificate/********"
default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "server 3 ok"
      status_code = "200"
    }
  }
}

# ---- load balancer access controls -------------------------------------------
resource "aws_security_group" "alb" {
  name        = "ekant-test"
  description = "controls access of the application load balancer"
  vpc_id      = var.vpc_id
lifecycle {
    create_before_destroy = true
  }
tags = {
    Name = "ekant-test"
  }
}
# we allow all internal networks access to the alb
resource "aws_security_group_rule" "alb_http_access_internal" {
  type              = "ingress"
  description       = "accept plain HTTP port from internal networks"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
# we allow all internal networks access to the alb
resource "aws_security_group_rule" "alb_https_access_internal" {
  type              = "ingress"
  description       = "accept secure HTTP port from internal networks"
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# we only allow the vpc link to go to the internal ALB
resource "aws_security_group_rule" "apigw_https_access" {
  type                     = "egress"
  description              = "Allow all access for egress"
  security_group_id        = aws_security_group.alb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
