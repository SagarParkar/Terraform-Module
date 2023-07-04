resource "google_service_account" "instance_account" {
  account_id   = "${var.nro}-airbyte-sa"
  display_name = "${var.nro}-SA"
  project      = var.project
}

resource "google_project_iam_member" "iam" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}

resource "google_project_iam_member" "iap" {
  project = var.project
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}

resource "google_project_iam_member" "instance" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}

resource "google_project_iam_member" "logging" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}


resource "google_project_iam_member" "bigqueryDataEditor" {
  project = var.project
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}

resource "google_project_iam_member" "storage" {
  project = var.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}

resource "google_project_iam_member" "bigqueryUser" {
  project = var.project
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.instance_account.email}"
}