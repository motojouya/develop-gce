# data "google_iam_policy" "develop-instance" {
#   binding {
#     role = "roles/iam.serviceAccountUser"
# 
#     members = [
#       "user:test@google.com",
#     ]
#   }
# }

## gceにつけるservice account
resource "google_service_account" "developer" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
}

# resource "google_service_account_iam_policy" "admin-account-iam" {
#   service_account_id = google_service_account.developer.name
#   policy_data        = data.google_iam_policy.develop-instance.policy_data
# }

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

  # TODO 鍵の値はvarに外出しにしたい
  metadata = {
    "ssh-keys" = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT ubuntu"
  }

  scheduling {
    preemptible         = true
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }
}
