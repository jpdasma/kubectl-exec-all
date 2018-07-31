#!/bin/bash
set -euo pipefail

if ! which jq &> /dev/null; then
    echo "Please install jq" 1>&2
    exit 1
fi

RESOURCE="${1}"
shift
RESOURCE_NAME="${1}"
shift

KUBECTL=${KUBECTL_PLUGINS_CALLER}
NAMESPACE=${KUBECTL_PLUGINS_GLOBAL_FLAG_NAMESPACE:-default}

CONTAINER=${KUBECTL_PLUGINS_LOCAL_FLAG_CONTAINER:-}
PARALLEL=${KUBECTL_PLUGINS_LOCAL_FLAG_PARALLEL:-1}


selector=$($KUBECTL -n "$NAMESPACE" get "$RESOURCE" "$RESOURCE_NAME" -o json |  jq -j '.spec.selector.matchLabels | to_entries | .[] | "\(.key)=\(.value),"')
selector=${selector%,}

if [[ -z "$CONTAINER" ]]; then
    $KUBECTL get pods -n "$NAMESPACE" --selector="$selector"  -o json | jq '.items | .[].metadata.name ' | xargs -I{} -n1 -P"${PARALLEL}" "$KUBECTL" exec -n "$NAMESPACE" -it '{}' -- "$@"
else
    $KUBECTL get pods -n "$NAMESPACE" --selector="$selector"  -o json | jq '.items | .[].metadata.name ' | xargs -I{} -n1 -P"${PARALLEL}" "$KUBECTL" exec -n "$NAMESPACE" -it --container="${CONTAINER}" '{}' -- "$@"
fi
