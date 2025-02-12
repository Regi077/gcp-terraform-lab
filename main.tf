provider "google" {
  project = var.gcp_project
  region  = "us-central1"
}

resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

resource "google_cloud_run_service" "default" {
  name     = "hello-world"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.cloudrun]
}

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_project_iam_member" "cloud_run_viewer" {
  project = var.gcp_project
  role    = "roles/viewer"
  member  = "cv.brainiac@gmail.com"
}

resource "google_compute_firewall" "deny_ingress" {
  name    = "block-all-ingress"
  network = "default"

  deny {
    protocol = "all"
  }

  priority = 1000
}

variable "gcp_project" {
  description = "Your GCP Project ID"
  type        = string
}
