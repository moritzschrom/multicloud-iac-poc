# AWS 
variable "aws_region" {
  description = "Region for the aws provider"
  type        = string
  sensitive   = false
}

variable "aws_availability_zones" {
  description = "Availability zones for the aws provider"
  type        = list(string)
  sensitive   = false
}

variable "aws_access_key" {
  description = "Access key for the aws provider"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "Secret key for the aws provider"
  type        = string
  sensitive   = true
}

# Google
variable "google_project" {
  description = "Project id for the google provider"
  type        = string
  sensitive   = false
}

variable "google_region" {
  description = "Region for the google provider"
  type        = string
  sensitive   = false
}

variable "google_credentials" {
  description = "Credentials key for the google provider"
  type        = string
  sensitive   = true
}