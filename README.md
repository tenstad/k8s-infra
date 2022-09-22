# k8s-infra

K8s infrastructure, with Prometheus, Thanos, Alertmanager and Grafana.

## Prereqs

Fork the repo and update the line `url: ssh://git@github.com/tenstad/k8s-infra`
in `clusters/dev/flux-system/gotk-sync.yaml` to your username/orgname.

Install `k3d`:

```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Install `flux`:

```
curl -s https://fluxcd.io/install.sh | sudo bash
```

Install `mc`:

```
curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin
```

## Setup

Create a new cluster using `k3d`:

```
k3d cluster create --k3s-arg "--disable=traefik@server:0"
```

Create a secret containing the slack webhook url:

```
kubectl create namespace flux-system
kubectl create secret -n flux-system generic kube-prometheus-stack-alertmanager --from-literal=slack-apiurl=<slack api url>
```

Configure Flux CI to sync from your GitHub repo:

```
export GITHUB_TOKEN=<github token>

flux bootstrap github \
  --owner=<github username / orgname> \
  --repository=k8s-infra \
  --branch=main \
  --path=./clusters/dev
```

Get Cluster IP and update /etc/hosts:

```
ip=$(docker network inspect k3d-k3s-default | jq -r '.[0].Containers[] | select(.Name=="k3d-k3s-default-server-0") | .IPv4Address' | cut -d "/" -f1)
for host in prometheus.cluster.local grafana.cluster.local karma.cluster.local thanos.cluster.local metrics-editor.cluster.local alertmanager.cluster.local minio.cluster.local minio-api.cluster.local; do
  sudo sed -i "/${host}/d" /etc/hosts
  echo "${ip} ${host}" | sudo tee -a /etc/hosts
done
```

Create in-cluster S3 bucket for Thanos metrics storage:

```
mc alias set minio-cluster-local http://minio-api.cluster.local minioadmin minioadmin
mc admin info minio-cluster-local
mc mb minio-cluster-local/thanos
mc admin user add minio-cluster-local thanos secret0123456789
mc admin policy set minio-cluster-local readwrite user=thanos
mc admin user info minio-cluster-local thanos
mc admin user svcacct add --access-key access0123456789 --secret-key secret0123456789 minio-cluster-local thanos
```

Wait for pods to start:

```
watch kubectl get pods -A
```

## Play

Explore the services and try to update config in GitHub and push/merge to `main`
to apply.

[`prometheus.cluster.local`](http://prometheus.cluster.local)  
[`grafana.cluster.local`](http://grafana.cluster.local) (admin/prom-operator)  
[`karma.cluster.local`](http://karma.cluster.local)  
[`thanos.cluster.local`](http://thanos.cluster.local)  
[`metrics-editor.cluster.local`](http://metrics-editor.cluster.local)  
[`alertmanager.cluster.local`](http://alertmanager.cluster.local)  
[`minio.cluster.local`](https://minio.cluster.local) (minioadmin/minioadmin)  

## Cleanup

```
k3d cluster delete
```

Delete GitHub fork.
