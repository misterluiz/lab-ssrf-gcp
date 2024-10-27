# Lab-SSRF-GCP 🔄🖥️🌐 

This repository contains Terraform code to set up a Server-Side Request Forgery (SSRF) vulnerability testing lab in Google Cloud Platform (GCP). This lab environment is intended for educational purposes, allowing users to safely learn and test SSRF vulnerabilities in a controlled setting.

Overview
SSRF is a vulnerability that allows an attacker to make requests from the server to other systems, potentially accessing internal services or exposing sensitive data. This lab leverages GCP resources to create an environment for testing SSRF scenarios, with infrastructure managed via Terraform for easy setup and teardown.

Prerequisites
Before you begin, make sure you have:
- Terraform installed
- A Google Cloud Platform (GCP) account
- GCP CLI installed and configured for your project

Setup
1 - Clone the Repository:
```bash
git clone https://github.com/misterluiz/lab-ssrf-gcp.git
cd lab-ssrf-gcp
```
2 - Login in GCP account:
```bash
gcloud auth login
```
3 - Access the main.tf file and change the project id to your gcp account.

4 - Initialize Terraform:
```bash
terraform init
```
5 - Apply the Terraform Configuration:
```bash
terraform apply
```
6 - After completing the lab destroy the infrastructure created:
```bash
terraform destroy
```
