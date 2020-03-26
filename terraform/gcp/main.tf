###########################################
################## GCP ####################
###########################################

provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project
  region      = local.region
  version     = "~> 2.20.2"
}

data "google_compute_zones" "available" {
  status = "UP"
}

variable "gcp_credentials" {
}

variable "gcp_project" {
}

###########################################
############# Confluent Cloud #############
###########################################

variable "src_bootstrap_server" {
}

variable "src_cluster_api_key" {
}

variable "src_cluster_api_secret" {
}

variable "dest_bootstrap_server" {
}

variable "dest_cluster_api_key" {
}

variable "dest_cluster_api_secret" {
}

###########################################
################## Others #################
###########################################

variable "global_prefix" {
  default = "cc-replicator-erc"
}
