resource "google_compute_instance_template" "default" {
  name_prefix = "${var.nro}-airbyte-template-"
  region      = var.region
  project     = var.project
  disk {
    disk_name    = "${var.nro}-airbyte-boot-disk"
    auto_delete  = true
    boot         = true
    device_name  = "boot-disk-0"
    mode         = "READ_WRITE"
    source_image = var.image_name
    type         = "PERSISTENT"
    disk_size_gb = 40
  }
  #labels       = var.labels
  machine_type = var.machine_size
  metadata = {
    startup-script = file("startupscript.sh")
  }
  network_interface {
    #access_config {
    #}
    network    = var.vpc_network
    subnetwork = var.vpc_subnetwork
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  tags = ["allow-health-check"]

  lifecycle {
    create_before_destroy = true
  }
}

###Instance group manager
resource "google_compute_region_instance_group_manager" "module_group" {
  name               = "${var.nro}-module-instance-group-managed"
  base_instance_name = "${var.nro}-airbyte"
  project            = var.project
  target_size        = var.region_instances

  named_port {
    name = "airbyte"
    port = "8000"
  }
  named_port {
    name = "grafana"
    port = "3000"
  }

  #named_port {
  #  name = "https"
  #  port = "443"
  #}
  # named_port {
  #   name = "http"
  #   port = "3000"
  # }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  region                           = var.region
  distribution_policy_zones        = var.distribution_zones
  distribution_policy_target_shape = "EVEN"
  update_policy {
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "REPLACE"
    max_unavailable_fixed          = 3
    replacement_method             = "RECREATE"
    most_disruptive_allowed_action = "REPLACE"
  }

  auto_healing_policies {
    health_check = google_compute_health_check.default.id
    initial_delay_sec = 480
  }


}
resource "google_compute_region_autoscaler" "auto-scaler" {
  name   = "airbyte-autoscaler"
  #zone   = "us-central1-a"
  region = var.region
  target = google_compute_region_instance_group_manager.module_group.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = 300

    cpu_utilization {
      target = 0.8
    }
  }
}

resource "google_compute_health_check" "default" {
  name         = "airbyte-health-check"
  #request_path = "/health_check"
  #port = 8000
  
  timeout_sec        = 60
  unhealthy_threshold = 8
  check_interval_sec = 120
  tcp_health_check {
    port = "8000"
  }
}
resource "google_compute_firewall" "allow-prom3" {
  name    = "allow-prom3"
  network = var.vpc_network
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["8000","3000"]#["8080","9090","3000","9100","9323","3100","8686","8000"]
  }
  source_ranges = ["0.0.0.0/0"] #["49.36.121.137","${google_compute_instance.my_vm.network_interface[0].access_config[0].nat_ip}"]
}