data "aws_caller_identity" "current" {}

# Load contextual data
locals {
  name             = "ex-${replace(basename(path.cwd), "_", "-")}"
  current_identity = data.aws_caller_identity.current.arn
}

# Virtual Private Cloud for isolation
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = var.vpc_cidr

  azs                              = var.project_azs
  private_subnets                  = var.private_subnets
  public_subnets                   = var.public_subnets
  database_subnets                 = var.database_subnets
  default_vpc_enable_dns_hostnames = true
  default_vpc_enable_dns_support   = true
  dhcp_options_domain_name         = var.dhcp_options_domain_name

  create_database_subnet_group           = false
  create_database_subnet_route_table     = false
  create_database_internet_gateway_route = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}

# Security Group - EC2 Firewall and Routes
module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = local.name
  description = "Security group for use with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = var.ingress_rules
  egress_rules        = ["all-all"]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}
