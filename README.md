# redash-gke
Setting up Redash on GKE

## Dependencies

* [Terraform](https://www.terraform.io/) for defining infrastructure as code
* A nifty tool called [`ktmpl`](https://github.com/jimmycuadra/ktmpl) for doing parameter substitutions in my Kubernetes manifests

## Infrastructure Setup

```
terraform apply
```

You will also need to create a service account that the CloudSQL proxy on Kubernetes will use.  Create that (Role = "Cloud SQL Client") and download the JSON key.  Once Kubernetes cluster is up, you need to attach a secret containing the previously-created service account.  And, if you haven't already, fetch credentials so that you can run `kubectl` commands on your cluster.
```
gcloud container clusters get-credentials redash-cluster
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
