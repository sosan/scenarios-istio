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
cat ./labs/01/config/envoy_config_base.yaml
```{{exec}}

```plain
kubectl create cm envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_base.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl apply -f ./labs/01/envoy-deploy.yaml
```{{exec}}

Let's now try calling the Envoy Proxy to verify that it routes correctly to the httpbin service.

```plain
kubectl exec deploy/sleep -- curl http://envoy/headers
```{{exec}}


> We can observe a response with additional response headers, such as *X-Envoy-Expected-Rq-Timeout-Ms*, *X-Envoy-Downstream-Service-Cluster*, *X-Envoy-Internal* in the output.
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


```bash
kubectl create cm envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_timeout.yaml -o yaml --dry-run=client | kubectl apply -f -
kubectl rollout restart deploy/envoy
```{{exec}}


```bash
kubectl exec deploy/sleep -- curl http://envoy/headers
```

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
kubectl exec deploy/sleep -- curl -v http://envoy/delay/100
```{{exec}}


```plain
> * Connected to envoy (10.103.173.213) port 80 (#0)
> > GET /delay/5 HTTP/1.1
> > Host: envoy
> > User-Agent: curl/7.87.0-DEV
> > Accept: */*
> > 
> * Mark bundle as not supporting multiuse
> < HTTP/1.1 504 Gateway Timeout
> < upstream request timeoutcontent-length: 24
> < content-type: text/plain
> < date: Fri, 30 Dec 2022 23:22:01 GMT
> < server: envoy
> < 
> * Connection #0 to host envoy left intact
> upstream request timeout
```

Although this has been straightforward so far, we can see the potential for Envoy to be extremely useful for managing service-to-service request paths. 

By enhancing the networking with features such as:

- timeouts
- retries
- circuit breaking

the services are able to concentrate on business logic and differentiating features rather than wasting time on tedious cross-cutting networking tasks.

## Failing requests




