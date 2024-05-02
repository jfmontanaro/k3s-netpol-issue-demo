set -e

echo 'Installing K3s...'
curl -sfL https://get.k3s.io | 
    sh -s - \
    --cluster-cidr=10.42.0.0/16,2001:cafe:42::/56 \
    --service-cidr=10.43.0.0/16,2001:cafe:43::/112

echo 'Waiting for cluster to be ready...'
sleep 30
echo 'Creating initial resources'
kubectl apply -f server.yaml -f service.yaml -f client.yaml
sleep 10

echo 'Testing connectivity (should succeed at this point)'
kubectl exec -it pod/client -- wget -O - http://whoami.default.svc.cluster.local

echo 'Creating network policy'
kubectl apply -f policy.yaml
sleep 5

echo 'Recreating server'
kubectl delete -f server.yaml
kubectl apply -f server.yaml
sleep 5

echo 'Testing connectivity (should fail indefinitely)'
set +e
while true; do
    kubectl exec -it pod/client -- wget -O - http://whoami.default.svc.cluster.local
    sleep 1
done
