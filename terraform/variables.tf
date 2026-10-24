# define the configuration inputs

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for TravelMemory assignment"
}

variable "project_name" {
  type        = string
  default     = "travelmemory"
  description = "project name for resource naming and tags"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "CIDR for TravelMemory assignment"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.20.1.0/24"
  description = "CIDR for TravelMemory public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.20.2.0/24"
  description = "CIDR for TravelMemory private subnet"
}

variable "allow_ssh_cidr" {
  type        = string
  default     = "49.37.110.72/32"
  description = "check your ip with # curl https://checkip.amazonaws.com"
}

variable "key_pair_name" {
  type        = string
  default     = "travelmemory-lab-key"
  description = "key pair created for this project"
}

variable "web_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 type for web/app"
}

variable "db_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 type for DB instance"
}

variable "enable_nat_gateway" {
  description = "Whether to provision a NAT Gateway for private subnet internet access"
  type        = bool
  default     = false
}





