# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required Google APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "container.googleapis.com",      # GKE API
    "servicenetworking.googleapis.com", # Service Networking API
    "sqladmin.googleapis.com",      # Cloud SQL Admin API
    "artifactregistry.googleapis.com", # Artifact Registry API
    "monitoring.googleapis.com",     # Cloud Monitoring API
    "logging.googleapis.com"         # Cloud Logging API
  ])

  service = each.key
  disable_on_destroy = false
}

# VPC Network
resource "google_compute_network" "vpc" {
  name                    = "fullstack-vpc"
  auto_create_subnetworks = false
  depends_on = [google_project_service.required_apis]
}

# Subnet for GKE
resource "google_compute_subnetwork" "subnet" {
  name          = "fullstack-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/16"

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Cloud Router for NAT Gateway
resource "google_compute_router" "router" {
  name    = "fullstack-router"
  region  = var.region
  network = google_compute_network.vpc.name
}

# NAT Gateway
resource "google_compute_router_nat" "nat" {
  name                               = "fullstack-nat"
  router                            = google_compute_router.router.name
  region                            = var.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall rule for internal communication
resource "google_compute_firewall" "internal" {
  name    = "fullstack-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "10.0.0.0/16",
    "10.1.0.0/16",
    "10.2.0.0/16"
  ]
}

# GKE cluster with enhanced configuration
resource "google_container_cluster" "primary" {
  name                     = "fullstack-gke"
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
  network                 = google_compute_network.vpc.name
  subnetwork              = google_compute_subnetwork.subnet.name

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.16.0.0/28"
  }

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "services-range"
  }

  release_channel {
    channel = "REGULAR"
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T00:00:00Z"
      end_time   = "2024-01-02T00:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# Node pool with improved configuration
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.min_node_count

  # Auto-scaling configuration
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Node configuration
  node_config {
    preemptible  = true
    machine_type = var.machine_type
    disk_size_gb = 12
    disk_type    = "pd-standard"

    # Enable workload identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
    }

    tags = ["gke-node", "${var.project_id}-gke"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

# Google Artifact Registry with enhanced configuration
resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  location      = var.region
  repository_id = "fullstack-docker"
  description   = "Docker repository for fullstack app"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

# Cloud SQL instance with enhanced configuration
resource "google_sql_database_instance" "postgres" {
  name                = "fullstack-postgres"
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = false

  settings {
    tier              = var.database_tier
    availability_type = "ZONAL"
    disk_size         = 20
    disk_type        = "PD_SSD"
    
    backup_configuration {
      enabled                        = true
      start_time                    = "02:00"
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc.id
      enable_private_path_for_google_cloud_services = true
    }

    insights_config {
      query_insights_enabled = true
      query_string_length    = 1024
      record_application_tags = true
      record_client_address  = true
    }

    maintenance_window {
      day          = 7
      hour         = 2
      update_track = "stable"
    }
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

# VPC peering for private Cloud SQL access
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# SQL user
resource "google_sql_user" "postgres" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

# Database
resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

# Outputs
output "gke_endpoint" {
  value     = google_container_cluster.primary.endpoint
  sensitive = true
}

output "cloudsql_instance" {
  value = google_sql_database_instance.postgres.connection_name
}

output "artifact_registry_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}
