## Istio

Istio is an open-source service mesh platform that provides features such as:
- load balancing
- service discovery
- monitoring for microservices

It uses a sidecar proxy(envoy), which is a separate process that runs alongside each microservice, to intercept and manage communication between services.

Here is a simplified diagram of how Istio works as a service mesh:

- A client sends a request to a microservice.
- The request is intercepted by the sidecar proxy for the microservice.
- The sidecar proxy forwards the request to the microservice.
- The microservice processes the request and sends a response back to the sidecar proxy.
- The sidecar proxy forwards the response back to the client.
Using a sidecar proxy allows Istio to provide features such as load balancing, service discovery, and monitoring without requiring any changes to the code of the microservices themselves. This makes it easier to manage communication between microservices and to add new features as needed.


![Istio diagram explication](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/explanation_diagram_istio.svg)

This diagram illustrates the process of a client sending a request to a microservice, which is intercepted by the sidecar proxy for that microservice (Sidecar1). The sidecar proxy then forwards the request to the microservice, which processes it and sends a response back to the sidecar proxy. The sidecar proxy then forwards the response back to the client.

Using a sidecar proxy allows Istio to provide features such as load balancing, service discovery, and monitoring without requiring any changes to the code of the microservices themselves. This makes it easier to manage communication between microservices and to add new features as needed.

## Main components of Istio

The main components of Istio include:
![Main components istio](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/components_istio.svg)

- **Data plane**: The data plane consists of a set of intelligent proxies (Envoy) that are deployed alongside each service in the mesh. These proxies intercept and direct traffic between services, and provide observability, security, and other features to the mesh.

- **Control plane**: The control plane consists of a set of components that are responsible for managing the data plane and enforcing policies and rules on the traffic flowing through the mesh. These components include the Pilot, Mixer, and Citadel components.

- **Policy and telemetry**: Istio provides a set of policy and telemetry components that allow you to define and enforce rules on traffic flowing through the mesh, as well as to collect and analyze metrics and logs from the data plane. These components include the Mixer and Prometheus components.

- **Ingress and egress**: Istio provides ingress and egress gateways that allow you to control access to and from the mesh, as well as to route traffic to and from external services.

Overall, Istio provides a set of tools and components that enable you to manage and secure your microservices-based applications at scale.






