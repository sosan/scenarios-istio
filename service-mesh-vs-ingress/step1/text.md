## Istio

Istio is an open-source service mesh platform that provides features such as load balancing, service discovery, and monitoring for microservices. It uses a sidecar proxy, which is a separate process that runs alongside each microservice, to intercept and manage communication between services.

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