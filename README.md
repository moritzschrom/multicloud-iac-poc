# Deploying and automating multi-cloud architectures using Infrastructure as Code

This repository contains code written as part of my bachelor thesis "Deploying and automating multi-cloud architectures using Infrastructure as Code".

This repository defines infrastructure for both AWS and Google, by using a local `aws` and a 
local `google` module.

The infrastructure consists of a VPC, a load balancer and multiple autoscaling compute 
instances.

In addition, a GitHub workflow is defined, which automatically triggers a run of Terraform 
once the infrastructure within this code is updated and pushed to the remote GitHub repository.
