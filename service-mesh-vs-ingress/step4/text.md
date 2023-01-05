## 

In the previous lab, we explored the function of Envoy and the need for a control plane to adapt it to a dynamic environment such as a cloud platform utilizing containers or Kubernetes. 

Istio serves as this control plane, enabling the integration and secure connection of Envoy proxies (also known as Istio service proxies, sidecar proxies, or data planes) with deployed workloads. 

Through the control plane's API, users can manipulate the behavior of the network. In this lab, we already have Istio installed, so we will focus on deploying some services.

To confirm that we have installed istioctl, we will run the following command:

```plain
istioctl version
```{{exec}}

> You should observe something similar to the following output:
> ```plain
> client version: 1.16.1
> control plane version: 1.16.1
> data plane version: 1.16.1 (2 proxies)
> ```

From this point, we can use the debug endpoints of the Istio control plane to determine which services are currently running and what Istio has identified.

All services/external services from all registries:

```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/registryz | jq
```{{exec}}

All endpoints:
```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/endpointz | jq
```{{exec}}

Listeners and routes

```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/adsz | jq
```{{exec}}

Metrics:

```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /metrics
```{{exec}}

Istio injection sidecar can be set manually or automagically trought specific namespace, every app deployed to that namespace will get injected with envoy proxy automatically.

We will begin by creating the namespace WITHOUT `istio-injection` enabled.

```plain
kubectl create namespace istio-lab-01
```{{exec}}

Let's run some mock `nicholasjackson/fake-service` apps:

```plain
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/backend-api.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/greetings.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/order-v1.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/sleep.yaml
NAMESPACE=istio-lab-01 URI=http://order:8080/health ./labs/02/wait.sh
```{{exec}}

After executing these commands, it is a good idea to verify the pods running in the `istio-lab-01` namespace:

```plain
kubectl -n istio-lab-01 get pods
```{{exec}}

## Inject sidecars manually

We will install a sidecar onto `httpbin` service from the previous lab and explore it. We will manually inject the sidecar so that we can experiment with the security permissions in the bonus section, as the Istio sidecar has disabled privileges by default.

In the current istio configuration, `meshConfigMapName` we will get from:

```plain
kubectl -n istio-system get configmap
```{{exec}}

> As a result of the previous action, we will obtain something similar to what is shown. For the next command, we will select:
> - `istio` as `meshConfigMapName`
> - `istio-sidecar-injector` as `injectConfigMapName`
> ```plain
> NAME                                  DATA   AGE
> istio                                 2      26m
> istio-ca-root-cert                    1      26m
> istio-gateway-deployment-leader       0      26m
> istio-gateway-status-leader           0      26m
> istio-leader                          0      26m
> istio-namespace-controller-election   0      26m
> istio-sidecar-injector                2      26m
> kube-root-ca.crt                      1      27m
> ```

To add the Istio sidecar to the `httpbin` service in the namespace `istio-lab-01`, run the following command:

```plain
istioctl kube-inject -f ./labs/02/httpbin.yaml --meshConfigMapName istio --injectConfigMapName istio-sidecar-injector  | kubectl -n istio-lab-01 apply -f -
```{{exec}}

```plain
kubectl -n istio-lab-01 get pods
```{{exec}}

> We will get something similar to:
> ```plain

> ```

## Inject sidecars automatically

We will begin by deleting namespace and will create again that namespace with injection enabled

```plain
kubectl delete namespace istio-lab-01
kubectl create namespace istio-lab-01
kubectl label namespace istio-lab-01 istio-injection=enabled
```{{exec}}

Let's run some mock `nicholasjackson/fake-service` apps:

```plain
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/backend-api.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/greetings.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/order-v1.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/sleep.yaml
NAMESPACE=istio-lab-01 URI=http://order:8080/health ./labs/02/wait.sh
```{{exec}}

After executing these commands, it is a good idea to verify the pods running in the `istio-lab-01` namespace:

```plain
kubectl -n istio-lab-01 get pods
```{{exec}}

> We will get something similar to:
> ```plain

> ```
