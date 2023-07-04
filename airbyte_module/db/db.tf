resource "google_sql_database" "airbyte_database" {
  name     = "${var.nro}-airbyte-db-database"
  project  = var.project
  instance = google_sql_database_instance.instance.name
  depends_on = [
    google_sql_user.users
  ]
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "instance" {
  name             = "${var.nro}-airbyte-db-instance1"
  region           = var.region
  database_version = var.postgresql_version
  project          = var.project
  settings {
       tier      = "db-custom-4-4096"
    disk_size = "10"
    disk_type = "PD_SSD"
    database_flags {
      name  = "max_connections"
      value = 200
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.selflink
      authorized_networks {
        name  = "Cosmos-airbyte-federated"
        value = var.allow_ip
      }
    }

    backup_configuration {
      enabled    = true
      start_time = "5:46"
      location   = var.region
    }

  }

  deletion_protection = "false"
  depends_on = [
       var.vpc_private_connection
  ]
}

resource "random_password" "pass" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "users" {
  name            = "${var.nro}-airbyte-db-user"
  project         = var.project
  deletion_policy = "ABANDON"
  instance        = google_sql_database_instance.instance.name
  password        = random_password.pass.result
}