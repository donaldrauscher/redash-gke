# redash-gke
Setting up Redash on GKE

## Dependencies

* [Terraform](https://www.terraform.io/) for defining infrastructure as code
* [Helm](https://helm.sh/) for packaging Kubernetes resources

## Infrastructure Setup

Create our infrastructure with Terraform and install Helm Tiller on our Kubernetes cluster.  You will also need to create a service account that the CloudSQL proxy on Kubernetes will use.  Create that (Role = "Cloud SQL Client"), download the JSON key, and attach key as secret.

``` bash
export PROJECT_ID=$(gcloud config get-value project -q)
terraform apply -var project=${PROJECT_ID}

gcloud container clusters get-credentials redash-cluster
gcloud config set container/cluster redash-cluster

helm init

kubectl create secret generic cloudsql-instance-credentials \
    --from-file=credentials.json=.keys/redash-cloudsql.json
```

## Redash Deployment

Next, we need to deploy Redash on our Kubernetes cluster.  I used a [Helm hook](https://docs.helm.sh/developing_charts/#hooks) to set up the configuration and the database resources (CloudSQL proxy + Redis) and also run a job to initialize the Redash schema before deploying the app.

``` bash
helm install . --set projectId=${PROJECT_ID}
```
