data "aws_caller_identity" "current" {}

# Load contextual data
locals {
  name             = "ex-${replace(basename(path.cwd), "_", "-")}"
  current_identity = data.aws_caller_identity.current.arn
}

# Random Password Creation for VM and RDS
resource "random_password" "master" {
  length = 10
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
  source  = "terraform-aws-modules/security-group/aws"

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

# Machine Image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# EC2 Spot Instance
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.name

  create_spot_instance        = true
  spot_price                  = var.max_spot_price
  spot_type                   = var.spot_type

  spot_wait_for_fulfillment   = true
  ami                         = data.aws_ami.ubuntu.id
  
  instance_type               = var.ec2_instance_type
  monitoring                  = true
  vpc_security_group_ids      = [module.security_group.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  
  associate_public_ip_address = true
  user_data                   = file("user-data.yaml")
  #user_data_replace_on_change = true
  availability_zone           = var.project_azs[0]
  ebs_optimized               = true

  spot_launch_group                = null
  spot_block_duration_minutes      = null

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}
