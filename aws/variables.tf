variable "region" {
  description = "Region for the aws provider"
  type        = string
  sensitive   = false
}

variable "availability_zones" {
  description = "Availability zones for the aws provider"
  type        = list(string)
  sensitive   = false
}

variable "vpc_cidr_block" {
  description = "The cidr block for the vpc."
  type        = string
  sensitive   = false
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr_blocks" {
  description = "The private subnets used within the vpc."
  type        = list(string)
  sensitive   = false
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "access_key" {
  description = "Access key for the aws provider"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "Secret key for the aws provider"
  type        = string
  sensitive   = true
}
