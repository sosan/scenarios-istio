## Istio Gateways



We recommend installing the istio-ingress gateway in a namespace separate from istiod for increased security and isolation. When installing, make sure to use a revision that is compatible with the control plane in the istio-ingress namespace

```plain
kubectl create namespace istio-ingress
istioctl install -y -n istio-ingress -f ./labs/03/ingress-gateways.yaml --revision 1-8-3
kubectl wait --for=condition=Ready pod --all -n istio-ingress
```{{exec}}

We should verify that the ingress gateway was installed correctly:

```plain
kubectl get po -n istio-ingress
```{{exec}}

> Result: 
>

The ingress gateway will create a Kubernetes Service of type LoadBalancer, which will provide an IP address that can be used to access the gateway

```plain
```


```plain
GATEWAY_IP=$(kubectl get svc \
    -n istio-ingress istio-ingress-gateway \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
```{{exec}}












