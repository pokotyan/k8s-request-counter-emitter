#!/bin/bash

set -euo pipefail

cd $(dirname $0)

IMAGE_NAME="$1"
kustomize edit set image app-image="${IMAGE_NAME}"
kustomize build . >../../../manifest/app/app.yml | kubeval --strict --ignore-missing-schemas
