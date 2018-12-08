// Configure project subnets
resource "google_compute_subnetwork" "private_subnet" {
  name          = "database-private-subnet"
  description   = "Private subnet for databases"
  ip_cidr_range = "${var.subnet_cidrs["private"]}"
  network       = "${google_compute_network.database-vpc.self_link}"
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "database-public-subnet"
  description   = "Public subnet for databases"
  ip_cidr_range = "${var.subnet_cidrs["public"]}"
  network       = "${google_compute_network.database-vpc.self_link}"
}
