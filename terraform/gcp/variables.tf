locals {
  region = split(".", var.dest_bootstrap_server)[1]
}

variable "instance_count" {
  type = map(string)
  default = {
    "bastion_server" = 0
    "kafka_replicator"  = 2
  }
}

variable "confluent_platform_location" {
  default = "http://packages.confluent.io/archive/5.4/confluent-5.4.1-2.12.zip"
}

variable "confluent_home_value" {
  default = "/etc/confluent/confluent-5.4.1"
}
