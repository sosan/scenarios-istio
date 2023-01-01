# Run Envoy Proxy

## Prerequsites

Confirm that you are in the correct directory for this lab: `/root`

```plain
pwd
```{{exec}}

## Setup services

In this lab, we use a simple httpbin service and a sleep app to test the basic functionality of Envoy.

We will start by creating a namespace for the Envoy lab:

```plain
kubectl create namespace envoy-lab-01
```{{exec}}

So we will continue by deploying two services: HTTPBin and sleeping service curl:

```plain
kubectl apply -f ./labs/01/httpbin.yaml -n envoy-lab-01
kubectl apply -f ./labs/01/sleep.yaml -n envoy-lab-01
```{{exec}}

Wait about 50 seconds until the pods are up.

```plain
kubectl get pods -n envoy-lab-01
```{{exec}}

To confirm that everything has been installed correctly, let's try run:

```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s httpbin:8080/anything 
```{{exec}}


> We should see httpbin output that looks similar to the following:

```plain
{
  "args": {}, 
  "data": "", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Host": "httpbin:8080", 
    "User-Agent": "curl/7.87.0-DEV"
  }, 
  "json": null, 
  "method": "GET", 
  "origin": "192.168.1.7", 
  "url": "http://httpbin:8080/anything"
}
```

## Envoy config

Envoy can be configured fully by loading a YAML/JSON file or partially by using a dynamic API. The dynamic API is a key reason why service mesh like Istio use Envoy. However, we will first learn about configuration at a basic level.

In this case, we will use the file configuration format. Here is an example of a configuration file:

```plain
clear
cat ./labs/01/config/envoy_config_base.yaml ; echo
```{{exec}}

```plain
kubectl -n envoy-lab-01 create configmap envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_base.yaml -o yaml --dry-run=client | kubectl -n envoy-lab-01 apply -f -
kubectl apply -f ./labs/01/envoy-deploy.yaml -n envoy-lab-01
chmod +x ./labs/01/wait-headers.sh
```{{exec}}

./labs/01/wait-headers.sh

Once we have regained cursor focus (after approximately 50 seconds), let's try calling the Envoy proxy to ensure that it correctly routes to the HTTPBin service.

```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s http://envoy/headers
```{{exec}}


> We can observe a response with additional response headers in the output, such as:
> - *X-Envoy-Downstream-Service-Cluster*
> - *X-Envoy-Expected-Rq-Timeout-Ms*
> - *X-Envoy-Internal*
> 
> ```plain
> ...
> "headers": {
>     "Accept": "*/*", 
>     "Host": "envoy", 
>     "User-Agent": "curl/7.87.0-DEV", 
>     "X-Envoy-Downstream-Service-Cluster": "", 
>     "X-Envoy-Expected-Rq-Timeout-Ms": "15000", 
>     "X-Envoy-Internal": "true"
>   }
> ```


## Change config


```plain
route_config:
  name: httpbin_route
  virtual_hosts:
  - name: httpbin_host
    domains:
    - '*'
    routes:
    - match:
        prefix: /
      route:
        cluster: httpbin_service
        timeout: 0.6s # <<<<<<<<<<
```


```plain
kubectl create configmap envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_timeout.yaml -o yaml --dry-run=client | kubectl apply -f - -n envoy-lab-01
kubectl rollout restart deploy/envoy -n envoy-lab-01
./labs/01/wait-headers.sh
```{{exec}}


```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s http://envoy/headers
```{{exec}}

```
...
"headers": {
    "Accept": "*/*", 
    "Host": "envoy", 
    "User-Agent": "curl/7.87.0-DEV", 
    "X-Envoy-Downstream-Service-Cluster": "", 
    "X-Envoy-Expected-Rq-Timeout-Ms": "600", 
    "X-Envoy-Internal": "true"
  }
```

> We observe *X-Envoy-Expected-Rq-Timeout-Ms* changed to *600*

```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s http://envoy/delay/100
```{{exec}}

> Response similar to:
> upstream request timeout

Although this has been straightforward so far, we can see the potential for Envoy to be extremely useful for managing service-to-service request paths. 

By enhancing the networking with features such as:

- timeouts
- retries
- circuit breaking

the services are able to concentrate on business logic and differentiating features rather than wasting time on tedious cross-cutting networking tasks.

## Config retries

Utilizing network services can be intimidating due to the potential for response failure or technical issues. To mitigate this risk, we can configure Envoy to automatically attempt to reestablish a connection in the event of a request failure. It's important to note that this is not always a suitable solution, but Envoy can be adjusted to make more informed decisions about when to retry

Config example 5XX retries:

```plain
route_config:
  name: httpbin_route
  virtual_hosts:
  - name: httpbin_host
    domains:
    - '*'
    routes:
    - match:
        prefix: /
      route:
        cluster: httpbin_service
        timeout: 0.6s
        retry_policy:     # <<<<
          retry_on: 5XX   # <<<<
          num_retries: 10 # <<<<
```

```plain
kubectl create configmap envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_retries.yaml -o yaml --dry-run=client | kubectl apply -f - -n envoy-lab-01
kubectl rollout restart deploy/envoy -n envoy-lab-01
```{{exec}}

```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s http://envoy/status/500
```{{exec}}

## Traffic routing
(Soon)

## Traffic splitting
(Soon)

## Load balancing
(Soon)

## Envoy discovery (XDS)
(Soon)


## Next Lab play with Istio

In this session, we will delve deeper into the inner workings of Istio's control plane. We will also examine how we can utilize the various capabilities of Envoy, including resilience, routing, observability, and security, to build a secure and observable microservices architecture."

