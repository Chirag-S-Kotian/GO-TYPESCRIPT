variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "min_node_count" {
  description = "Minimum number of GKE nodes"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of GKE nodes"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-medium"
}

variable "database_tier" {
  description = "The machine type to use for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "fullstack_db"
}

variable "db_user" {
  description = "PostgreSQL user name"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}
