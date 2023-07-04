module "mig" {
  source             = "./airbyte_module/mig"
  nro                = var.nro
  region             = var.region
  zone               = var.zone
  project            = var.project
  machine_size       = var.machine_size
  image_name         = var.image_name
  region_instances   = var.region_instances
  distribution_zones = var.distribution_zones
  max_replicas = var.max_replicas
  min_replicas = var.min_replicas
  vpc_network = module.vpc.vpc_network
  vpc_subnetwork = module.vpc.vpc_subnetwork
}

module "lb" {
  source           = "./airbyte_module/lb"
  nro              = var.nro
  project          = var.project
  airbyte_backend  = module.mig.airbyte_backend
  dns_primary_zone = var.dns_primary_zone
}

module "vpc" {
  source                = "./airbyte_module/vpc"
  nro                   = var.nro
  region                = var.region
  project               = var.project
  #dns_primary_zone      = "airbyte.systems"
  http_forwarding_rule  = module.lb.http_forwarding_rule
  #https_forwarding_rule = module.lb.https_forwarding_rule
  lb_ip                 = module.lb.lb_ip
}

#module "serviceacc" {
#  source = "./airbyte_module/serviceacc"
#  nro = var.nro
#  project = var.project
#}

# module "iam" {
#   source = "./airbyte_module/iam"
#   nro = var.nro
#   project = var.project
#   # project_name = "My First Project"
# }

#module "db" {
#  source                 = "./airbyte_module/db"
#  nro                    = var.nro
#  project                = var.project
#  postgresql_version     = "POSTGRES_14"
#  region                 = var.region
#  selflink               = module.vpc.selflink
#  allow_ip               = module.lb.allow_ip
#  vpc_private_connection = module.vpc.vpc_private_connection
#}

