#locals {
#  dns_zone_name = "${var.nro}.${var.dns_primary_zone}"
#}

resource "google_compute_network" "vpc" {
  name                    = "${var.nro}-airbyte-vpc1"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
  project                 = var.project
}

resource "google_compute_subnetwork" "private_subnet_1" {
  purpose       = "PRIVATE"
  name          = "${var.nro}-airbyte-private-subnet-1"
  ip_cidr_range = "10.2.0.0/16"
  network       = google_compute_network.vpc.name
  region        = var.region
  project       = var.project
}

resource "google_compute_firewall" "firewall" {
  name    = "${var.nro}-firewall-externalssh"
  network = google_compute_network.vpc.name
  project = var.project
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "airbyte_router" {
  name    = "airbyte-router"
  network = google_compute_network.vpc.self_link
  region  = "us-central1"
}

resource "google_compute_router_nat" "airbyte_nat" {
  name            = "airbyte-nat"
  router          = google_compute_router.airbyte_router.name
  region = var.region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


#VPC peering
#resource "google_compute_global_address" "private_ip_block" {
#  name          = "${var.nro}-private-ip-block"
#  purpose       = "VPC_PEERING"
#  address_type  = "INTERNAL"
#  ip_version    = "IPV4"
#  prefix_length = 20
#  network       = google_compute_network.vpc.self_link
#  project       = var.project
#}


#resource "google_service_networking_connection" "private_vpc_connection" {
#  network                 = google_compute_network.vpc.self_link
#  service                 = "servicenetworking.googleapis.com"
#  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
#}