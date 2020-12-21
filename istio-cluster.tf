# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 2
  /* If set location = region
  If region have 3 zones, and node_count equal 2 
  => Total have 6 nodes in all zones
  */

  /* If set location = zone, and node_count equal 2 
  => Total have 2 nodes in zone
  */

  node_config {
    disk_size_gb = 30
    # disk_type = "pd-ssd"
    # pd-standard', 'pd-balanced' or 'pd-ssd' 
    # If unspecified, the default disk type is 'pd-standard'

    # oauth_scopes = [
    #   "https://www.googleapis.com/auth/logging.write",
    #   "https://www.googleapis.com/auth/monitoring",
    # ]

    labels = {
      env = "istio-node"
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}



# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "istio-cluster"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
  cluster_ipv4_cidr_block  = "10.10.0.0/16"
  services_ipv4_cidr_block = "192.168.0.0/24"
  }

  private_cluster_config  {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
}
