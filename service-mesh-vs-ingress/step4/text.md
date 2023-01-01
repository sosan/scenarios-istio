## 

In the previous lab, we explored the function of Envoy and the need for a control plane to adapt it to a dynamic environment such as a cloud platform utilizing containers or Kubernetes. 

Istio serves as this control plane, enabling the integration and secure connection of Envoy proxies (also known as Istio service proxies, sidecar proxies, or data planes) with deployed workloads. 

Through the control plane's API, users can manipulate the behavior of the network. In this lab, we already have Istio installed, so we will focus on deploying some services.


```plain
kubectl create namespace istio_lab_01
```{{exec}}


```plain
kubectl apply -n istio_lab_01 -f services/backend-api.yaml
kubectl apply -n istio_lab_01 -f services/greetings.yaml
kubectl apply -n istio_lab_01 -f services/order-v1.yaml
kubectl apply -n istio_lab_01 -f services/sleep.yaml
```{{exec}}