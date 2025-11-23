# Cluster


## Failed attempt using CAPH

```bash
kind create cluster
clusterctl init --core cluster-api --bootstrap kubeadm --control-plane kubeadm --infrastructure hetzner

export SSH_KEY_NAME='caph-trappist-1'
export HCLOUD_REGION='nbg1'
export HCLOUD_CONTROL_PLANE_MACHINE_TYPE='cx23'
export HCLOUD_WORKER_MACHINE_TYPE='cx23'

source .env.caph || exit 1

kubectl create secret generic hetzner --from-literal=hcloud="${HCLOUD_TOKEN:?}" --from-literal=robot-user="${HETZNER_ROBOT_USER:?}" --from-literal=robot-password="${HETZNER_ROBOT_PASSWORD:?}"
kubectl create secret generic robot-ssh --from-literal=sshkey-name=cluster --from-file=ssh-privatekey="${HETZNER_SSH_PRIV_PATH:?}" --from-file=ssh-publickey="${HETZNER_SSH_PUB_PATH:?}"

kubectl patch secret hetzner -p '{"metadata":{"labels":{"clusterctl.cluster.x-k8s.io/move":""}}}'
kubectl patch secret robot-ssh -p '{"metadata":{"labels":{"clusterctl.cluster.x-k8s.io/move":""}}}'

clusterctl generate cluster trappist-1 --kubernetes-version '1.34.2' --control-plane-machine-count=1 --worker-machine-count=0 | kubectl apply -f -
```
