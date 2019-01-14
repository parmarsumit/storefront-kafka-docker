#!/bin/bash
#
# Part 2: Deploy resources to dev Namespace

# Constants - CHANGE ME!
readonly NAMESPACE='dev'
readonly PROJECT='gke-confluent-atlas'
readonly CLUSTER='storefront-api-non-prod'
readonly REGION='us-central1'
readonly ZONE='us-central1-a'

# kubectl delete -n istio-system secret istio-ingressgateway-certs
# kubectl delete -n istio-system secret istio-ingressgateway-ca-certs

export CERT_PATH=~/Documents/Articles/gke-kafka/sslforfree_non_prod
kubectl create -n istio-system secret tls istio-ingressgateway-certs \
  --key $CERT_PATH/private.key --cert $CERT_PATH/certificate.crt

kubectl create -n istio-system secret generic istio-ingressgateway-ca-certs \
  --from-file $CERT_PATH/ca_bundle.crt

kubectl apply -f ./resources/other/istio-gateway.yaml

kubectl apply -n $NAMESPACE -f ../../storefront-secrets/mongodb-atlas-external-mesh.yaml
kubectl apply -n $NAMESPACE -f ../../storefront-secrets/confluent-cloud-external-mesh.yaml

# kubectl delete configmap confluent-cloud-kafka -n $NAMESPACE
# kubectl delete secret mongodb-atlas -n $NAMESPACE
# kubectl delete secret confluent-cloud-kafka -n $NAMESPACE

kubectl apply -n $NAMESPACE -f ./resources/config/confluent-cloud-kafka-configmap.yaml
kubectl get configmap confluent-cloud-kafka -n $NAMESPACE --export -o yaml \
  | kubectl apply -n test -f -
kubectl get configmap confluent-cloud-kafka -n $NAMESPACE --export -o yaml \
  | kubectl apply -n uat -f -

kubectl apply -f ../../storefront-secrets/mongodb-atlas-secret.yaml
kubectl get secret mongodb-atlas -n $NAMESPACE --export -o yaml \
  | kubectl apply -n test -f -
kubectl get secret mongodb-atlas -n $NAMESPACE --export -o yaml \
  | kubectl apply -n uat -f -

kubectl apply -f ../../storefront-secrets/confluent-cloud-kafka-secret.yaml
kubectl get secret confluent-cloud-kafka -n $NAMESPACE --export -o yaml \
  | kubectl apply -n test -f -
kubectl get secret confluent-cloud-kafka -n $NAMESPACE --export -o yaml \
  | kubectl apply -n uat -f -

# kubectl apply -f ./resources/other/ingress-auth-policy.yaml
# kubectl apply -n $NAMESPACE -f ./resources/other/accounts-auth-policy.yaml

# kubectl delete deployment accounts -n $NAMESPACE
# kubectl delete deployment fulfillment -n $NAMESPACE
# kubectl delete deployment orders -n $NAMESPACE

kubectl apply -n $NAMESPACE -f ./resources/services/accounts.yaml
# kubectl apply -n $NAMESPACE -f ./resources/services/fulfillment.yaml
# kubectl apply -n $NAMESPACE -f ./resources/services/orders.yaml