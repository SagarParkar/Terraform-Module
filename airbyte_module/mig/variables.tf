variable "nro" {}
variable "region" {}
variable "zone" {}
variable "project" {}
variable "image_name" {}
variable "machine_size" {}
variable "region_instances" {}
variable "vpc_network" {}
variable "vpc_subnetwork" {}
variable "distribution_zones" {
  type = list(string)
}
variable "min_replicas" {}
variable "max_replicas" {}
#variable "labels" {}