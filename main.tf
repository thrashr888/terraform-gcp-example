variable "zone" {
  default = "us-central1-a"
}

variable "project" {
  default = "tfce-test"
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
  }
}

provider "google" {
  project     = var.project
  region      = var.zone
}

resource "google_service_account" "default" {
  account_id   = "tfce-test"
  display_name = "Custom SA for VM Instance"
}

data "google_compute_image" "my_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

resource "google_compute_disk" "defaultA" {
  name  = "test-diskA"
  type  = "pd-ssd"
  zone  = var.zone
  image = data.google_compute_image.my_image.self_link
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "defaultB" {
  name  = "test-diskB"
  type  = "pd-ssd"
  zone  = var.zone
  image = data.google_compute_image.my_image.self_link
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "defaultC" {
  name  = "test-diskC"
  type  = "pd-ssd"
  zone  = var.zone
  image = data.google_compute_image.my_image.self_link
  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "micro" {
  name         = "test-micro"
  machine_type = "f1-micro"
  zone         = var.zone

  boot_disk {
    source = google_compute_disk.defaultA.self_link
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

resource "google_compute_instance" "small" {
  name         = "test-sm"
  machine_type = "g1-small"
  zone         = var.zone

  boot_disk {
    source = google_compute_disk.defaultB.self_link
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

resource "google_compute_instance" "standard" {
  name         = "test-standard"
  machine_type = "n1-standard-1"
  zone         = var.zone

  tags = ["foo", "bar"]

  boot_disk {
    source = google_compute_disk.defaultC.self_link
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
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
