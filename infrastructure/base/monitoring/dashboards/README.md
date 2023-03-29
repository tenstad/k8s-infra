# Grafana Dashboards

Collection of Grafana dashboards
written in [jsonnet](https://jsonnet.org)
using [grafonnet](https://grafana.github.io/grafonnet-lib)
and deployed with [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler)
and [grizzly](https://grafana.github.io/grizzly).

## Dashboard Development Tips

When developing dashboards, it is often helpfull to explore changes in the Grafana
GUI itself, and then find and update the corresponding fields in grafonnet code.

The supported field and methods are documented through docstrings in the GitHub
repo
[grafana/grafonnet-lib/grafonnet](https://github.com/grafana/grafonnet-lib/tree/master/grafonnet)
repo, e.g
[graph_panel.libsonnet](https://github.com/grafana/grafonnet-lib/blob/30280196507e0fe6fa978a3e0eaca3a62844f817/grafonnet/graph_panel.libsonnet#L6-L70).

## Local Development

### Requirements

- [docker](https://docs.docker.com/engine/install/ubuntu)/[podman](https://podman.io/getting-started/installation)
- [jq](https://stedolan.github.io/jq)
- [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler)
- [grizzly](https://grafana.github.io/grizzly)

### Apply Dashboards

```bash
export GRAFANA_HOST=grafana.cluster.local
export GRAFANA_URL=http://${GRAFANA_HOST}
while ! curl "http://admin:prom-operator@${GRAFANA_HOST}/api/auth/keys" -s && echo ...; do sleep 1; done
export GRAFANA_TOKEN=$(curl -X POST -H "Content-Type: application/json" -d '{"name":"apikeycurl", "role": "Admin"}' "http://admin:prom-operator@${GRAFANA_HOST}/api/auth/keys" | jq -r .key)
```

Apply the dashboards and update on any saved changes:

```bash
jb install
grr apply main.jsonnet
grr watch . main.jsonnet
```

Any local code changes will now instantly be pushed to Grafana.

Open [http://grafana.cluster.local](http://grafana.cluster.local) and login with
`admin` `prom-operator`.
