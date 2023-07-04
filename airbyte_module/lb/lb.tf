locals {
  dns_zone_name = "${var.nro}.${var.dns_primary_zone}"
}

resource "google_compute_global_address" "static" {
  project    = var.project
  name       = "${var.nro}-lb-ipv4"
  ip_version = "IPV4"
} 

resource "google_compute_health_check" "default_lb" {
  name               = "${var.nro}-airbyte-basic-check"
  project            = var.project
  check_interval_sec = 5
  healthy_threshold  = 2
  tcp_health_check {
    port               = 8000
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
  }
  timeout_sec         = 5
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "backend_service" {
  name      = "${var.nro}-backend-service"
  #port = 8000
  port_name = "airbyte"
  protocol  = "HTTP"
  project   = var.project

  backend {
    group = var.airbyte_backend
  }

  health_checks = [
    google_compute_health_check.default_lb.id,
  ]
}

resource "google_compute_health_check" "grafana_healthcheck" {
  name               = "${var.nro}-grafana-basic-check"
  project            = var.project
  check_interval_sec = 5
  healthy_threshold  = 2
  tcp_health_check {
    port               = 3000
    port_specification = "USE_FIXED_PORT"
    proxy_header       = "NONE"
  }
  timeout_sec         = 5
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "grafana_service" {
  name      = "${var.nro}-grafana-backend-service"
  port_name = "grafana"
  protocol  = "HTTP"
  project   = var.project

  backend {
    group = var.airbyte_backend
  }

  health_checks = [
    google_compute_health_check.grafana_healthcheck.id,
  ]
}

resource "google_compute_global_forwarding_rule" "http_default" {
  name                  = "${var.nro}-http-content-rule"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.static.address
}

resource "google_compute_global_forwarding_rule" "https_default" {
  name                  = "${var.nro}-https-content-rule"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443-443"
  target                = google_compute_target_https_proxy.https_default.id
  ip_address            = google_compute_global_address.static.address
}

resource "google_compute_target_https_proxy" "https_default" {
  name    = "${var.nro}-https-lb-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.airbyte_cert.name,
    google_compute_managed_ssl_certificate.grafana_cert.name

  ]
  depends_on = [
    google_compute_managed_ssl_certificate.airbyte_cert,
    google_compute_managed_ssl_certificate.grafana_cert
  ]
  project = var.project
}

resource "google_compute_managed_ssl_certificate" "airbyte_cert" {
   name    = "${var.nro}-airbyte-ssl-cert"
   project = var.project

  managed {
    domains = ["airbyte.${local.dns_zone_name}"]
  }
}

resource "google_compute_managed_ssl_certificate" "grafana_cert" {
   name    = "${var.nro}-grafana-ssl-cert"
   project = var.project

  managed {
    domains = ["grafana.${local.dns_zone_name}"]
  }
}


resource "google_compute_target_http_proxy" "default" {
  name    = "test-proxy"
  url_map = google_compute_url_map.default.id
}
resource "google_compute_url_map" "default" {
  name            = "airbyte-lb"
  default_service = google_compute_backend_service.backend_service.id

  host_rule {
    hosts        = ["airbyte.${local.dns_zone_name}"]
    path_matcher = "${var.nro}-airbyte"
  }

  host_rule {
    hosts        = ["grafana.${local.dns_zone_name}"]
    path_matcher = "${var.nro}-grafana"
  }

  path_matcher {
    name            = "${var.nro}-airbyte"
    default_service = google_compute_backend_service.backend_service.id

    #path_rule {
    #  paths   = ["/*"]
    #  service = google_compute_backend_service.module_service.id
    #}

  }

  path_matcher {
    name            = "${var.nro}-grafana"
    default_service = google_compute_backend_service.grafana_service.id

    #path_rule {
    #  paths   = ["/*"]
    #  service = google_compute_backend_service.grafana_service.id
    #}

  }
}

#DNS
#resource "google_dns_managed_zone" "managed_zone" {
#  project  = var.project
#  name     = "${var.nro}-zone"
#  dns_name = "${local.dns_zone_name}."
#}

#resource "google_dns_record_set" "airbyte_dns_record" {
#  project = var.project
#  name    = "airbyte.${google_dns_managed_zone.managed_zone.dns_name}"
#  type    = "A"
#  ttl     = 300

#  managed_zone = google_dns_managed_zone.managed_zone.name

#  depends_on = [
#    google_compute_global_forwarding_rule.https_default,
#    google_compute_global_forwarding_rule.http_default
#  ]

#  rrdatas = ["${google_compute_global_forwarding_rule.https_default.ip_address}"]
#}

#resource "google_dns_record_set" "grafana_dns_record" {
#  project = var.project
#  name    = "grafana.${google_dns_managed_zone.managed_zone.dns_name}"
#  type    = "A"
#  ttl     = 300

#  managed_zone = google_dns_managed_zone.managed_zone.name

#  depends_on = [
#    google_compute_global_forwarding_rule.https_default,
#    google_compute_global_forwarding_rule.http_default
#  ]

#  rrdatas = ["${google_compute_global_forwarding_rule.https_default.ip_address}"]
#}