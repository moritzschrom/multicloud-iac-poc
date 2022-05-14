terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.20.0"
    }
  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = var.credentials
}
