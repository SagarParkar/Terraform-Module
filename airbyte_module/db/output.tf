output "db_user_name" {
  value = google_sql_user.users.name
}


output "db_password" {
  value = google_sql_user.users.password
}

output "db_name" {
  value = google_sql_database.airbyte_database.name
}

output "db_host" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "db_instance" {
  value = google_sql_database_instance.instance
}