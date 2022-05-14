module "aws" {
  source = "./aws"

  region             = var.aws_region
  availability_zones = var.aws_availability_zones
  access_key         = var.aws_access_key
  secret_key         = var.aws_secret_key
}

module "google" {
  source = "./google"

  project     = var.google_project
  region      = var.google_region
  credentials = var.google_credentials
}
