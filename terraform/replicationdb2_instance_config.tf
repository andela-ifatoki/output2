// Configure DB instance3.
resource "google_compute_instance" "replicationdb2_instance" {
  name         = "replicationdb2"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["private"]
  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }
  network_interface {
    subnetwork  = "${google_compute_subnetwork.private_subnet.self_link}"
  }
  service_account {
    scopes = ["cloud-platform"]
  }
}
