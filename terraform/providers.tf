# AWS region to use
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project    = var.project_name
      ManagedBy  = "Terraform"
      Assignment = "TravelMemory"
    }
  }
}