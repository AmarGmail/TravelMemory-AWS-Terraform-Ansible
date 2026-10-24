# Define Terraform version and provider version
terraform {
  # minimum required terraform version
  required_version = ">= 1.6.0"

  # where to obtain AWS provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Note: Terraform uses provider to translate resources such as VPC,
# instances into AWS API operations.

