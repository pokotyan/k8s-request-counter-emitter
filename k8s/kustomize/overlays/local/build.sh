#!/bin/sh
cd $(dirname $0)

# k8s-request-counter-emitter/k8s/kustomize/overlays/local にいる状態で実行する

#IMAGE_NAME="$1"
#kustomize edit set image app-image="${IMAGE_NAME}"
kustomize edit set image app-image="pokotyan/k8s-request-counter-emitter:latest"
kustomize build . >../../../manifest/app/app.yml
