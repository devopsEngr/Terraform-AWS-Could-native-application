locals {
  is_dev_vpn_enabled = var.dev_vpn_enabled == "on"
}

// CA Certificate

resource "tls_private_key" "ca" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  private_key_pem = tls_private_key.ca[0].private_key_pem

  subject {
    common_name  = "${var.env}.vpn.ca"
    organization = "reach-atribo"
  }
  validity_period_hours = 87600
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "aws_acm_certificate" "ca" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  private_key      = tls_private_key.ca[0].private_key_pem
  certificate_body = tls_self_signed_cert.ca[0].cert_pem
}

resource "aws_ssm_parameter" "vpn_ca_key" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name        = "/${var.env}/shared/vpn-ca-privatekey"
  type        = "SecureString"
  value       = tls_private_key.ca[0].private_key_pem
}

resource "aws_ssm_parameter" "vpn_ca_cert" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name        = "/${var.env}/shared/vpn-ca-cert"
  type        = "SecureString"
  value       = tls_self_signed_cert.ca[0].cert_pem
}

// VPN Endpoint Certificate

resource "tls_private_key" "endpoint" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_cert_request" "endpoint" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  private_key_pem = tls_private_key.endpoint[0].private_key_pem
  subject {
    common_name  = "${var.env}.vpn.endpoint"
    organization = "reach-atribo"
  }
}

resource "tls_locally_signed_cert" "endpoint" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  cert_request_pem      = tls_cert_request.endpoint[0].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca[0].private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca[0].cert_pem
  validity_period_hours = 87600
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "endpoint" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  private_key       = tls_private_key.endpoint[0].private_key_pem
  certificate_body  = tls_locally_signed_cert.endpoint[0].cert_pem
  certificate_chain = tls_self_signed_cert.ca[0].cert_pem
}

resource "aws_ssm_parameter" "vpn_endpoint_key" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name        = "/${var.env}/shared/vpn-endpoint-key"
  type        = "SecureString"
  value       = tls_private_key.endpoint[0].private_key_pem
}

resource "aws_ssm_parameter" "vpn_endpoint_cert" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name        = "/${var.env}/shared/vpn-endpoint-cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.endpoint[0].cert_pem
}

resource "tls_private_key" "client" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  algorithm = "RSA"
}

resource "tls_cert_request" "client" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  private_key_pem = tls_private_key.client[0].private_key_pem
  subject {
    common_name  = "${var.env}.vpn.client"
    organization = "reach-atribo"
  }
}
resource "tls_locally_signed_cert" "client" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  cert_request_pem      = tls_cert_request.client[0].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca[0].private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca[0].cert_pem
  validity_period_hours = 87600
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "aws_acm_certificate" "client" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  private_key       = tls_private_key.client[0].private_key_pem
  certificate_body  = tls_locally_signed_cert.client[0].cert_pem
  certificate_chain = tls_self_signed_cert.ca[0].cert_pem
}

resource "aws_ssm_parameter" "vpn_client_key" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name        = "/${var.env}/shared/vpn-client-key"
  type        = "SecureString"
  value       = tls_private_key.client[0].private_key_pem
}

resource "aws_ssm_parameter" "vpn_client_cert" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name        = "/${var.env}/shared/vpn-client-cert"
  type        = "SecureString"
  value       = tls_locally_signed_cert.client[0].cert_pem
}

resource "aws_ec2_client_vpn_endpoint" "vpn_endpoint" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  description = "Atribo VPN Endpoint"
  server_certificate_arn = aws_acm_certificate.endpoint[0].arn
  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client[0].arn
  }
  connection_log_options {
    enabled = true
    cloudwatch_log_group = "${aws_cloudwatch_log_group.vpn_log_group[0].name}"
  }
  client_cidr_block = "172.16.0.0/22"
  split_tunnel = true
  vpc_id = module.vpc.vpc_id
  dns_servers = ["8.8.8.8", "1.1.1.1"]
  security_group_ids = ["${aws_security_group.vpn_sg[0].id}"]
}

resource "aws_ec2_client_vpn_network_association" "vpn-client-1" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint[0].id
  subnet_id              = module.vpc.private_subnets[0]
}

resource "aws_ec2_client_vpn_network_association" "vpn-client-2" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint[0].id
  subnet_id              = module.vpc.private_subnets[1]
}

resource "aws_ec2_client_vpn_network_association" "vpn-client-3" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint[0].id
  subnet_id              = module.vpc.private_subnets[2]
}

resource "aws_ec2_client_vpn_authorization_rule" "vpn-client" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn_endpoint[0].id
  target_network_cidr    = "10.0.0.0/20"
  authorize_all_groups   = true
  depends_on = [
    aws_ec2_client_vpn_endpoint.vpn_endpoint,
    aws_ec2_client_vpn_network_association.vpn-client-1,
    aws_ec2_client_vpn_network_association.vpn-client-2,
    aws_ec2_client_vpn_network_association.vpn-client-3
  ]
}

resource "aws_security_group" "vpn_sg" {
  count = local.is_dev_vpn_enabled ? 1 : 0

  name_prefix = "${var.env}-vpn-sg"
  description = "Security group for VPN endpoint"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "vpn_ingress" {
  count = local.is_dev_vpn_enabled ? 1 : 0
  
  type                      = "ingress"
  from_port                 = 1433
  to_port                   = 1433
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.vpn_sg[0].id
  security_group_id         = aws_security_group.rds_sg_main.id

  lifecycle {
      create_before_destroy = true
  }

  depends_on = [aws_security_group.rds_sg_main]
}

resource "aws_cloudwatch_log_group" "vpn_log_group" {
  count = local.is_dev_vpn_enabled ? 1 : 0
  
  name = "reach-atribo-${var.env}-vpn-logs"
  retention_in_days = 7
}
