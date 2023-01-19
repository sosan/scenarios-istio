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

We verify that we have installed at the beginning of this course:

```plain
kubectl get pods -n istio-system
```{{exec}}

> Result:
> ```plain
> NAME                                    READY   STATUS    RESTARTS   AGE
> istio-egressgateway-556484c697-nbd62    1/1     Running   0          30s
> istio-ingressgateway-85c5744c4f-8gs89   1/1     Running   0          30s
> istiod-6948f8fb67-mftds                 1/1     Running   0          36s
> ```

The installed components are:
- **Istio egress gateway** – used for securing egress traffic
- **Istio ingress gateway** – the entry point of traffic coming into your cluster
- **Istiod** – Istio’s control plane that configures the service proxies

From this point, we can use the debug endpoints of the Istio control plane to determine which services are currently running and what Istio has identified.

All services/external services from all registries:

```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/registryz | jq
```{{exec}}

All endpoints:
```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/endpointz | jq
```{{exec}}

Metrics:
```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /metrics
```{{exec}}

Listeners and routes
```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/adsz | jq
```{{exec}}

We will focus on listening with the following command:

```plain
kubectl exec -n istio-system deploy/istiod -- pilot-discovery request GET /debug/adsz | jq '.clients[0].watches."type.googleapis.com/envoy.config.endpoint.v3.ClusterLoadAssignment"'
```{{exec}}

> Result:
> ```plain
> "outbound|15443||istio-ingressgateway.istio-system.svc.cluster.local",
> "outbound|31400||istio-ingressgateway.istio-system.svc.cluster.local",
> "outbound|443||istio-ingressgateway.istio-system.svc.cluster.local",
> "outbound|80||istio-ingressgateway.istio-system.svc.cluster.local",
> "outbound|15021||istio-ingressgateway.istio-system.svc.cluster.local",
> "outbound|443||istio-egressgateway.istio-system.svc.cluster.local",
> "outbound|80||istio-egressgateway.istio-system.svc.cluster.local",
> "outbound|15012||istiod.istio-system.svc.cluster.local",
> "outbound|443||istiod.istio-system.svc.cluster.local",
> "outbound|9153||kube-dns.kube-system.svc.cluster.local",
> "outbound|15010||istiod.istio-system.svc.cluster.local",
> "outbound|15014||istiod.istio-system.svc.cluster.local",
> "outbound|443||kubernetes.default.svc.cluster.local",
> "outbound|53||kube-dns.kube-system.svc.cluster.local"
> ```



Istio injection sidecar can be set manually or automagically trought specific namespace, every app deployed to that namespace will get injected with envoy proxy automatically.

## Inject sidecars manually

We will begin by creating the namespace WITHOUT `istio-injection` enabled.

```plain
kubectl create namespace istio-lab-01
```{{exec}}

Next, we will install a sidecar onto `httpbin` service from the previous lab and explore it. We will manually inject the sidecar so that we can experiment with the security permissions in the bonus section, as the Istio sidecar has disabled privileges by default.

In the current istio configuration, `meshConfigMapName` we will get from:

```plain
kubectl -n istio-system get configmap
```{{exec}}

> As a result of the previous action, we will obtain something similar to what is shown. For the next command, we will select:
> - `istio` as `meshConfigMapName`
> - `istio-sidecar-injector` as `injectConfigMapName`
> ```plain
> NAME                                  DATA   AGE
> istio                                 2      10m
> istio-ca-root-cert                    1      10m
> istio-gateway-deployment-leader       0      10m
> istio-gateway-status-leader           0      10m
> istio-leader                          0      10m
> istio-namespace-controller-election   0      10m
> istio-sidecar-injector                2      10m
> kube-root-ca.crt                      1      11m
> ```

```plain
istioctl kube-inject -f ./labs/02/httpbin.yaml \
--meshConfigMapName istio \
--injectConfigMapName istio-sidecar-injector \
 | kubectl -n istio-lab-01 
```

Explanation above command:
```plain
istioctl kube-inject
```
This command is used to inject an Istio sidecar proxy into a Kubernetes deployment manifest.

```plain
-f ./labs/02/httpbin.yaml
```
This flag specifies the path to the deployment manifest file to be injected. In this case, the file is located at ./labs/02/httpbin.yaml.

```plain
--meshConfigMapName istio
```
This flag specifies the name of the Istio Mesh ConfigMap to use. In this case, the name is istio.

```plain
--injectConfigMapName istio-sidecar-injector
```
This flag specifies the name of the Istio Injector ConfigMap to use. In this case, the name is istio-sidecar-injector.

```plain
| kubectl -n istio-lab-01
```
This part of the command pipes the output of the istioctl kube-inject command to kubectl, which is used to apply the modified deployment manifest to the Kubernetes cluster. The -n flag specifies the namespace to apply the manifest to, which in this case is istio-lab-01.

A more detailed explanation:

> - **MAIN INSTRUCTION AND YAML DEPLOY SERVICE CONFIG**
>   - istioctl kube-inject -f ./labs/02/httpbin.yaml
> 
> - **MESH CONFIG MAP NAME** is a Kubernetes ConfigMap that stores the Istio mesh-wide configuration. This is used to control the behavior of the Istio service mesh, and can be used to set various options such as the default outbound/inbound traffic policy:
>   - --meshConfigMapName istio
> 
> - **INJECTOR CONFIG MAP NAME** is a Kubernetes ConfigMap that stores the configuration for the Istio sidecar injector. The sidecar injector is a tool that automatically injects an Istio sidecar proxy into the pods. This can be used to control the behavior of the sidecar injector, such as which namespaces to inject the sidecar into and which labels to use to determine which pods should be injected.
>   - --injectConfigMapName istio-sidecar-injector


To add the Istio sidecar to the `httpbin` service in the namespace `istio-lab-01`, run the following command:

```plain
istioctl kube-inject -f ./labs/02/httpbin.yaml --meshConfigMapName istio --injectConfigMapName istio-sidecar-injector  | kubectl -n istio-lab-01 apply -f -
```{{exec}}

After executing these commands, it is a good idea to verify the pods running in the `istio-lab-01` namespace:

```plain
kubectl -n istio-lab-01 get pods
```{{exec}}

> We will get something similar to:
> ```plain
> NAME                       READY   STATUS    RESTARTS   AGE
> httpbin-7dc7cf6dd6-qljds   2/2     Running   0          12s
> ```

To quick verify that the Envoy proxy has been injected, the `READY` status should show 2/2.


## Inject sidecars automatically

We will begin by deleting namespace and will create again that namespace with injection enabled

```plain
kubectl delete namespace istio-lab-01
kubectl create namespace istio-lab-01
kubectl label namespace istio-lab-01 istio-injection=enabled
```{{exec}}

Let's run some mock `nicholasjackson/fake-service` apps:

```plain
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/follow.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/greetings.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/order-v1.yaml
kubectl apply -n istio-lab-01 -f ./labs/mock-apps/sleep.yaml
kubectl wait --for=condition=Ready pod --all -n istio-lab-01
```{{exec}}

> ```plain
> Result:
> pod/follow-68f9f9444b-wcp6j condition met
> pod/greetings-858487c485-gb545 condition met
> pod/order-v1-6f84964467-6b2gj condition met
> pod/sleep-6c7c95d6c-js4nv condition met
> ```

After executing these commands, it is a good idea to verify the pods running in the `istio-lab-01` namespace:

```plain
kubectl -n istio-lab-01 get pods
```{{exec}}

> We will get something similar to:
> ```plain
> NAME                           READY   STATUS    RESTARTS   AGE
> follow-68f9f9444b-k5x26   2/2     Running   0          22s
> greetings-858487c485-72d4d     2/2     Running   0          21s
> order-v1-6f84964467-qvc4k      2/2     Running   0          21s
> sleep-6c7c95d6c-5r4gq          2/2     Running   0          20s
> ```

Check `2/2` for istio injected each pod or we can use:

```plain
istioctl -n istio-lab-01 analyze
```{{exec}}

> Result:
> ✔ No validation issues found when analyzing namespace: istio-lab-01.


To compare the difference between a namespace with Istio injection enabled and one that is not enabled (namespace default is not injection activated )

```plain
istioctl -n default analyze
```{{exec}}

> Result:
> Info [IST0102] (Namespace default) The namespace is not enabled for Istio injection. Run 'kubectl label namespace default istio-injection=enabled' to enable it, or 'kubectl label namespace default istio-injection=disabled' to explicitly mark it as not needing injection.


