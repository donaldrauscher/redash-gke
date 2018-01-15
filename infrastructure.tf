provider "google" {
  version = "~> 1.4"
  project = "blog-180218"
  region = "us-central1"
}

resource "google_compute_disk" "redash-redis-disk" {
  name  = "redash-redis-disk"
  type  = "pd-ssd"
  size = "200"
  zone  = "us-central1-f"
}

resource "google_sql_database_instance" "redash-db" {
  name = "redash-db"
  database_version = "POSTGRES_9_6"
  region  = "us-central1"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "redash-schema" {
  name = "redash"
  instance = "${google_sql_database_instance.redash-db.name}"
}

resource "google_sql_user" "proxyuser" {
  name = "proxyuser"
  instance = "${google_sql_database_instance.redash-db.name}"
  host = "cloudsqlproxy~%"
  password = "hsader"
}
