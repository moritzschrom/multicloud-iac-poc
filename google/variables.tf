variable "project" {
  description = "GCP project id for the google provider"
  type        = string
  sensitive   = false
}

variable "region" {
  description = "Region for the google provider"
  type        = string
  sensitive   = false
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for the google provider"
  type        = string
  sensitive   = false
  default     = "us-central1-a"
}

variable "credentials" {
  description = "Credentials key for the google provider"
  type        = string
  sensitive   = true
}