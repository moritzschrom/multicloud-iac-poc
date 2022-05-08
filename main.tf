module "aws" {
  source = "./aws"

  aws_region             = var.aws_region
  aws_availability_zones = var.aws_availability_zones
  aws_access_key         = var.aws_access_key
  aws_secret_key         = var.aws_secret_key
}
