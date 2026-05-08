terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }
  backend "gcs" {
    bucket = "renntg-tfstate"
  }
}

provider "google" {
  project = "renntg"
  region = "us-central1"
  zone = "us-central1-c"
}

resource "google_storage_bucket" "static_site" {
  name = "renntg.com"
  location = "US"

  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.static_site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "indexpage" {
  name         = "index.html"
  content      = "<html><body>Hello World!</body></html>"
  content_type = "text/html"
  bucket       = google_storage_bucket.static_site.id
}
