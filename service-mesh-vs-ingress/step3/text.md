# Run Envoy Proxy

## Setup services

In this lab, we use a simple httpbin service and a sleep app to test the basic functionality of Envoy.

```plain
kubectl apply -f labs/01/httpbin.yaml && \
kubectl apply -f labs/01/sleep.yaml
```{{exec}}

Verify with

```bash
kubectl exec deploy/sleep -- curl httpbin:8000/headers
```{{exec}}