# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "fullstack-gke"
  location = var.region
  remove_default_node_pool = true
  initial_node_count = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1
  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    disk_size_gb = 30
  }
}

# Google Artifact Registry for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  provider = google
  location = var.region
  repository_id = "fullstack-docker"
  description  = "Docker repository for fullstack app"
  format       = "DOCKER"
}

# Cloud SQL (Postgres) instance
resource "google_sql_database_instance" "postgres" {
  name             = "fullstack-postgres"
  database_version = "POSTGRES_15"
  region           = var.region
  settings {
    tier = "db-f1-micro"
    disk_size = 10
    disk_type = "PD_SSD"
    activation_policy = "ALWAYS"
    ip_configuration {
      ipv4_enabled = true
      # No authorized networks specified; remove the block or specify a value if needed
      # authorized_networks {}
    }
  }
}

resource "google_sql_user" "postgres" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password_wo = var.db_password
}

resource "google_sql_database" "app_db" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
}

# Output cluster info
output "gke_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "artifact_registry_repo" {
  value = google_artifact_registry_repository.docker_repo.repository_id
}

output "cloudsql_instance" {
  value = google_sql_database_instance.postgres.connection_name
}
