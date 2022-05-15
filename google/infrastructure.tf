resource "google_compute_network" "my_vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.my_vpc.id
}

resource "google_compute_global_address" "my_static_ip" {
  name = "my-static-ip"
}

resource "google_compute_global_forwarding_rule" "my_forwarding_rule" {
  name                  = "my-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.my_http_proxy.id
  ip_address            = google_compute_global_address.my_static_ip.id
}

resource "google_compute_target_http_proxy" "my_http_proxy" {
  name    = "my-target-http-proxy"
  url_map = google_compute_url_map.my_url_map.id
}

resource "google_compute_url_map" "my_url_map" {
  name            = "my-url-map"
  default_service = google_compute_backend_service.my_backend_service.id
}

resource "google_compute_backend_service" "my_backend_service" {
  name                  = "my-backend-service"
  protocol              = "HTTP"
  port_name             = "my-port"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = true
  health_checks         = [google_compute_health_check.my_health_check.id]
  backend {
    group           = google_compute_instance_group_manager.my_group_manager.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_instance_template" "my_template" {
  name         = "my-template"
  machine_type = "e2-small"

  network_interface {
    network    = google_compute_network.my_vpc.id
    subnetwork = google_compute_subnetwork.my_subnet.id
  }

  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_health_check" "my_health_check" {
  name = "my-health-check"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_instance_group_manager" "my_group_manager" {
  name = "my-mig"

  named_port {
    name = "http"
    port = 8080
  }

  version {
    instance_template = google_compute_instance_template.my_template.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

resource "google_compute_firewall" "my_firewall" {
  name          = "my-fw-allow-health-checks"
  direction     = "INGRESS"
  network       = google_compute_network.my_vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}
