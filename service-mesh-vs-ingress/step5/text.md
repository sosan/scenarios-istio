## Istio Gateways

The Istio Gateway is a load balancer for HTTP/TCP traffic that can be configured to work in any environment. It allows multiple gateways to exist within a service mesh and for different gateway implementations to coexist. It can also be bound to specific workloads by specifying a set of labels, allowing for the use of pre-existing network appliances.

The Istio Gateway is used for ingress traffic management and addresses limitations in the Kubernetes Ingress API by separating L4-L6 configurations from L7

Istio Gateway overcomes the Ingress shortcomings by separating the L4-L6 spec from L7. It only configures the L4-L6 functions (e.g., ports to expose, TLS configuration) that are uniformly implemented by all good L7 proxies. Users can then use standard Istio rules to control HTTP requests as well as TCP traffic entering a Gateway by binding a VirtualService to it.

![Istio gateway](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/istio_gateway.svg)

This diagram shows that external traffic sends a request to the default gateway, which then routes the request to the appropriate service (in this case, Service A). Service A processes the request and sends a response back to the default gateway, which then sends the response back to the external traffic.

Please note that this is a simple example, and in reality the routing decision might be more complex, depending on the service, the path and the headers of the request.


## Istio Ingress Gateways

The Istio ingress gateway is a specialized proxy that sits at the edge of the mesh and controls access to the services within the cluster from the public network.

It is exposed by a Kubernetes Service of type LoadBalancer, which can be query default using:

```plain
kubectl get svc -n istio-system --selector istio=ingressgateway
```{{exec}}

> ```plain
> NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
> istio-ingressgateway   LoadBalancer   10.98.230.210   <pending>     15021:32255/TCP,80:31165/TCP,443:32507/TCP,31400:30603/TCP,15443:31674/TCP   10m
> ```

When using `kind`, the external IP address of the Istio ingress gateway will not be assigned a static IP address, it will be in a `Pending` state.

The `Loadbalancer` service created: 
- if we are in a **Kubernetes managed** or a **MetalLB** environment, both will assign an IP to that loadbalancer. 
- Otherwise, it will not be possible to assign an IP and its status will remain `pending`.

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
> 50661 portforward.go:406] an error occurred forwarding 8081 -> 8080: error forwarding port 8080
> ```

**As we expected, the gateway has responded with an error.**

## Allow incoming traffic to the gateway

A service mesh can have multiple ingress gateways. This is typically used in multi-tenant environments. 

In this case, we will installing new istio ingress gateway in namespace `istio-ingress` separate for increased security and isolation.

```plain
kubectl create namespace istio-ingress
istioctl install -y -n istio-ingress -f ./labs/03/istio-install-gateway.yaml
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
> NAMESPACE       NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                   
> istio-ingress   istio-ingressgateway   LoadBalancer   10.96.178.175   <pending>     15021:30304/TCP,80:30507/TCP,443:31811/TCP                                
> istio-system    istio-ingressgateway   LoadBalancer   10.101.85.163   <pending>     15021:30449/TCP,80:31252/TCP,443:30696/TCP,31400:31143/TCP,15443:31990/TCP
> ```

As we previously mentioned, if we don't have a **MetalLB** environment or a **Managed Kubernetes**, `external-ip` will remain in the <pending> state.

To solve this issue, we can use the port-forward command to manually route traffic towards the ingress gateway.

## Two possibilities:

- If we obtain an external IP, we will continue with...
- If we do not obtain an external IP, we will proceed to...

We will focus on the loadbalancer in the namespace within `istio-ingress`:

```plain
kubectl get service -n istio-ingress
```{{exec}}

In a managed Kubernetes cluster or with MetalLB, the cloud provider or MetalLB will assign a static IP to the load balancer for routing traffic to the gateway. 

To resolve this issue, you can use the "port-forward" command to forward the ingress gateway.

```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

```plain
lsof -i :8081
```{{exec}}


A VirtualService defines a set of traffic routing rules to apply when a host is addressed. It allows you to route traffic to different versions of a service or to different services based on certain conditions. This API endpoint allows you to create, read, update, and delete VirtualServices in an Istio service mesh.

```plain
kubectl apply -f labs/03/ingress-gateway.yaml -n istio-lab-01
kubectl apply -f labs/03/virtualservices.yaml -n istio-lab-01
```{{exec}}

```plain
kubectl port-forward -n istio-ingress svc/new-ingressgateway 1234:80 >> /dev/null &
```{{exec}}



kubectl get gateway -A

kubectl get service -A -l istio=ingressgateway

kubectl get gateways.networking.istio.io mock-apps-gateway -n istio-ingress  -o jsonpath='{.status.addresses[*].value}'
kubectl get service -n istio-ingress istio-ingressgateway   -o jsonpath='{.status.addresses[*].value}'


kubectl get virtualservices -n istio-labs-01

kubectl get gateway -A


```plain
GATEWAY_IP=$(kubectl get svc \
    -n istio-ingress mock-apps-gateway \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```{{exec}}












