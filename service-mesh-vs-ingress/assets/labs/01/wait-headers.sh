#!
echo "Waiting..."
until kubectl -n envoy_lab_01 exec deploy/sleep -- curl -s --max-time 1 http://envoy/headers >/dev/null 2>&1
do
  sleep 1
done
echo "Done"