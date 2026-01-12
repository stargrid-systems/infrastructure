# Pleiades Talos Kubernetes cluster

## Bootstrapping

```bash
talosctl gen secrets -o secrets.yaml
```

```bash
CLUSTER_NAME='pleiades.stargrid.systems'
API_ENDPOINT='https://kube.pleiades.stargrid.systems:6443'
talosctl gen config "${CLUSTER_NAME}" "${API_ENDPOINT}" --with-secrets secrets.yaml --with-examples=false --with-docs=false --config-patch @patch.yaml
```

Once Terraform has applied the C1 node:

```bash
: "${PLEIADES_C1_IP:?}"
talosctl apply-config --nodes "${PLEIADES_C1_IP}" --insecure --file ./controlplane.yaml
export TALOSCONFIG=./talosconfig
talosctl bootstrap --nodes "${PLEIADES_C1_IP:?}"
talosctl kubeconfig --nodes "${PLEIADES_C1_IP:?}"
```

Kubernetes is now up and running.

```bash
```
