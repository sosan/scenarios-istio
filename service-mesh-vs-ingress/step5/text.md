## Istio Ingress Gateways

The Istio ingress gateway is a specialized proxy that sits at the edge of the mesh and controls access to the services within the cluster from the public network. It is exposed by a Kubernetes Service of type LoadBalancer, which can be queried using the appropriate command.

```plain
kubectl get svc -n istio-system --selector istio=ingressgateway
```{{exec}}

> ```plain
> NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
> istio-ingressgateway   LoadBalancer   10.98.230.210   <pending>     15021:32255/TCP,80:31165/TCP,443:32507/TCP,31400:30603/TCP,15443:31674/TCP   10m
> ```

When using `kind`, the external IP address of the Istio ingress gateway will not be assigned a static IP address, it will be in a `Pending` state.

However, in a managed Kubernetes cluster, the cloud provider will assign a static IP to the load balancer that can be used to route traffic to the gateway. 

To work around this issue, you can use the "port-forward" command to forward the ingress gateway:

```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

```plain
lsof -i :8081
```{{exec}}

> Result: 
> ```plain
> COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
> kubectl 73923 root    8u  IPv4 425756      0t0  TCP localhost:tproxy (LISTEN)
> kubectl 73923 root    9u  IPv6 425760      0t0  TCP ip6-localhost:tproxy (LISTEN)
> ```

By using the "port-forward" command, traffic to localhost:8081 will now be directed to the ingress gateway. If you open curl and type request in that address, you will find that the gateway will reject your request. This is the default behavior of the gateway.

```plain
curl -v localhost:8081
```{{exec}}

> Result:
> ```plain
> 50661 portforward.go:406] an error occurred forwarding 8081 -> 8080: error forwarding port 8080
> ```

## Allow incoming traffic to the gateway

A service mesh can have multiple ingress gateways. This is typically used in multi-tenant environments. In this case, we will installing the istio-ingress gateway in a namespace `istio-ingress` separate for increased security and isolation.

```plain
kubectl create namespace istio-ingress
istioctl install -y -n istio-ingress -f ./labs/03/istio-install-gateway.yaml
```{{exec}}

```plain
✔ Ingress gateways installed                                                                                       
✔ Installation complete                                                                                            
[...]
```

We should verify that the ingress gateway was installed correctly:

```plain
kubectl get service -A -l istio=ingressgateway
```

> Result:
> ```plain
> NAMESPACE       NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                   
> istio-ingress   istio-ingressgateway   LoadBalancer   10.96.178.175   <pending>     15021:30304/TCP,80:30507/TCP,443:31811/TCP                                
> istio-system    istio-ingressgateway   LoadBalancer   10.101.85.163   <pending>     15021:30449/TCP,80:31252/TCP,443:30696/TCP,31400:31143/TCP,15443:31990/TCP
> ```

After the kubectl command, we see two services as `LoadBalancer`, but with the `EXTERNAL-IP` in pending.

The `Loadbalancer` service created earlier: 
- if we are in a Kubernetes managed or a MetalLB environment, the cloud provider or MetalLB will assign an IP to that loadbalancer. 
- Otherwise, it will not be possible to assign an IP and its status will remain `pending`.

To solve this issue, we can use the port-forward command to manually route traffic towards the ingress gateway.

We focus on the loadbalancer in the namespace within `istio-ingress`

<!-- Modify config gateway

Istio uses the `Gateway` kind resource to control the types of traffic that are allowed into the mesh. To configure the ingress gateway to accept HTTP traffic on port 80, you can use the following configuration.

```plain
cat ./labs/03/ingress-gateway.yaml
```{{exec}}

```plain
kubectl apply -f ./labs/03/ingress-gateway.yaml -n istio-ingress
```{{exec}} -->

<!-- We should verify that the ingress gateway was installed correctly:

```plain
kubectl get gateway -n istio-ingress
```{{exec}}

> Result: 
> ```plain
> NAME                    AGE
> mock-apps-gateway       26s
> ```
> -->

The ingress gateway created a Kubernetes Service of type LoadBalancer, which will provide an IP address that can be used to access the gateway

kubectl get svc -n istio-ingress --selector istio=ingressgateway

```plain
kubectl get svc -n istio-ingress istio-ingressgateway -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
```{{exec}}


```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

When using `kind`, the external IP address of the Istio ingress gateway will not be assigned a static IP address, it will be in a `Pending` state.

However, in a managed Kubernetes cluster, the cloud provider will assign a static IP to the load balancer that can be used to route traffic to the gateway. 

To work around this issue, you can use the "port-forward" command to forward the ingress gateway:

```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

```plain
lsof -i :8081
```{{exec}}


kubectl get service -A -l istio=ingressgateway

kubectl get gateways.networking.istio.io mock-apps-gateway -n istio-ingress  -o jsonpath='{.status.addresses[*].value}'
kubectl get service -n istio-ingress istio-ingressgateway   -o jsonpath='{.status.addresses[*].value}'


kubectl get virtualservices -n istio-ingress

kubectl get gateway -A


```plain
GATEWAY_IP=$(kubectl get svc \
    -n istio-ingress mock-apps-gateway \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```{{exec}}












