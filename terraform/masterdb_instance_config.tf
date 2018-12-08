// Configure DB instance1.
resource "google_compute_instance" "masterdb_instance" {
  name         = "masterdb"
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
