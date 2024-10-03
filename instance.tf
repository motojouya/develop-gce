## gceにつけるservice account
resource "google_service_account" "developer" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
}

resource "google_project_iam_member" "developer_role_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.developer.email}"
}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.developer.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOF
#!/bin/bash
curl https://raw.githubusercontent.com/motojouya/develop-gce/main/resources/init.sh | bash -s -- ${var.ssh_port}
EOF

  metadata = {
    "ssh-keys" = var.ssh_key # ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT ubuntu
  }

  scheduling {
    preemptible         = true
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }
}
