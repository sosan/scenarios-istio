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

We will begin by creating the namespace:

```plain
kubectl create namespace istio-lab-01
```{{exec}}


```plain
kubectl apply -n istio-lab-01 -f labs/02/services/backend-api.yaml
kubectl apply -n istio-lab-01 -f labs/02/services/greetings.yaml
kubectl apply -n istio-lab-01 -f labs/02/services/order-v1.yaml
kubectl apply -n istio-lab-01 -f labs/02/services/sleep.yaml
```{{exec}}


After executing these commands, it is a good idea to verify the pods running in the istioinaction namespace:

```plain
kubectl -n istio-lab-01 get pods
```