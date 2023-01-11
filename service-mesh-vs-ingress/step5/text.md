## Istio Gateways



We recommend installing the istio-ingress gateway in a namespace separate from istiod for increased security and isolation. When installing, make sure to use a revision that is compatible with the control plane in the istio-ingress namespace

```plain
kubectl create namespace istio-ingress
kubectl apply -f ./labs/03/ingress-gateway.yaml -n istio-ingress
```{{exec}}

We should verify that the ingress gateway was installed correctly:

```plain
kubectl get gateway -n istio-ingress
```{{exec}}

> Result: 
> NAME                    AGE
> istio-ingress-gateway   26s
>

The ingress gateway will create a Kubernetes Service of type LoadBalancer, which will provide an IP address that can be used to access the gateway

```plain
```


```plain
GATEWAY_IP=$(kubectl get svc \
    -n istio-ingress istio-ingress-gateway \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```{{exec}}












