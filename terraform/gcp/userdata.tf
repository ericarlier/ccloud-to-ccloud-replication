##########################################
### Kafka Connect Replicator Bootstrap ###
##########################################

data "template_file" "kafka_replicator_properties" {
  template = file("../util/kafka-replicator.properties")

  vars = {
    global_prefix                   = var.global_prefix
    src_bootstrap_server            = var.src_bootstrap_server
    src_cluster_api_key             = var.src_cluster_api_key
    src_cluster_api_secret          = var.src_cluster_api_secret
    dest_bootstrap_server           = var.dest_bootstrap_server
    dest_cluster_api_key            = var.dest_cluster_api_key
    dest_cluster_api_secret         = var.dest_cluster_api_secret
    confluent_home_value            = var.confluent_home_value
  }
}
data "template_file" "kafka_replicator_config" {
  template = file("../util/kafka-replicator-config-template.json")

  vars = {
    src_bootstrap_server            = var.src_bootstrap_server
    src_cluster_api_key             = var.src_cluster_api_key
    src_cluster_api_secret          = var.src_cluster_api_secret
    dest_bootstrap_server           = var.dest_bootstrap_server
    dest_cluster_api_key            = var.dest_cluster_api_key
    dest_cluster_api_secret         = var.dest_cluster_api_secret
  }
}

data "template_file" "kafka_replicator_bootstrap" {
  template = file("../util/kafka-replicator.sh")

  vars = {
    confluent_platform_location    = var.confluent_platform_location
    kafka_replicator_properties    = data.template_file.kafka_replicator_properties.rendered
    kafka_replicator_config        = data.template_file.kafka_replicator_config.rendered
    kafka_replicator_jaas_config   = data.template_file.kafka_replicator_jaas.rendered
    kafka_connect_passwords        = data.local_file.password_file.content
    confluent_home_value           = var.confluent_home_value
  }
}

data "template_file" "kafka_replicator_load_script" {
  template = file("../util/loadReplicator-template.sh")

  vars = {
    external_ip    = "${google_compute_global_address.kafka_replicator[0].address}"
  }
}

data "template_file" "kafka_replicator_jaas" {
  template = file("../util/jaas.config-template")

  vars = {
    confluent_home_value           = var.confluent_home_value
  }
}

data "local_file" "password_file" {
    filename = "${path.module}/../util/connect.password"
}
