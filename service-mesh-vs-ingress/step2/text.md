## Sidecar proxy: Envoy Proxy

We delve into one of the foundational components of Istio: the "data plane".

In Istio, [Envoy Proxy](https://www.envoyproxy.io) is deployed as a sidecar container alongside the service it is protecting.

Envoy is a high-performance proxy designed for modern, complex environments. It acts as a middleman for network communication, routing traffic between services and enforcing policies such as rate limiting and authentication.

This allows it to: 
- intercept all inbound and outbound traffic to and from the service,
- apply any configured policies or rules before forwarding the traffic to its destination. 

In addition to its role as a proxy, Envoy also provides features such as:

- **Routing**. Supports multiple protocols and can be used in conjunction with other technologies such as gRPC and HTTP/2

- **Load balancing**

- **Observability**. It is very difficult for architects to implement stats, logging, and tracing across different services and network infrastructures, such as load balancers. Without standardization, it becomes difficult to trace the root cause of a problem in a network by scanning the health of multiple services separately and identifying the point of failure.

- **Service discovery**. Scaling application features becomes difficult as developers spend a lot of their time writing network or security logic. 

- **Security**. It becomes challenging for the team to manage and maintain the network centrally and keep it safe and secure. Oftentimes, developers are frustrated because they have to spend time debugging the network or writing security policies instead of focusing on business logic.

One of the main benefits of using Envoy is its ability to provide a single, consistent layer for all communication within a microservices architecture.

Fat Microservice:
![Fat Microservice](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/fat_microservices.svg)

Microservice with service mesh:
![Microservice with service mesh](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/microservice_with_mesh.png)


This can simplify the architecture and make it easier to manage and scale the system. Envoy is also highly configurable and can be customized to fit the specific needs of a particular deployment.

Envoy is designed to be resilient and performant, with a focus on high throughput and low latency. It is widely used in production environments and has been adopted by companies such as Lyft, Airbnb, and Square.

Here is a diagram showing how Envoy can be used to route gRPC and HTTP/2 traffic in a microservices architecture:

![Envoy requests](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/diagram_envoy_requests.svg)

In this diagram, the client makes gRPC and HTTP/2 requests to Envoy, which acts as a proxy and forwards the requests to the appropriate services (in this case, Service A for the gRPC request and Service B for the HTTP/2 request). The services process the requests and send responses back to Envoy, which then forwards the responses to the client.

Envoy can support multiple protocols simultaneously, allowing it to route traffic to different services depending on the protocol being used. It can also be configured to perform protocol transformation, allowing it to route traffic between services that use different protocols.

Here is a diagram showing the relationship between Envoy and Istio:

![Relation envoy istio](https://raw.githubusercontent.com/sosan/scenarios-istio/main/service-mesh-vs-ingress/assets/images/relation_envoy_istio.svg)

In this diagram, Envoy sits between the client and the service, proxying requests and responses. It also communicates with the Istio control plane, sending request/response metrics and receiving configuration updates. The control plane uses this information to manage the behavior of the service mesh, including routing traffic, enforcing policies, and providing observability.

The importance of Envoy to Istio cannot be overstated, which is why we start our labs with it.

Let's run some labs!. GOO!