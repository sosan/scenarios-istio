## Istio Ingress Gateways

The Istio ingress gateway is a specialized proxy that sits at the edge of the mesh and controls access to the services within the cluster from the public network. It is exposed by a Kubernetes Service of type LoadBalancer, which can be queried using the appropriate command.

```plain
kubectl get svc -n istio-system --selector istio=ingressgateway
```{{exec}}

> ```plain
> NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
> istio-ingressgateway   LoadBalancer   10.98.230.210   <pending>     15021:32255/TCP,80:31165/TCP,443:32507/TCP,31400:30603/TCP,15443:31674/TCP   10m
> ```

When using kind, the external IP address of the Istio ingress gateway will not be assigned a static IP address, it will be in a "Pending" state. However, in a managed Kubernetes cluster, the cloud provider will assign a static IP to the load balancer that can be used to route traffic to the gateway. 

To work around this issue with kind, you can use the "port-forward" command to forward the ingress gateway to your local environment by opening a second terminal, executing the command and keeping the terminal running for the duration of your work.

```plain
kubectl port-forward -n istio-system svc/istio-ingressgateway 8081:80 >> /dev/null &
```{{exec}}

```plain
lsof -i :8081
```{{exec}}

By using the "port-forward" command, traffic to localhost:8081 will now be directed to the ingress gateway. If you open curl and type request in that address, you will find that the gateway will reject your request. This is the default behavior of the gateway.

```plain
curl -v localhost:8081
```{{exec}}

> Result:
> ```plain
> 50379 portforward.go:406] an error occurred forwarding 8080 -> 8080: error forwarding port 
> ```

### Admit traffic



Istio uses the `Gateway` kind resource to control the types of traffic that are allowed into the mesh. To configure the ingress gateway to accept HTTP traffic on port 80, you can use the following configuration.

```plain
cat ./labs/03/ingress-gateway.yaml
```{{exec}}

A service mesh can have multiple ingress gateways. This is typically used in multi-tenant environments. In this case, we will installing the istio-ingress gateway in a namespace separate from istiod for increased security and isolation. When installing, make sure to use a revision that is compatible with the control plane in the istio-ingress namespace

istioctl install -y -n istio-ingress -f ./labs/03/istio-install-gateway.yaml



we will be applying the Gateway configuration to the default ingress gateway, which is labeled with "istio=ingressgateway".


```plain
kubectl create namespace istio-ingress
kubectl apply -f ./labs/03/ingress-gateway.yaml -n istio-ingress
```{{exec}}

We should verify that the ingress gateway was installed correctly:

```plain
kubectl get gateway -n istio-ingress
```{{exec}}

> Result: 
> ```plain
> NAME                    AGE
> mock-apps-gateway       26s
> ```
>

The ingress gateway will create a Kubernetes Service of type LoadBalancer, which will provide an IP address that can be used to access the gateway

```plain
```

kubectl get gateways.networking.istio.io mock-apps-gateway -n istio-ingress  -o jsonpath='{.status.addresses[*].value}'

kubectl get service istio-ingressgateway -n istio-system  -o jsonpath='{.status.addresses[*].value}'

kubectl get gateway -A

kubectl get virtualservices -n istio-ingress




```plain
GATEWAY_IP=$(kubectl get svc \
    -n istio-ingress mock-apps-gateway \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```{{exec}}












