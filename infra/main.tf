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
