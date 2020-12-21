terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  credentials = file("istio-account.json")
  project = var.project_id
  region = var.region
}