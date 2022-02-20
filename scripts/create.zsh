#!/usr/bin/env zsh

external_tools=(
  helm
  jq
  k3d
  step
)

for tool in ${(@)external_tools}; do
  if ! command -v $tool &>/dev/null; then
    echo "$tool not installed"
    exit 1
  fi
done

declare -A defaults
defaults=(
  [agent_count]=3
  [cluster_name]=dev
  [http_port]=8080
  [https_port]=8443
)

declare -A args
args=( ${(kv)defaults} )

usage() {
  printf "Purpose:\n"
  printf "  Create a local K8s cluster using K3s\n"

  printf "\nUsage:\n"
  printf "  create.zsh [-v] [-n <cluster-name>] [-s <server-count>] [-a <agent-count>]\n"

  printf "\nOptions:\n"
  format="  %-4s%-17s%-34s[Default: %s]\n"
  printf $format "-a" "<agent-count>" "set number of agent containers" $defaults[agent_count]
  printf $format "-h" "<http-port>" "host port to expose cluster lb HTTP protocol on" $defaults[http_port]
  printf $format "-n" "<cluster-name>" "set cluster name" $defaults[cluster_name]
  printf $format "-s" "<https-port>" "host port to expose cluster lb HTTPS protocol on" $defaults[https_port]
  printf $format "-v" "" "show debug info (set -x)" "false"
}

arg_err() {
  printf "Invalid option: %s requires an argument\n" $1 1>&2
}

create_cluster() {
  # Prevent k3d from failing due to too many open files on docker.sock
  ulimit -n 512

  k3d cluster create ${args[cluster_name]} \
    --agents ${args[agent_count]} \
    --servers 1 \
    --port "${args[http_port]}:80@loadbalancer" \
    --port "${args[https_port]}:443@loadbalancer" \
    --timeout 5m
}

provision_cluster() {
  helm install argocd argo/argo-cd \
    --atomic \
    --create-namespace \
    --namespace argocd \
    --set server.extraArgs={--insecure}

  kubectl apply -f manifests/argocd-ingressroute.yaml

  # Restart all pods to make sure they join the service mesh
  kubectl get namespaces -o json | jq -r '.items[].metadata.name' | xargs -n 1 -I{} kubectl -n {} rollout restart deployments
}

while getopts ":a:h:n:s:v" opt; do
  case  $opt in
    a  ) args[agent_count]=$OPTARG;;
    h  ) args[http_port]=$OPTARG;;
    n  ) args[cluster_name]=$OPTARG;;
    s  ) args[https_port]=$OPTARG;;
    v  ) args+=( [debug]=true );;
    \? ) usage; exit;;
    :  ) arg_err $OPTARG; exit 1;;
  esac
done

if [ ! -z ${args[debug]} ]; then
  set -x
fi

cluster_exists=$(k3d cluster list --output json | jq -r ".[] | select(.name==\"${args[cluster_name]}\") | .name")
if [[ -z $cluster_exists ]]; then
  create_cluster
  provision_cluster
else
  provision_cluster
fi
