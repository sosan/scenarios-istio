#!
until [ $(kubectl get svc/istio-ingress-gateway -n istio-ingress -o jsonpath="{.status.loadBalancer.ingress[0].ip}"|wc -c) -gt 5 ]
do
  sleep 1
done