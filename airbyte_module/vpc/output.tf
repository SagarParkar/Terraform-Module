output "vpc_network" {
  value = google_compute_network.vpc.name
}

output "vpc_subnetwork" {
  value = google_compute_subnetwork.private_subnet_1.name
}

output "selflink" {
  value = google_compute_network.vpc.self_link
}

#output "vpc_private_connection" {
#  value = google_service_networking_connection.private_vpc_connection
#}