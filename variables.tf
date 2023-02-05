variable "project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ec2_instance_type" {
  type = string
}

variable "max_spot_price" {
  type = number
}

variable "spot_type" {
  type = string
}

variable "project_azs" {
  type = list(string)
}

variable "ebs_az" {
  type = string
}

variable "ebs_size" {
  type = number
}

variable "ebs_type" {
  type = string
}

variable "ebs_encrypted" {
  type = string
}

variable "rbs_size" {
  type = number
}

variable "rbs_type" {
  type = string
}

variable "rbs_encrypted" {
  type = string
}

variable "rbs_iops" {
  type = number
}

variable "ingress_rules" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

variable "vpc_cidr" {
  type = string
}

variable "dhcp_options_domain_name" {
  type = string
}

variable "environment_name" {
  type = string
}
