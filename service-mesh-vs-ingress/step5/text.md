## Istio Gateways

The Istio Gateway is a load balancer for HTTP/TCP traffic that can be configured to work in any environment. It allows multiple gateways to exist within a service mesh and for different gateway implementations to coexist. It can also be bound to specific workloads by specifying a set of labels, allowing for the use of pre-existing network appliances.

The Istio Gateway is used for ingress traffic management and addresses limitations in the Kubernetes Ingress API by separating L4-L6 configurations from L7

Istio Gateway overcomes the Ingress shortcomings by separating the L4-L6 spec from L7. It only configures the L4-L6 functions (e.g., ports to expose, TLS configuration) that are uniformly implemented by all good L7 proxies. Users can then use standard Istio rules to control HTTP requests as well as TCP traffic entering a Gateway by binding a VirtualService to it.

![Istio gateway](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/istio_gateway.svg)

This diagram shows that external traffic sends a request to the default gateway, which then routes the request to the appropriate service (in this case, Service A). Service A processes the request and sends a response back to the default gateway, which then sends the response back to the external traffic.

Please note that this is a simple example, and in reality the routing decision might be more complex, depending on the service, the path and the headers of the request.


## Istio Ingress Gateways

The Istio ingress gateway is a specialized proxy that sits at the edge of the mesh and controls access to the services within the cluster from the public network.

It is exposed by a Kubernetes Service of type **LoadBalancer**, which can be query default using:

```plain
kubectl get svc -n istio-system --selector istio=ingressgateway
```{{exec}}

> ```plain
> NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
> istio-ingressgateway   LoadBalancer   10.98.230.210   <pending>     15021:32255/TCP,80:31165/TCP,443:32507/TCP,31400:30603/TCP,15443:31674/TCP   10m
> ```

This `Loadbalancer` service: 
- if we are in a **Kubernetes managed** or a **MetalLB** environment, both will assign an IP to `EXTERNAL-IP`. 
- Otherwise, it will not be possible to assign an external IP and its status will remain `pending`.

To work around this issue, you can use the "port-forward" command:

```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

Let's check if port 8081 has been opened:

```plain
lsof -i :8081
```{{exec}}

> Result: 
> ```plain
> COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
> kubectl 73923 root    8u  IPv4 425756      0t0  TCP localhost:tproxy (LISTEN)
> kubectl 73923 root    9u  IPv6 425760      0t0  TCP ip6-localhost:tproxy (LISTEN)
> ```

By using the "port-forward" command, traffic to localhost:8081 will now be directed to the service `istio-ingressgateway`. If you open curl and type request in that address, you will find that the gateway will reject your request. **This is the default behavior of the gateway.**

```plain
curl -v localhost:8081
```{{exec}}

> Result:
> ```plain
> an error occurred forwarding 8081 -> 8080: error forwarding port 8080
> ```

**As we expected, the gateway has responded with an error.**

## Allow incoming traffic to the gateway

To enable traffic to a gateway, we will need to create:
- `Gateway` resource
- `VirtualService` resource

Once these resources are created and configured, traffic should be able to reach the gateway.


<!-- 
```plain
kubectl apply -f labs/03/virtualservices-for-default.yaml -n istio-lab-01
```{{exec}}


```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

```plain
curl -v localhost:8081/api/v1/follow
```{{exec}}
 ✅
> Result
> ```plain
> ddd
> ``` 
-->


### Creating new gateway

A service mesh can have multiple ingress gateways. This is typically used in multi-tenant environments. 

In this case, we will installing new istio ingress gateway in namespace `istio-ingress` separate for increased security and isolation.

```plain
kubectl create namespace istio-ingress
istioctl install -y -n istio-ingress -f ./labs/03/istio-install-gateway.yaml
kubectl apply -f labs/03/ingress-gateway.yaml -n istio-lab-01
```{{exec}}

Result:
> ```plain
> ✔ Ingress gateways installed                                                                                       
> ✔ Installation complete                                                                                            
> [...]
> ```

We should verify that the ingress gateway was installed correctly:

```plain
kubectl get service -A -l istio=ingressgateway
```{{exec}}

> Result:
> ```plain
> NAMESPACE       NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
> istio-ingress   istio-ingressgateway   LoadBalancer   10.108.227.19   <pending>     15021:30854/TCP,80:30082/TCP,443:32662/TCP                                   10s
> istio-system    istio-ingressgateway   LoadBalancer   10.102.40.230   <pending>     15021:31499/TCP,80:31783/TCP,443:32579/TCP,31400:31224/TCP,15443:31626/TCP   21m
> ```

As we previously mentioned, if we don't have a **MetalLB** environment or a **Managed Kubernetes**, `EXTERNAL-IP` will remain in the <pending> state.

We verify that we have correctly installed and raised the gateway:

```plain
kubectl get gateway -n istio-lab-01
```{{exec}}

> Result
> ```plain
> NAMESPACE      NAME                AGE
> istio-lab-01   mock-apps-gateway   15s
> ```

### Creating VirtualServices

A VirtualService defines a set of traffic routing rules to apply when a host is addressed.

It allows you to route traffic to different versions of a service or to different services based on certain conditions.

```plain
kubectl apply -f labs/03/virtualservices-for-mock-apps-gateway.yaml -n istio-lab-01
```{{exec}}

We will check if created correctly:
```plain
kubectl get virtualservices -n istio-lab-01 
```{{exec}}

> Result:
> ```plain
> NAME        GATEWAYS                HOSTS   AGE
> follow      ["mock-apps-gateway"]   ["*"]   25s
> greetings   ["mock-apps-gateway"]   ["*"]   25s
> order       ["mock-apps-gateway"]   ["*"]   25s
> ```

---

To recap, we have active services of:
- `Gateway` ✅
- `Virtualservices` ✅

We can query the gateway configuration using the `istioctl proxy-config` command:

```plain
istioctl proxy-config routes deploy/istio-ingressgateway.istio-ingress -n istio-ingress
```

> Result
> ```plain
> NAME          DOMAINS     MATCH                  VIRTUAL SERVICE
> http.8080     *           /api/v1/follow*        follow.istio-lab-01
> http.8080     *           /api/v1/greetings*     greetings.istio-lab-01
> http.8080     *           /api/v1/orders*        order.istio-lab-01
>               *           /healthz/ready*        
>               *           /stats/prometheus*     
> ```

If we wanted to see an individual route, we can ask for its output as `json` like this:

```plain
istioctl proxy-config routes deploy/istio-ingressgateway.istio-ingress -n istio-ingress -o json | jq
```

---
---


```plain
kubectl port-forward -n istio-ingress svc/istio-ingressgateway 1234:80 >> /dev/null &
```{{exec}}

Let's check if port 1234 has been opened:

```plain
lsof -i :1234
```{{exec}}


```plain
curl -v localhost:1234/api/v1/follow
```{{exec}}

Status code 200 from
`Follow` -> `Greetings` -> `Order`

> Result: status code 200
> ```plain
> {
>   [...]
>   "body": "---- BEGIN API -----",
>   "upstream_calls": {
>     "http://greetings:9080": {
>       "body": "--- GREEETINGS HERE ---",
>       [...]
>       "upstream_calls": {
>         "http://order:9080": {
>           [...]
>           "body": "---- ORDER V1 HERE ----",
>           "code": 200
>         }
>       },
>       "code": 200
>     }
>   },
>   "code": 200
> }
> ```



Send curl direct to `Greetings` -> `Order`

```plain
curl -v localhost:1234/api/v1/greetings
```{{exec}}

Send curl direct to `Order`

```plain
curl -v localhost:1234/api/v1/orders
```{{exec}}


<!-- 
## Ingress traffic with certification HTTPS

We will create a certificate with an appropriate SAN

```plain
kubectl create -n istio-ingress \
    secret tls gw-istioingress-cert \
    --key ./labs/03/certs/key.key \
    --cert ./labs/03/certs/cert.crt
```

_the cert must be where the gateway is actually deployed_

```plain
kubectl -n istioinaction apply -f labs/03/https-gateway.yaml
```


Example calling it:

```
curl --cacert ./labs/04/certs/ca/root-ca.crt https://localhost --resolve localhost:443:$GATEWAY_IP
``` -->


## Istio Ingress Ingress Gateway traffic with Cert Manager

In this lab, the CA will be our own CA but cert-manager can be integrated with a lot of backend PKI --- which is a big reason why cert manager is so popular. 

Preparation for installation of cert manager:

```plain
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
```

```plain
helm install cert-manager  \
    --namespace cert-manager \
    --version v1.11.0 \
    --set installCRDs=true \
    jetstack/cert-manager
kubectl wait --for=condition=Ready pod --all -n cert-manager
```

```plain
kubectl get pod -n cert-manager
```

> Result:
> ```plain
> NAME                                       READY   STATUS    RESTARTS   AGE
> cert-manager-64f9f45d6f-56nkx              1/1     Running   0          54s
> cert-manager-cainjector-56bbdd5c47-f2vz7   1/1     Running   0          54s
> cert-manager-webhook-d4f4545d7-zbzjd       1/1     Running   0          54s
> ```



Install certs, better resolution LetsEncrypt, Vault:

```plain
kubectl create -n cert-manager \
    secret tls manager-cacerts \
    --cert ./labs/03/certs/ca/root-ca.crt \
    --key ./labs/03/certs/ca/root-ca.key
```

```plain
kubectl apply -f ./labs/03/cert-manager/issuer-ca.yaml
```

```plain
kubectl apply -f labs/03/cert-manager/certification.yaml
```

kubectl get secrets/istio-gateway-cert -n istio-ingress

kubectl get Certificate -n istio-ingress

> Result:
> ```plain
> 
> ```

Let's check the certificate SAN was specified correctly as `killercoda.com`:

```bash
kubectl get secret -n istio-ingress manager-cacerts -o jsonpath="{.data['tls\.crt']}" | base64 -d | step certificate inspect -
```


