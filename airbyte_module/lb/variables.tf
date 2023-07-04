variable "project" {}
variable "nro" {}
variable "airbyte_backend" {}
variable "dns_primary_zone" {
  type = string
}

#variable "iap_iam_https_resource_accessor_members" {
#  type        = list(string) #formerly list(string), but needs to be decoded from gitlabci using jsondecode first
#  description = "Members to add as (HTTPS) accessors to the app. Must be in the orgagnization already. Format is <member type>:<email / domain>. More information: https://cloud.google.com/billing/docs/reference/rest/v1/Policy#Binding"
#}