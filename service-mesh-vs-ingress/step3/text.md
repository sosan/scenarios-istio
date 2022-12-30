# Run Envoy Proxy

## Prerequsites

Confirm that you are in the correct directory for this lab: `/root`

## Setup services

In this lab, we use a simple httpbin service and a sleep app to test the basic functionality of Envoy.

```plain
kubectl apply -f ./labs/01/httpbin.yaml
kubectl apply -f ./labs/01/sleep.yaml
```{{exec}}

Wait about 50 seconds until the pods are up.

```plain
kubectl get pods
```{{exec}}

To confirm that everything has been installed correctly, let's try run:

```plain
kubectl exec deploy/sleep -- curl httpbin:8080/user-agent
```{{exec}}


We should see httpbin output that looks similar to the following:

```plain
"user-agent": "curl/7.87.0-DEV"
```

## Envoy config

Envoy can be configured fully by loading a YAML/JSON file or partially by using a dynamic API. The dynamic API is a key reason why service mesh like Istio use Envoy. However, we will first learn about configuration at a basic level.

In this case, we will use the file configuration format. Here is an example of a configuration file:

```plain
clear
cat ./labs/01/config/envoy_config.yaml
```{{exec}}


```plain
kubectl create proxy-envoy envoy --from-file=envoy.yaml=./labs/01/config/envoy-config.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl apply -f ./labs/01/envoy-deploy.yaml
```{{exec}}

Let's now try calling the Envoy Proxy to verify that it routes correctly to the httpbin service.

```plain
kubectl exec deploy/sleep -- curl http://envoy/headers
```{{exec}}



