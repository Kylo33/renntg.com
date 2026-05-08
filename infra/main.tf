# Terraform Setup

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
  backend "gcs" {
    bucket = "renntg-tfstate"
  }
}

provider "google" {
  project = "renntg"
  region  = "us-central1"
  zone    = "us-central1-c"
}

# Static Site Bucket

resource "google_storage_bucket" "static_site" {
  name     = "renntg.com"
  location = "US"

  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.static_site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "indexpage" {
  name         = "index.html"
  content      = "<html><body>Hi, this is Renn. My website is currently under construction, but it will be back shortly!</body></html>"
  content_type = "text/html"
  bucket       = google_storage_bucket.static_site.id
}

resource "google_compute_backend_bucket" "static_site" {
  name        = "static-site-backend"
  bucket_name = google_storage_bucket.static_site.name
  enable_cdn  = true
}

# Load Balancer Setup

resource "google_compute_global_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_url_map" "default" {
  name        = "renntg-urlmap"
  default_service = google_compute_backend_bucket.static_site.id
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "renntg-cert"
  managed {
    domains = ["renntg.com"]
  }
}

resource "google_compute_target_https_proxy" "default" {
  name = "renntg-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "renntg-forwarding-rule"
  target     = google_compute_target_https_proxy.default.id
  ip_address = google_compute_global_address.static.id
  port_range = 443
}

output "load_balancer_ip" {
  value = google_compute_global_address.static.address
  description = "Load balancer IP address"
}
