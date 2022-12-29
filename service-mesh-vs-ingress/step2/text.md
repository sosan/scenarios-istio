## Sidecar proxy: Envoy

In this lab, we delve into one of the foundational components of Istio: the "data plane".

In Istio, Envoy is deployed as a sidecar container alongside the service it is protecting.

Envoy is a high-performance proxy designed for modern, complex environments. It acts as a middleman for network communication, routing traffic between services and enforcing policies such as rate limiting and authentication.

This allows it to: 
- intercept all inbound and outbound traffic to and from the service,
- apply any configured policies or rules before forwarding the traffic to its destination. 

In addition to its role as a proxy, Envoy also provides features such as:
- routing (supports multiple protocols and can be used in conjunction with other technologies such as gRPC and HTTP/2)
- load balancing
- observability
- service discovery
- security

One of the main benefits of using Envoy is its ability to provide a single, consistent layer for all communication within a microservices architecture. This can simplify the architecture and make it easier to manage and scale the system. Envoy is also highly configurable and can be customized to fit the specific needs of a particular deployment.

Envoy is designed to be resilient and performant, with a focus on high throughput and low latency. It is widely used in production environments and has been adopted by companies such as Lyft, Airbnb, and Square.

The importance of Envoy to Istio cannot be overstated, which is why we start our labs with it.

