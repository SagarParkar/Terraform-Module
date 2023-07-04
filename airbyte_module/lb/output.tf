output "http_forwarding_rule" {
  value = google_compute_global_forwarding_rule.http_default
}

#output "https_forwarding_rule" {
#  value = google_compute_global_forwarding_rule.https_default
#}


output "lb_ip" {
  value = google_compute_global_forwarding_rule.http_default.ip_address
}

output "allow_ip" {
  value = google_compute_global_address.static.address
}