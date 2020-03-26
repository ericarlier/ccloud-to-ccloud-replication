###########################################
################# Outputs #################
###########################################

output "Kafka_Replicator" {
  value = var.instance_count["kafka_replicator"] >= 1 ? join(
    ",",
    formatlist(
      "http://%s",
      google_compute_global_address.kafka_replicator.*.address,
    ),
  ) : "Kafka Connect has been disabled"
}
