provider "google" {
  version = "~> 1.4"
  project = "blog-180218"
  region = "us-central1"
}

resource "google_compute_disk" "default" {
  name  = "redash-redis-disk"
  type  = "pd-ssd"
  size = "200"
  zone  = "us-central1-f"
}
