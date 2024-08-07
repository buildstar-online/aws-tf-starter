# Machine Image
data "aws_ami" "debian12" {
  most_recent = true
  owners = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "template_file" "this" {
  template = file("${path.module}/user-data.tftpl")

  vars = {
    HOSTNAME              = var.hostname
    USERNAME              = var.username
    GITHUB_USERNAME       = var.github_username
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    REGION                = var.region
  }
}

# EC2 Spot Instance
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = local.name

  create_spot_instance = true
  spot_price           = var.max_spot_price
  spot_type            = var.spot_type

  spot_wait_for_fulfillment = true
  ami                       = data.aws_ami.debian12.id

  instance_type          = var.ec2_instance_type
  monitoring             = true
  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  associate_public_ip_address = true
  user_data                   = data.template_file.this.rendered
  user_data_replace_on_change = true
  availability_zone           = var.project_azs[0]
  ebs_optimized               = true

  spot_launch_group           = null
  spot_block_duration_minutes = null

  root_block_device = [
    {
      encrypted   = false
      volume_type = "gp3"
      throughput  = 700
      volume_size = 250
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.environment_name}"
  }
}
