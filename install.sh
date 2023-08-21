#! /bin/bash

VALUES=values.yaml
CWD=$(pwd)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# install istio
kubectl create ns istio-system
helm install -n istio-system istio-base $CWD/manifests/charts/base

helm install istio-cni $CWD/manifests/charts/istio-cni -n kube-system --set components.cni.enabled=true -f $SCRIPT_DIR/$VALUES
helm install -n istio-system istiod $CWD/manifests/charts/istio-control/istio-discovery -f $SCRIPT_DIR/$VALUES

# install workloads
kubectl create namespace dual-stack
kubectl create namespace ipv4
kubectl create namespace ipv6

kubectl label --overwrite namespace default istio-injection=enabled
kubectl label --overwrite namespace dual-stack istio-injection=enabled
kubectl label --overwrite namespace ipv4 istio-injection=enabled
kubectl label --overwrite namespace ipv6 istio-injection=enabled

kubectl apply --namespace dual-stack -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/tcp-echo/tcp-echo-dual-stack.yaml
kubectl apply --namespace ipv4 -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/tcp-echo/tcp-echo-ipv4.yaml
kubectl apply --namespace ipv6 -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/tcp-echo/tcp-echo-ipv6.yaml

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/sleep/sleep.yaml

kubectl apply -f ~/aspenmesh/downloads/aspenmesh-carrier-grade-1.14.6-am5/samples/aspenmesh/simpleserver/dual-stack/simpleserver-dualstack.yaml -n dual-stack

# kubectl apply -n dual-stack -f $CWD/../aspenmesh-carrier-grade-1.14.6-am5/samples/aspenmesh/simpleserver/dual-stack/simpleserver-dualstack.yaml
# kubectl apply -n ipv4 -f $CWD/../aspenmesh-carrier-grade-1.14.6-am5/samples/aspenmesh/simpleserver/ipv4-only/simpleserver-ipv4-only.yaml
# kubectl apply -n ipv6 -f $CWD/../aspenmesh-carrier-grade-1.14.6-am5/samples/aspenmesh/simpleserver/ipv6-only/simpleserver-ipv6-only.yaml