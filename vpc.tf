module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                 = "${var.env}-vpc"
  cidr                 = var.cidr
  azs                  = [var.azs[0], var.azs[1], var.azs[2]]
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  enable_dhcp_options  = true
  dhcp_options_domain_name_servers  = ["AmazonProvidedDNS"]
  dhcp_options_ntp_servers          = ["169.254.169.123"]

  tags = {
    Environment = var.env
    Type        = "Managed by Terraform"
  }
}
