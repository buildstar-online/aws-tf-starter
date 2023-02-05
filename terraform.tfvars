# Project Options
project_name     = "starter"
region           = "eu-central-1"
environment_name = "dev"

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
project_azs = ["eu-central-1a", "eu-central-1b"]

# Network Configuration
# For more information see here: https://github.com/terraform-aws-modules/terraform-aws-vpc
vpc_cidr                 = "10.0.0.0/16"
public_subnets           = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets          = ["10.0.3.0/24", "10.0.4.0/24"]
database_subnets         = ["10.0.5.0/24", "10.0.6.0/24"]
dhcp_options_domain_name = "lan"

# For more information on these see here: https://github.com/terraform-aws-modules/terraform-aws-security-group
# full list of rules here: https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf
ingress_rules = ["http-80-tcp",
  "https-443-tcp",
  "all-icmp",
  "ssh-tcp",
  "grafana-tcp",
  "loki-grafana",
  "loki-grafana-grpc",
  "prometheus-http-tcp",
  "prometheus-node-exporter-http-tcp",
  "prometheus-pushgateway-http-tcp",
  "promtail-http"
]

# EC2 Options
ec2_instance_type = "g5.xlarge"
max_spot_price    = 0.40
spot_type         = "persistent"

# Main Drive
rbs_size      = 50
rbs_type      = "io1"
rbs_encrypted = false
rbs_iops      = 2500
