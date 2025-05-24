provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "default" {
  name                    = "default"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "default-allow-app-ports" {
  name    = "default-allow-app-ports"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["3000", "8000"]
  }

  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["app-server"]
}

resource "google_compute_instance" "app_vm" {
  name         = "app-vm"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = google_compute_network.default.name
    access_config {}
  }

  tags = ["app-server"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose git
    usermod -aG docker google
    cd /home/google
    git clone ${var.repo_url} app
    cd app
    mv compose.yaml docker-compose.yml
    docker-compose up -d
  EOT
}