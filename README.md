<h1 align="center">
  AWS Starter-Project
</h1>

<p align="center">
  <img width="64" src="https://icons-for-free.com/iconfiles/png/512/amazon+aws-1331550885897517282.png">
  <img width="64" src="https://icons-for-free.com/iconfiles/png/512/terraform-1331550893634583795.png">
<p>

<p align="center">
Create and manage AWS resources using Terraform and Github Actions
</p>
<br>

TODO: customize the user-data files to use gaming drivers as well: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-gaming-driver

## Prerequisites

1. An AWS account

   This project uses non-free resources. You will need to sign up for an AWS account, verify your identity as well as provide a payment method. One of the benefits of automating your cloud projects with Terraform is the ease with which you may re-create and destroy cloud resources. Make use of this festure to `turn off` your project when it is not in use.

   - [Sign up for AWS](https://aws.amazon.com/)

2. AWS CLI
   
   You will need the AWS cli tool to authenticate your innitial account as well as create some base resources and permissions that will allow terraform to control your project.
   - [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - or use the docker container `docker pull amazon/aws-cli:latest`

3. Terraform

   You will need terraform to manage all of the terraform (obviously). Be aware that terraform doesn't have ARM64 support yet so M1/M2 mac users will need to use the docker version of the cli with the `--platform linux/amd64` flag.
   - [Installing Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
   - [Dockerhub images](https://hub.docker.com/r/hashicorp/terraform/)

4. Resource Quotas (Optional)

   AWS as well as most other cloud providers make use of `Quotas` to limit the amount of resources customers can create. This prevents abuse of their `free-tier` as well as stops customer from accidentially letting autoscaling generate massive bills. If you plan on deploying GPU/TPU accelerators or more than a couple VMs, you will need to request a quota increase for those resources. See below for more information.

   - [How to request a quota increase on AWS](https://docs.aws.amazon.com/servicequotas/latest/userguide/request-quota-increase.html)

5. Infracost (Optional)

   Infracost shows cloud cost estimates for Terraform. It lets engineers see a cost breakdown and understand costs before making changes, either in the terminal, VS Code or pull requests.
   
   - [Infracost Quickstart Guide](https://www.infracost.io/docs/#quick-start)
   - [Run Infracost automatically in your Github Actions Workflows](https://github.com/infracost/actions)
   - [Check out the project out on Github](https://github.com/infracost/infracost)


## Get Started

1. Create the Terraform state bucket

    ```bash
    export REGION="eu-central-1"
    export STATE_BUCKET="buildstar-terraform-state"

    aws s3api create-bucket --bucket $STATE_BUCKET \
      --region $REGION \
      --create-bucket-configuration \
      LocationConstraint=$REGION

    aws s3api put-bucket-encryption --bucket $STATE_BUCKET \
      --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault \":{\"SSEAlgorithm\": \"AES256\"}}]}"

    aws dynamodb create-table --table-name Terraform-backend-lock \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    ```

2. Create IAM Roles
  
    ```bash
    aws iam create-policy --policy-name Terraform-Backend-Policy-S3 \
      --policy-document file://s3-policy.json

    aws iam create-policy --policy-name Terraform-Backend-Policy-DynamoDB \
      --policy-document file://dynamo-policy.json
    ```

3. Create an IAM User

    ```bash
    export ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

    aws iam create-user --user-name terraform

    aws iam create-access-key --user-name terraform

    aws iam attach-user-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/Terraform-Backend-Policy-S3  \
      --user-name terraform

    aws iam attach-user-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/Terraform-Backend-Policy-DynamoDB  \
      --user-name terraform
    ```

4. Initialize Terraform

    ```bash
    export AWS_ACCESS_KEY_ID=""
    export AWS_SECRET_ACCESS_KEY=""

    docker run --platform linux/amd64 \
      -e "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
      -e "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
      -v $(pwd):/terraform -w /terraform hashicorp/terraform init -upgrade
    ```

## Instance Types

This project is tested using the G5, G4dn, and G3 sinatnce tiers which utilize Nvidia A10, T4 and M60 GPUs. If you do not need a GPU, you are advised to consider Hetzner or Equinix who have better prices on CPU-only instances. Buildstar Online has a quota maximum limit of 48 vCores in eu-central.

- G5 instances feature NVIDIA A10G Tensor Core GPUs and second generation AMD EPYC processors.

    | Instance Size| GPUs | GPU RAM | vCPUs | RAM (GiB) | Disk Size (GB) | Network (Gbps) | Price |
    |   ---        |  --- |  ---    |    ---|        ---|             ---|             ---|    ---|
    | g5.xlarge    | 1    | 24      | 4     | 16        | 250            | 10             |$0.3774|
    | g5.2xlarge   | 1    | 24      | 8     | 32        | 450            | 10             |$0.4547|
    | g5.4xlarge   | 1    | 24      | 16    | 64        | 600            | 25             |$0.6092|
    | g5.12xlarge  | 4    | 96      | 48    | 192       | 3800           | 40             |$2.1278|

- G4dn instances feature NVIDIA T4 GPUs and custom Intel Cascade Lake CPU

    | Instance Size| GPUs | GPU RAM | vCPUs | RAM (GiB) | Disk Size (GB) | Network (Gbps) | Price |
    |   ---        |  --- |  ---    |    ---|        ---|             ---|             ---|    ---|
    | g4dn.xlarge  | 1    | 16      | 4     | 16        | 125            | 25             |$0.1974|
    | g4dn.2xlarge | 1    | 16      | 8     | 32        | 225            | 25             |$0.282|
    | g4dn.4xlarge | 1    | 16      | 16    | 64        | 225            | 25             |$0.462|
    | g4dn.12xlarge| 4    | 64      | 48    | 192       | 900            | 50             |$1.467|

- G3 instances provides access to NVIDIA Tesla M60 GPUs, each with up to 2,048 parallel processing cores and 8 GiB of GPU memory in a dual-socket Intel Xeon E5 2686 v4 system.

    | Instance Size| GPUs | GPU RAM | vCPUs | RAM (GiB) | Disk Size (GB) | Network (Gbps) | Price |
    |   ---        |  --- |  ---    |    ---|        ---|             ---|             ---|    ---|
    | g3s.xlarge   | 1    | 8       | 4     | 16        | not included   | 20             |$0.2814|
    | g3.4xlarge   | 1    | 8       | 16    | 32        | not included   | 20             |$0.4511|
    | g3.8xlarge   | 2    | 16      | 32    | 64        | not included   | 20             |$0.855|

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>5.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_instance"></a> [ec2\_instance](#module\_ec2\_instance) | terraform-aws-modules/ec2-instance/aws | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | n/a | `string` | n/a | yes |
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
