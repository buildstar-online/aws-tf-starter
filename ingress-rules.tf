resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "vnc" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 5900
  ip_protocol       = "tcp"
  to_port           = 5900
}

resource "aws_vpc_security_group_ingress_rule" "novnc" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "rdp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 3389
  ip_protocol       = "tcp"
  to_port           = 3389
}

resource "aws_vpc_security_group_ingress_rule" "sunshine_tcp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 47984
  ip_protocol       = "tcp"
  to_port           = 47990
}

resource "aws_vpc_security_group_ingress_rule" "sunshine_udp" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 47998
  ip_protocol       = "udp"
  to_port           = 48000
}

resource "aws_vpc_security_group_ingress_rule" "sunshine_tcp2" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 48010
  ip_protocol       = "tcp"
  to_port           = 48010
}

resource "aws_vpc_security_group_ingress_rule" "kubernetes" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 6443
  ip_protocol       = "tcp"
  to_port           = 6443
}

resource "aws_vpc_security_group_ingress_rule" "nicedcv" {
  security_group_id = module.security_group.security_group_id
  cidr_ipv4         = module.vpc.vpc.public_subnets_cidr_blocks
  from_port         = 8443
  ip_protocol       = "tcp"
  to_port           = 8443
}






