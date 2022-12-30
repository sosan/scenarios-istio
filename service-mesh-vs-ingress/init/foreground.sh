echo "========= INSTALING ISTIO ========="
FILE=/ks/wait-background.sh; while ! test -f ${FILE}; do clear; sleep 0.1; done; bash ${FILE}
export ISTIO_VERSION=1.16.1
curl -L https://istio.io/downloadIstio | TARGET_ARCH=x86_64 sh -
echo "export PATH=/root/istio-${ISTIO_VERSION}/bin:\$PATH" >> .bashrc
echo "========= SETTING PATH ========="
export PATH=/root/istio-${ISTIO_VERSION}/bin:$PATH
mv /tmp/demo.yaml /root/istio-${ISTIO_VERSION}/manifests/profiles/
istioctl install --set profile=demo -y --manifests=/root/istio-${ISTIO_VERSION}/manifests
echo "========= INSTALLED ========="