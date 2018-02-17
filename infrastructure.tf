variable "project" {}

variable "postgres_user" {
  default = "redash"
}
variable "postgres_pw" {
  default = "hsader"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-f"
}

provider "google" {
  version = "~> 1.4"
  project = "${var.project}"
  region = "${var.region}"
}

resource "google_compute_global_address" "redash-static-ip" {
  name = "redash-static-ip"
}

resource "google_compute_disk" "redash-redis-disk" {
  name  = "redash-redis-disk"
  type  = "pd-ssd"
  size = "200"
  zone  = "${var.zone}"
}

resource "google_sql_database_instance" "redash-db" {
  name = "redash-db"
  database_version = "POSTGRES_9_6"
  region = "${var.region}"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "redash-schema" {
  name = "redash"
  instance = "${google_sql_database_instance.redash-db.name}"
}

resource "google_sql_user" "proxyuser" {
  name = "${var.postgres_user}"
  password = "${var.postgres_pw}"
  instance = "${google_sql_database_instance.redash-db.name}"
  host = "cloudsqlproxy~%"
}

resource "google_container_cluster" "redash-cluster" {
  name = "redash-cluster"
  zone = "${var.zone}"
  initial_node_count = "1"
  node_config {
    machine_type = "n1-standard-4"
  }
}
