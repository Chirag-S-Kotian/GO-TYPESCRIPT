// file: variables.tf
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "repo_url" {
  description = "GitHub repository HTTPS URL containing the compose.yaml"
  type        = string
  default     = "https://github.com/Chirag-S-Kotian/GO-TYPESCRIPT"
}