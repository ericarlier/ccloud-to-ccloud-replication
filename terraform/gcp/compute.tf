###########################################
########### Kafka Replicator LBR ##########
###########################################

# Global Address (static publlic IP) for HTTP(s) Load balancing
resource "google_compute_global_address" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name = "kafka-replicator-global-address-${var.global_prefix}"
}

# Forwarding rule from Global Address to HTTP Proxy
resource "google_compute_global_forwarding_rule" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name       = "kafka-replicator-global-forwarding-rule-${var.global_prefix}"
  target     = google_compute_target_http_proxy.kafka_replicator[0].self_link
  ip_address = google_compute_global_address.kafka_replicator[0].self_link
  port_range = "80"
}

resource "google_compute_target_http_proxy" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name    = "kafka-replicator-http-proxy-${var.global_prefix}"
  url_map = google_compute_url_map.kafka_replicator[0].self_link
}

resource "google_compute_url_map" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name            = "kafka-replicator-url-map-${var.global_prefix}"
  default_service = google_compute_backend_service.kafka_replicator[0].self_link
}

# Back-end service on instance group
resource "google_compute_backend_service" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name        = "kafka-replicator-backend-service-${var.global_prefix}"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 5

  backend {
    group = google_compute_region_instance_group_manager.kafka_replicator[0].instance_group
  }

  health_checks = [google_compute_health_check.kafka_replicator[0].self_link]
}

resource "google_compute_region_instance_group_manager" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name                      = "kafka-replicator-instance-group-${var.global_prefix}"
  base_instance_name        = "${var.global_prefix}-kafka-replicator"
  region                    = local.region
  distribution_policy_zones = data.google_compute_zones.available.names
  target_size               = var.instance_count["kafka_replicator"]

  version {
    instance_template         = google_compute_instance_template.kafka_replicator[0].self_link
  }

  named_port {
    name = "http"
    port = 8083
  }

}

resource "google_compute_health_check" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0

  name                = "kafka-replicator-tcp-health-check-${var.global_prefix}"
  
  healthy_threshold   = 3
  unhealthy_threshold = 3
  check_interval_sec  = 5
  timeout_sec         = 3

  tcp_health_check {
    port = "8083"
  }
}

resource "google_compute_instance_template" "kafka_replicator" {
  # count = var.instance_count["kafka_replicator"] > 0 ? var.instance_count["kafka_replicator"] : 0
  count = var.instance_count["kafka_replicator"] > 0 ? 1 : 0
  
  name         = "kafka-replicator-template-${var.global_prefix}"
  machine_type = "n1-standard-2"

  metadata_startup_script = data.template_file.kafka_replicator_bootstrap.rendered

  disk {
    source_image = "centos-7"
    disk_size_gb = 100
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.self_link

    access_config {
    }
  }

  tags = ["kafka-replicator-${var.global_prefix}"]
}

resource "local_file" "kafka_replicator_load" {
  content = data.template_file.kafka_replicator_load_script.rendered
  filename = "load/loadReplicator.sh"
}

resource "local_file" "kafka_replicator_config" {
  content = data.template_file.kafka_replicator_config.rendered
  filename = "load/kafka-replicator-config.json"
}


