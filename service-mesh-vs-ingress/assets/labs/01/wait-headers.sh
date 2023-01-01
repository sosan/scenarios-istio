#!
echo "Waiting..."
until kubectl exec deploy/sleep -- curl -s --max-time 1 http://envoy/headers >/dev/null 2>&1
do
  sleep 1
done
echo "Done"