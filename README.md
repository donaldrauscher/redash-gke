# redash-gke
Setting up Redash on GKE

## Infrastructure Setup

CloudSQL backend:
1. Create a Postgres instance on CloudSQL and a `redash` schema (UI)
2. Create a service account (Role = "Cloud SQL Client") that the CloudSQL proxy on Kubernetes will use, and download the JSON key (UI)
3. Create a Postgres user account for Redash

``` bash
gcloud sql users create [POSTGRES_USER] cloudsqlproxy~% \
  --instance=[POSTGRES_INSTANCE_ID] \
  --password=[POSTGRES_PW]
```

Persistent drive for Redis:
``` bash
gcloud compute disks create --size 200GB redash-redis-disk
```

Kubernetes cluster:
1. Create a small cluster for Redash
2. Add secret containing the previously-created service account for CloudSQL

``` bash
gcloud container clusters create redash-cluster \
  --num-nodes=1 \
  --machine-type n1-standard-4

gcloud config set container/cluster redash-cluster

kubectl create secret generic cloudsql-instance-credentials \
    --from-file=credentials.json=[PROXY_KEY_FILE_PATH]
```

## Redash Deployment

Next, we need to deploy Redash on our Kubernetes cluster.  This is done in three steps:
1. Set up a Redis service and a CloudSQL proxy so our Redash instances can access their Postgres backend in CloudSQL
2. Kick off initialization [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) which will create the Redash app's tables in the `redash` schema
3. Deploy the Redash app (1 server + 2 workers)

``` bash
ktmpl k8s/redash-resources.yaml --parameter-file config.yaml | kubectl apply -f -
ktmpl k8s/redash-init.yaml --parameter-file config.yaml | kubectl apply -f -
ktmpl k8s/redash.yaml --parameter-file config.yaml | kubectl apply -f -
```

NOTE: I use a nifty tool called [`ktmpl`](https://github.com/jimmycuadra/ktmpl) to do parameter substitutions in my Kubernetes manifests.
