#!/bin/bash

if ! which jq &> /dev/null; then
    echo "Please install jq" 2>&1
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
    $KUBECTL get pods -n "$NAMESPACE" --selector="$selector"  | sed '1 d' | gawk '{ print $1 }' | xargs -I{} -n1 -P"${PARALLEL}" "$KUBECTL" exec -n "$NAMESPACE" -it '{}' -- "$@"
else
    $KUBECTL get pods -n "$NAMESPACE" --selector="$selector"  | sed '1 d' | gawk '{ print $1 }' | xargs -I{} -n1 -P"${PARALLEL}" "$KUBECTL" exec -n "$NAMESPACE" -it --container="${CONTAINER}" '{}' -- "$@"
fi