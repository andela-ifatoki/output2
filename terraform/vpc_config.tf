resource "google_compute_network" "database-vpc" {
  name                    = "database-network"
  description             = "Virtual Private Cloud for demo purpose"
  auto_create_subnetworks = "false"  
}
