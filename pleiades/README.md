# Pleiades Talos Kubernetes cluster

```bash
talosctl gen secrets -o secrets.yaml
```

```bash
CLUSTER_NAME='pleiades.stargrid.systems'
API_ENDPOINT='https://kube.pleiades.stargrid.systems:6443'
talosctl gen config  \
    --dns-domain pleiades.stargrid.systems \
    --with-secrets secrets.yaml \
    --output-types talosconfig  \
    --output talosconfig        \
    $CLUSTER_NAME               \
    $API_ENDPOINT

```

```bash
CLUSTER_NAME='pleiades.stargrid.systems'
API_ENDPOINT='https://kube.pleiades.stargrid.systems:6443'
talosctl gen config "${CLUSTER_NAME}" "${API_ENDPOINT}" --with-examples=false --with-docs=false --config-patch @patch.yaml
```

```bash
: "${PLEIADES_C1_IP:?}"
talosctl apply-config --nodes "${PLEIADES_C1_IP}" --insecure --file ./controlplane.yaml
```
