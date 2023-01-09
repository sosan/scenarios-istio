#!
echo "Waiting to getting up..."
until kubectl -n ${NAMESPACE} exec deploy/sleep -- curl -s --max-time 1 ${URI} >/dev/null 2>&1
do
  sleep 1
done
echo "It's done. You can continue"