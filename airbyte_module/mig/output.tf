output "airbyte_backend" {
  value = google_compute_region_instance_group_manager.module_group.instance_group
}