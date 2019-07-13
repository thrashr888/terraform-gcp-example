variable "zone" {
  default = "us-central1-a"
}

variable "project" {
  default = "tfce-test"
}

provider "google" {
  project     = var.project
  region      = var.zone
}

resource "google_compute_disk" "default" {
  name  = "test-disk"
  type  = "pd-ssd"
  zone  = var.zone
  image = "debian-8-jessie-v20170523"
  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "micro" {
  name         = "test"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {}

  network_interface {}
}

resource "google_compute_instance" "standard1" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {}

  network_interface {}
}

resource "google_compute_instance" "default" {
  name         = "test"
  machine_type = "n1-standard-1"
  zone         = var.zone

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
