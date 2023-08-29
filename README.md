# AWS EC2 GPU Instances

Create an AWS EC2 instance with attached GPU using Terraform and Cloud-Init

## State Bucket Setup

```bash
export REGION="eu-central-1"
export STATE_BUCKET="buildstar-terraform-state"

aws s3api create-bucket --bucket $STATE_BUCKET \
  --region $REGION \
  --create-bucket-configuration \
  LocationConstraint=$REGION

aws s3api put-bucket-encryption --bucket $STATE_BUCKET \
  --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\": \"AES256\"}}]}"

aws dynamodb create-table --table-name Terraform-backend-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

## IAM Setup

```bash
aws iam create-policy --policy-name Terraform-Backend-Policy \
  --policy-document file://policy.json

```
## Run Terraform

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""

docker run --platform linux/amd64 \
  -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
  -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
  -v $(pwd):/terraform -w /terraform hashicorp/terraform init -upgrade
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.34.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>4.34.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | ~> 3.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [random_password.master](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | n/a | `string` | n/a | yes |
| <a name="input_ebs_az"></a> [ebs\_az](#input\_ebs\_az) | n/a | `string` | n/a | yes |
| <a name="input_ebs_encrypted"></a> [ebs\_encrypted](#input\_ebs\_encrypted) | n/a | `string` | n/a | yes |
| <a name="input_ebs_size"></a> [ebs\_size](#input\_ebs\_size) | n/a | `number` | n/a | yes |
| <a name="input_ebs_type"></a> [ebs\_type](#input\_ebs\_type) | n/a | `string` | n/a | yes |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | n/a | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | n/a | `string` | n/a | yes |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | n/a | `list(string)` | n/a | yes |
| <a name="input_max_spot_price"></a> [max\_spot\_price](#input\_max\_spot\_price) | n/a | `number` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_project_azs"></a> [project\_azs](#input\_project\_azs) | n/a | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | n/a | `string` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_rbs_encrypted"></a> [rbs\_encrypted](#input\_rbs\_encrypted) | n/a | `string` | n/a | yes |
| <a name="input_rbs_iops"></a> [rbs\_iops](#input\_rbs\_iops) | n/a | `number` | n/a | yes |
| <a name="input_rbs_size"></a> [rbs\_size](#input\_rbs\_size) | n/a | `number` | n/a | yes |
| <a name="input_rbs_type"></a> [rbs\_type](#input\_rbs\_type) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_spot_type"></a> [spot\_type](#input\_spot\_type) | n/a | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | n/a |
<!-- END_TF_DOCS -->
