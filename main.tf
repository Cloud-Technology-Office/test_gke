resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "gke-subnet"
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_container_cluster" "primary" {
  name = var.cluster_name

  remove_default_node_pool = false

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.vpc_subnetwork.name

  private_cluster_config {
    master_global_access_config {
      enabled = true
    }
  }

  node_pool {
    name               = "default-pool"
    initial_node_count = 1
  }

  deletion_protection = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}