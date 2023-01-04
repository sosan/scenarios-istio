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
> ```plain
> {
>   "args": {}, 
>   "data": "", 
>   "files": {}, 
>   "form": {}, 
>   "headers": {
>     "Accept": "*/*", 
>     "Host": "httpbin:8080", 
>     "User-Agent": "curl/7.87.0-DEV"
>   }, 
>   "json": null, 
>   "method": "GET", 
>   "origin": "192.168.1.7", 
>   "url": "http://httpbin:8080/anything"
> }
> ```

## Envoy config

Envoy can be configured fully by loading a YAML/JSON file or partially by using a dynamic API. The dynamic API is a key reason why service mesh like Istio use Envoy. However, we will first learn about configuration at a basic level.

In this case, we will use the file configuration format. Here is an example of a configuration file:

```plain
clear
cat ./labs/01/config/envoy_config_base.yaml ; echo
```{{exec}}

We will create a ConfigMap named `envoy` using the data in the `envoy_config_base.yaml` file and also we will apply the configuration from the previous command

```plain
kubectl -n envoy-lab-01 create configmap envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_base.yaml -o yaml --dry-run=client | kubectl -n envoy-lab-01 apply -f -
kubectl -n envoy-lab-01 apply -f ./labs/01/envoy-deploy.yaml
chmod +x ./labs/01/wait-headers.sh
./labs/01/wait-headers.sh
```{{exec}}

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

Here is diagram interactions:

![Diagram kubectl-sleep-envoy](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/sleep_envoy_httpbin.svg)

## Envoy Change config

We will change envoy config to define a route that directs traffic to the httpbin_service cluster. The route applies to all domains and matches all incoming requests with a prefix of `/`.

The route `/` has a timeout of 0.6 seconds, which means that if a response is not received from the `httpbin_service` cluster within that time, the request will be considered failed and the route will not be used. 

This timeout can be used to ensure that requests are not stuck waiting for a response from the cluster for an excessive amount of time, which can help to improve the performance and reliability of the overall system.

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

Update the configuration of deployment `envoy` in the `envoy-lab-01` namespace and restart deployment:

```plain
kubectl create configmap envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_timeout.yaml -o yaml --dry-run=client | kubectl apply -f - -n envoy-lab-01
sleep 1
kubectl rollout restart deploy/envoy -n envoy-lab-01
sleep 5
./labs/01/wait-headers.sh
```{{exec}}

This curl command to `http://envoy/headers` URL is utilized to transmit an HTTP request to HTTPBin service throught Envoy:

```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s http://envoy/headers
```{{exec}}

> We observe *X-Envoy-Expected-Rq-Timeout-Ms* changed to *600*
> ```plain
> "headers": {
>     "Accept": "*/*", 
>     "Host": "envoy", 
>     "User-Agent": "curl/7.87.0-DEV", 
>     "X-Envoy-Downstream-Service-Cluster": "", 
>     "X-Envoy-Expected-Rq-Timeout-Ms": "600", 
>     "X-Envoy-Internal": "true"
>   }
> ```

We will send this curl command that sends an HTTP request to the URL http://envoy/delay/2000, which is expected to take 2000 seconds to complete.

```plain
kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s http://envoy/delay/2000 ; echo
```{{exec}}

> Response similar: *upstream request timeout*

Diagram illustrating what occurred:

![Diagram kubectl-sleep-envoy with timeout](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/sleep_envoy_httpbin_with_timeout.svg)

Although this has been straightforward so far, we can see the potential for Envoy to be extremely useful for managing service-to-service request paths. 

By enhancing the networking with features such as:

- timeouts
- retries
- circuit breaking

the services are able to concentrate on business logic and differentiating features rather than wasting time on tedious cross-cutting networking tasks.

## Config retries

Utilizing network services can be intimidating due to the potential for response failure or technical issues. 

To mitigate this risk, we can configure Envoy to automatically attempt to reestablish a connection in the event of a request failure. 

It's important to note that this is not always a suitable solution, but Envoy can be adjusted to make more informed decisions about when to retry.

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

We apply the new configuration and restart deployment:

```plain
kubectl -n envoy-lab-01 create configmap envoy --from-file=envoy.yaml=./labs/01/config/envoy_config_retries.yaml -o yaml --dry-run=client | kubectl apply -f - -n envoy-lab-01
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


## Final: Delete namespace

The envoy-lab-01 namespace is no longer needed, so in order to release the resources it was using, we will delete the namespace using the following command:

```plain
kubectl delete namespaces envoy-lab-01
```{{exec}}

## Next Lab play with Istio

In the next lab, we will delve deeper into the inner workings of Istio's control plane. 

We will also examine how we can utilize the various capabilities of Envoy, including resilience, routing, observability, and security, to build a secure and observable microservices architecture.

