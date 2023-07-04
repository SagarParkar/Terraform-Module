variable "image_name" {
  default = "sparkar-airbyte-packer-1685354515"
}
variable "project" {
  default = "mystic-impulse-384712"
}
variable "nro" {
  default = "sag"
}
variable "region" {
  default = "us-central1"
}
variable "zone" {
  default = "us-central1-a"
}
#variable "image_name" {}
variable "machine_size" {
  default = "e2-medium"
}
variable "dns_primary_zone" {
  default = "airbyte.systems"
}
#variable "postgre_version" {}
variable "region_instances" {
  default = "1"
}
variable "distribution_zones" {
  default = ["us-central1-a","us-central1-b"]
  type = list(string)
}
#variable "org_id" {}
#variable "project_name" {}
#variable "label_name" {
#  type        = string
#  description = "Label name"
#}
variable "min_replicas" {
  default = 1
}
variable "max_replicas" {
  default = 2
}

#variable "vpc_network" {
#
#}
#variable "vpc_subnetwork" {
#
#}



