
# VPC
resource "google_compute_network" "vpc" {
  name                    = "istio-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "istio-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "192.168.100.0/24"
}

# resource "google_compute_address" "slb_address" {
#   name   = "slb-external-ip"
#   region = google_compute_subnetwork.subnet.region
# }

# output "slb-external-ip" {
#   value = google_compute_address.address_slb.address
# }


# External IP address
resource "google_compute_address" "address" {
  name   = "istio-nat-address"
  region = google_compute_subnetwork.subnet.region
}
# Router
resource "google_compute_router" "router" {
  name    = "istio-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.vpc.id
}



# NAT Gateway
resource "google_compute_router_nat" "nat_gateway" {
  name   = "istio-nat-gateway"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}