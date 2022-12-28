## Sidecar proxy: Envoy

In this lab, we delve into one of the foundational components of Istio: the "data plane".

In Istio, Envoy is deployed as a sidecar container alongside the service it is protecting. This allows it to: 
- intercept all inbound and outbound traffic to and from the service,
- apply any configured policies or rules before forwarding the traffic to its destination. 

This enables Istio to provide features to the services in the mesh such as:
- routing
- load balancing
- observability
- security

Envoy is a open source service proxy. It is responsible for intercepting and directing incoming and outgoing traffic between microservices, and for providing observability, security, and other features to the service mesh.

The importance of Envoy to Istio cannot be overstated, which is why we start our labs with it.