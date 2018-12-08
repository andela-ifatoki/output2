// Configure DB instance2.
resource "google_compute_instance" "replicationdb1_instance" {
  name         = "replicationdb1"
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
