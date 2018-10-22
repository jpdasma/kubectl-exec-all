#!/bin/bash
set -eo pipefail

if ! which jq &> /dev/null; then
    echo "Please install jq" 1>&2
    exit 1
fi

print_usage() {
    cat << EOF
Usage: kubectl exec_all [-c container_name] [-p number_parallel_executions] [-n namespace] resource resource_name command

Options:
-c          Container name if there are multiple containers in the pod. If not included, it will use the default container.
-p          Number of parallel executions.
-n          Namespace. If not included, it will use the one specified in kubeconfig file.
EOF
exit 1
}

container=
parallel=1
namespace=
while true; do
    case "$1" in
        "-c")
            shift
            container="$1"
            shift
            ;;
        "-p")
            shift
            parallel="$1"
            shift
            ;;
        "-n")
            shift
            namespace="$1"
            shift
            ;;
        *)
            break
            ;;
    esac
done

set -u

resource="$1"
resource_name="$2"

if [[ -z "${resource}" || -z "${resource_name}" ]]; then
    print_usage
fi

shift;shift;

kubectl=$(which kubectl)

if [[ -z ${container} ]]; then
    container_flag=
else
    container_flag="--container=${container}"
fi

if [[ -z ${namespace} ]]; then
    namespace_flag=
else
    namespace_flag="--namespace=${namespace}"
fi

# shellcheck disable=SC2086
selector=$(${kubectl} ${namespace_flag} get "$resource" "$resource_name" -o json |  jq -j '.spec.selector.matchLabels | to_entries | .[] | "\(.key)=\(.value),"')
selector=${selector%,}

# shellcheck disable=SC2086
${kubectl} get pods ${namespace_flag} --selector="$selector"  -o json | jq '.items | .[].metadata.name ' | xargs -I{} -n1 -P"${parallel}" "${kubectl}" exec $namespace_flag $container_flag '{}' -- "$@"
