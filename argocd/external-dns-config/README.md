# External DNS Configuration

```bash
kubectl create secret generic cloudflare-api-key --dry-run=client --from-file=apiKey=/dev/stdin -o yaml | kubeseal -w cloudflare-api-key.yaml -n external-dns
```
