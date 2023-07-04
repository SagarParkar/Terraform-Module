# ###IAP 
# resource "google_iap_client" "project_client" {
#   display_name = "${var.nro}-client"
#   brand        =  google_iap_brand.project_brand.name
# }

# resource "google_iap_brand" "project_brand" {
#   support_email     = "support@example.com"
#   application_title = "Cloud IAP protected Application"
#   project           = google_project_service.project_service.project
# }

# # resource "google_project" "project" {
# #   project_id = var.project
# # name       = var.project_name
# # #   org_id     = "123456789"
# # }

# resource "google_project_service" "project_service" {
#   project =  var.project
#     service = "iap.googleapis.com"
# }