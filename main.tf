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
  member  = "user:cv.brainiac@gmail.com"
}


variable "gcp_project" {
  description = "Your GCP Project ID"
  type        = string
}


terraform {
  backend "gcs" {
    bucket = "tf-state-utility-emblem-450718-d0"
    prefix = "terraform/state"
  }
}
