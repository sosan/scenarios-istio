#!
echo "Waiting to getting up..."
until kubectl -n envoy-lab-01 exec deploy/sleep -- curl -s --max-time 1 http://envoy/headers >/dev/null 2>&1
do
  sleep 1
done
echo "It's done. You can continue"