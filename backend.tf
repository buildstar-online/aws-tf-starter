terraform {
    backend "s3" {
        bucket         = "buildstar-terraform-state"
        encrypt        = true
        key            = "dev.buildstar.tfstate"
        region         = "eu-central-1"
        dynamodb_table = "Terraform-backend-lock"
    }
}
