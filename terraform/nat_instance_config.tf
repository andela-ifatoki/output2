// Configure NAT gateways.
resource "google_compute_instance" "nat_instance" {
  name         = "nat-instance"
  description  = "A NAT instance to help provide internet access to the instances in the private subnet."
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  metadata_startup_script = "${var.startup_scripts["nat"]}"
  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.public_subnet.self_link}"
    access_config {
      nat_ip = "${google_compute_address.nat_ip.address}"
    }
  }
  can_ip_forward = "true"
  tags = ["public", "http-server"]
  service_account {
    scopes = ["cloud-platform"]
  }
}
