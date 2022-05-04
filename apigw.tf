resource "aws_security_group" "apigw" {
  name        = "ekant_api_test"
  description = "controls access of the apig ingress controller"
  vpc_id      = var.vpc_id
lifecycle {
    create_before_destroy = true
  }
tags = {
    Name = "ekant_api_test"
  }
}
resource "aws_security_group_rule" "apigw_https_access_external" {
  type              = "ingress"
  description       = "accept secure HTTP port from anywhere"
  security_group_id = aws_security_group.apigw.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
# we only allow the vpc link to go to the internal ALB
resource "aws_security_group_rule" "apigw_https_access_alb" {
  type                     = "egress"
  description              = "Allow all access for egress"
  security_group_id        = aws_security_group.apigw.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}
# we also allow the APIGW vpc link to go to the internal ALB
resource "aws_security_group_rule" "alb_https_access_apigw" {
  type                     = "ingress"
  description              = "accept secure HTTP port from the API Gateway VPC Link"
  security_group_id        = aws_security_group.alb.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.apigw.id
}

resource "aws_apigatewayv2_vpc_link" "apigw" {
  name               = "apigw"
  security_group_ids = [aws_security_group.apigw.id]
  subnet_ids         = var.public_subnet_ids
tags = {
    Name = "ekant_vpc_link"
  }
}

resource "aws_apigatewayv2_domain_name" "apigw_1" {
domain_name = "api1.ekant.com"
domain_name_configuration {
    certificate_arn = "arn:aws:acm:ap-southeast-2:******:certificate/******"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
resource "aws_apigatewayv2_domain_name" "apigw_2" {
domain_name = "api2.ekant.com"
domain_name_configuration {
    certificate_arn = "arn:aws:acm:ap-southeast-2:******:certificate/******"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}
resource "aws_apigatewayv2_domain_name" "apigw_3" {
domain_name = "api3.ekant.com"
domain_name_configuration {
    certificate_arn = "arn:aws:acm:ap-southeast-2:******:certificate/******"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}


resource "aws_apigatewayv2_api" "apigw" {
  name          = "apigw-proxy"
  protocol_type = "HTTP"
}

# create a stage for each API gateway ingress environment
resource "aws_apigatewayv2_stage" "apigw_1" {
  api_id        = aws_apigatewayv2_api.apigw.id
  name          = "api1"
  auto_deploy   = false
}

# create a stage for each API gateway ingress environment
resource "aws_apigatewayv2_stage" "apigw_2" {
  api_id        = aws_apigatewayv2_api.apigw.id
  name          = "api2"
  auto_deploy   = false
  lifecycle {
  ignore_changes = [
    # This is needed to be ignored as we are updating the route
    #by null resource and next apply should not revert the changes #
    deployment_id,
  ]
}
}
# create a stage for each API gateway ingress environment
resource "aws_apigatewayv2_stage" "apigw_3" {
  api_id        = aws_apigatewayv2_api.apigw.id
  name          = "api3"
  auto_deploy   = false
  lifecycle {
  ignore_changes = [
    # This is needed to be ignored as we are updating the route
    #by null resource and next apply should not revert the changes #
    deployment_id,
  ]
}
}

# create a DNS mapping for each stage
resource "aws_apigatewayv2_api_mapping" "apigw_1" {
  api_id      = aws_apigatewayv2_api.apigw.id
  domain_name = aws_apigatewayv2_domain_name.apigw_1.id
  stage       = aws_apigatewayv2_stage.apigw_1.id
}

resource "aws_apigatewayv2_api_mapping" "apigw_2" {
  api_id      = aws_apigatewayv2_api.apigw.id
  domain_name = aws_apigatewayv2_domain_name.apigw_2.id
  stage       = aws_apigatewayv2_stage.apigw_2.id
}

resource "aws_apigatewayv2_api_mapping" "apigw_3" {
  api_id      = aws_apigatewayv2_api.apigw.id
  domain_name = aws_apigatewayv2_domain_name.apigw_3.id
  stage       = aws_apigatewayv2_stage.apigw_3.id
}


# create the HTTP proxy integration to the internal load balancer
resource "aws_apigatewayv2_integration" "apigw_1" {
  api_id             = aws_apigatewayv2_api.apigw.id
  description        = "Proxy forward to the internal load balancer"
  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_lb_listener.https_1.arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.apigw.id
  #TLS config is used for API Gateway to connects to the backend host using HTTPS.
  #API Gateway uses the hostname to verify the hostname on the integration's certificate.
  tls_config {
    server_name_to_verify = "api1.ekant.com"
  }
}

# create the HTTP proxy integration to the internal load balancer
resource "aws_apigatewayv2_integration" "apigw_2" {
  api_id             = aws_apigatewayv2_api.apigw.id
  description        = "Proxy forward to the internal load balancer"
  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_lb_listener.https_2.arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.apigw.id
  #TLS config is used for API Gateway to connects to the backend host using HTTPS.
  #API Gateway uses the hostname to verify the hostname on the integration's certificate.
  tls_config {
    server_name_to_verify = "api2.ekant.com"
  }
}


# create the HTTP proxy integration to the internal load balancer
resource "aws_apigatewayv2_integration" "apigw_3" {
  api_id             = aws_apigatewayv2_api.apigw.id
  description        = "Proxy forward to the internal load balancer"
  integration_type   = "HTTP_PROXY"
  integration_uri    = aws_lb_listener.https_3.arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.apigw.id
  #TLS config is used for API Gateway to connects to the backend host using HTTPS.
  #API Gateway uses the hostname to verify the hostname on the integration's certificate.
  tls_config {
    server_name_to_verify = "api3.ekant.com"
  }
}

# create a route path for anything to the load balancer integration
# API requires at least one aws_apigatewayv2_route resource associated with that API.
resource "aws_apigatewayv2_route" "apigw_1" {
  api_id    = aws_apigatewayv2_api.apigw.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.apigw_1.id}"
  lifecycle {
  ignore_changes = [
    target,
  ]
}
}


# # create a deployment for the integration
resource "aws_apigatewayv2_deployment" "apigw_1" {
  api_id      = aws_apigatewayv2_api.apigw.id
  description = "Terraform managed deployment of the proxy routes"
  lifecycle {
      create_before_destroy = true
    }
}

resource "aws_apigatewayv2_deployment" "apigw_2" {
  api_id      = aws_apigatewayv2_api.apigw.id
  description = "Terraform managed deployment of the proxy routes"
  lifecycle {
      create_before_destroy = true
    }
}

resource "aws_apigatewayv2_deployment" "apigw_3" {
  api_id      = aws_apigatewayv2_api.apigw.id
  description = "Terraform managed deployment of the proxy routes"
  lifecycle {
      create_before_destroy = true
    }
}

## Workaround to update the routes and do the deployment.##
resource "null_resource" "update_1" {
  provisioner "local-exec" {
    command = "aws apigatewayv2 update-route --api-id ${aws_apigatewayv2_api.apigw.id} --route-id ${aws_apigatewayv2_route.apigw_1.id} --target integrations/${aws_apigatewayv2_integration.apigw_2.id}"
  }
  provisioner "local-exec" {
    command = "aws apigatewayv2 create-deployment --api-id ${aws_apigatewayv2_api.apigw.id} --stage-name api2"
  }
}

## Workaround to update the routes and do the deployment.##
resource "null_resource" "update_2" {
  provisioner "local-exec" {
    command = "aws apigatewayv2 update-route --api-id ${aws_apigatewayv2_api.apigw.id} --route-id ${aws_apigatewayv2_route.apigw_1.id} --target integrations/${aws_apigatewayv2_integration.apigw_3.id}"
  }
  provisioner "local-exec" {
    command = "aws apigatewayv2 create-deployment --api-id ${aws_apigatewayv2_api.apigw.id} --stage-name api3"
  }
}
